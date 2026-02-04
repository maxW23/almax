import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:lklk/core/config/app_config.dart';
import 'package:lklk/core/utils/logger.dart';

/// Event-driven, low-latency voice activity controller.
/// - Subscribes to LiveKit participant audioLevel changes (ChangeNotifier)
/// - Applies normalization, dynamic noise gate with hysteresis, and fast release
/// - Emits per-participant levels suitable for UI wave indicators
class VoiceActivityController {
  final lk.Room room;
  final bool Function() isLocalMicOn;

  VoiceActivityController({required this.room, required this.isLocalMicOn});

  final _levelsCtrl = StreamController<Map<String, double>>.broadcast();
  Stream<Map<String, double>> get levelsStream => _levelsCtrl.stream;

  lk.EventsListener<lk.RoomEvent>? _listener;
  final Map<String, _PerId> _state = {};
  final Map<String, VoidCallback> _detachers = {};
  final Map<String, VoidCallback> _tickers = {};
  Timer? _cleanup;

  void start() {
    // Create room events listener
    _listener = room.createListener()
      ..on<lk.ParticipantConnectedEvent>((e) {
        _attachParticipant(e.participant);
      })
      ..on<lk.ParticipantDisconnectedEvent>((e) {
        _detachParticipant(e.participant.identity);
      })
      ..on<lk.TrackSubscribedEvent>((e) {
        if (e.publication.kind == lk.TrackType.AUDIO) {
          _attachParticipant(e.participant);
        }
      })
      ..on<lk.TrackPublishedEvent>((e) {
        if (e.publication.kind == lk.TrackType.AUDIO) {
          _attachParticipant(e.participant);
        }
      })
      ..on<lk.TrackUnsubscribedEvent>((e) {
        if (e.publication.kind == lk.TrackType.AUDIO) {
          _attachParticipant(e.participant);
        }
      })
      ..on<lk.ActiveSpeakersChangedEvent>((e) {
        // Force an immediate recompute for all attached participants
        for (final tick in _tickers.values) {
          try { tick(); } catch (_) {}
        }
      });

    // Attach existing participants
    final local = room.localParticipant;
    if (local != null) _attachParticipant(local);
    for (final p in room.remoteParticipants.values) {
      _attachParticipant(p);
    }

    // Periodic small cleanup (safe, non-polling for levels)
    _cleanup = Timer.periodic(const Duration(seconds: 30), (_) {
      final identities = <String>{};
      if (room.localParticipant != null) identities.add(room.localParticipant!.identity);
      identities.addAll(room.remoteParticipants.keys);
      final toRemove = _state.keys.where((id) => !identities.contains(id)).toList();
      for (final id in toRemove) {
        _detachParticipant(id);
      }
    });
  }

  void dispose() {
    try { _listener?.dispose(); } catch (_) {}
    _listener = null;
    for (final d in _detachers.values) {
      try { d(); } catch (_) {}
    }
    _detachers.clear();
    _state.clear();
    _cleanup?.cancel();
    _cleanup = null;
    try { _levelsCtrl.close(); } catch (_) {}
  }

  void _attachParticipant(lk.Participant p) {
    final id = p.identity;
    // Detach previous listener/state if present first, then add fresh state
    _detachParticipant(id);
    _state[id] = _PerId();

    void cb() {
      try {
        double raw = p.audioLevel; // 0..1
        // Gate by mic/subscription
        final bool isLocal = (p is lk.LocalParticipant) || (room.localParticipant?.identity == p.identity);
        if (isLocal && !isLocalMicOn()) {
          raw = 0.0;
        } else if (!isLocal) {
          bool subscribed = true;
          try { subscribed = p.audioTrackPublications.any((pub) => pub.subscribed); } catch (_) {}
          if (!subscribed) raw = 0.0;
        }

        final st = _state[id]!;
        final norm = _normalize(raw);

        // Dynamic threshold based on recent quiet signal (when gate is closed)
        if (!st.gateOpen) {
          st.noiseFloor = (st.noiseFloor * 0.97) + (norm * 0.03);
          if (st.noiseFloor < 0.003) st.noiseFloor = 0.003;
          if (st.noiseFloor > 0.10) st.noiseFloor = 0.10; // never too high
        }
        final double openThr = math.max(st.noiseFloor + 0.02, 0.05);
        final double closeThr = math.max(st.noiseFloor + 0.01, 0.03);

        final now = DateTime.now();
        bool justOpened = false;
        final double dRaw = raw - st.lastRaw;
        final double dNorm = norm - st.lastNorm;
        if (st.gateOpen) {
          if (norm <= closeThr) {
            // Hold gate open up to 1000ms after last above-threshold sample
            if (now.difference(st.lastAbove) > const Duration(milliseconds: 1000)) {
              st.gateOpen = false;
            }
          } else {
            // Update last-above time and capture peak for hold envelope
            st.lastAbove = now;
            if (st.lastLevel > st.holdStart) {
              st.holdStart = st.lastLevel;
            }
          }
        } else {
          // Open immediately on clear onset: threshold OR small raw/norm burst
          if (norm >= openThr || raw > 0.010 || dRaw > 0.006 || dNorm > 0.05) {
            st.gateOpen = true;
            st.lastAbove = now;
            justOpened = true;
            // Seed hold to ensure visible envelope even for single-word bursts
            st.holdStart = st.lastLevel > 0 ? st.lastLevel : 0.32;
          }
        }

        // Visual target with 1s hold envelope when gate is open
        double target;
        if (st.gateOpen) {
          final int elapsedMs = now.difference(st.lastAbove).inMilliseconds;
          double holdLevel = 0.0;
          if (norm <= closeThr && elapsedMs <= 1000) {
            final double frac = (elapsedMs.clamp(0, 1000)) / 1000.0;
            holdLevel = st.holdStart * (1.0 - frac);
          }
          target = math.max(norm, holdLevel);
        } else {
          target = 0.0;
        }
        if (justOpened && target < 0.25) {
          target = 0.32; // immediate, visible start
        }
        // Fast-onset path: if we were quiet and a clear burst arrives, lift immediately
        if (!justOpened && st.lastLevel <= 0.25) {
          if (norm >= openThr || raw > 0.015) {
            if (target < 0.32) target = 0.32;
          }
        }

        // Smooth with attack/release
        final double smooth = _smooth(st.lastLevel, target);
        st.lastLevel = smooth;
        st.lastRaw = raw;
        st.lastNorm = norm;

        // Emit
        _levelsCtrl.add({id: smooth});
        if (AppConfig.enableLogging) {
          final bool isLocal = (p is lk.LocalParticipant) || (room.localParticipant?.identity == p.identity);
          bool subscribed = true;
          if (!isLocal) {
            try { subscribed = p.audioTrackPublications.any((pub) => pub.subscribed); } catch (_) {}
          }
          AppLogger.debug(
            'VAC meter id=$id local=$isLocal raw=${raw.toStringAsFixed(3)} norm=${norm.toStringAsFixed(3)} openThr=${(math.max(st.noiseFloor + 0.05, 0.10)).toStringAsFixed(3)} closeThr=${(math.max(st.noiseFloor + 0.02, 0.06)).toStringAsFixed(3)} gate=${st.gateOpen} target=${target.toStringAsFixed(3)} smooth=${smooth.toStringAsFixed(3)} subscribed=$subscribed',
            tag: 'VoiceActivityController',
          );
        }
      } catch (_) {}
    }

    try { p.addListener(cb); } catch (_) {}
    _detachers[id] = () {
      try { p.removeListener(cb); } catch (_) {}
    };
    _tickers[id] = cb;

    // Prime once
    cb();
  }

  void _detachParticipant(String identity) {
    final d = _detachers.remove(identity);
    if (d != null) {
      try { d(); } catch (_) {}
    }
    _state.remove(identity);
    _tickers.remove(identity);
  }

  // Normalization with fixed low noise floor and gentle shaping
  double _normalize(double level) {
    const double noiseFloor = 0.008;
    if (level <= noiseFloor) return 0.0;
    double norm = (level - noiseFloor) / (1.0 - noiseFloor);
    norm = math.pow(norm, 0.70).toDouble();
    return norm.clamp(0.0, 1.0);
  }

  double _smooth(double previous, double target) {
    if (previous <= 0.25 && target > 0.25) {
      return target; // instant rise at threshold
    }
    if (previous > 0.25 && target < 0.18) {
      return target; // instant fall well below threshold
    }
    const double attack = 1.0;
    const double release = 0.35;
    final double alpha = target > previous ? attack : release;
    return previous + (target - previous) * alpha;
  }
}

class _PerId {
  double noiseFloor = 0.008;
  bool gateOpen = false;
  DateTime lastAbove = DateTime.fromMillisecondsSinceEpoch(0);
  double lastLevel = 0.0;
  double lastRaw = 0.0;
  double lastNorm = 0.0;
  double holdStart = 0.0;
}

import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

/// Lightweight performance logger (no platform code needed)
/// - Logs RAM RSS and ImageCache usage periodically
/// - Logs frame timings (build/raster) and flags jank
class PerformanceLogger {
  PerformanceLogger._();
  static final PerformanceLogger instance = PerformanceLogger._();

  Timer? _timer;
  int _lastRss = 0;
  // snapshot of frame stats to print then reset each tick
  final _frameStats = _FrameStatsAggregator();

  /// Start periodic logging (every [interval])
  void start({Duration interval = const Duration(seconds: 5)}) {
    stop();
    // Guard: only meaningful in debug/profile to avoid noisy release logs
    if (!(kDebugMode || kProfileMode)) {
      AppLogger.info('PerformanceLogger suppressed in release builds', tag: 'Perf');
      return;
    }
    _timer = Timer.periodic(interval, (_) => _tick());
    AppLogger.info('PerformanceLogger started interval=${interval.inSeconds}s', tag: 'Perf');
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    try {
      // RAM (Resident Set Size)
      final rss = ProcessInfo.currentRss; // bytes
      final delta = rss - _lastRss;
      _lastRss = rss;

      // ImageCache
      final cache = PaintingBinding.instance.imageCache;
      final cacheBytes = cache.currentSizeBytes;
      final cacheCount = cache.currentSize;
      final liveCount = cache.liveImageCount;

      // periodic RAM + cache
      AppLogger.log(
        '🧠 RAM rss=${_fmtBytes(rss)} (Δ ${_fmtBytes(delta)}) | '
        '🖼 ImageCache bytes=${_fmtBytes(cacheBytes)} current=$cacheCount live=$liveCount',
        tag: 'Perf',
      );

      // periodic frame summary
      final summary = _frameStats.takeAndReset();
      if (summary != null) {
        AppLogger.log(
          '📊 Frames: total=${summary.total} jank=${summary.jank} worst=${summary.worstTotalMs}ms '
          '(build=${summary.worstBuildMs}ms raster=${summary.worstRasterMs}ms)',
          tag: 'Perf',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.log('Perf tick error: $e', tag: 'Perf');
      }
    }
  }

  String _fmtBytes(int b) {
    const k = 1024;
    if (b.abs() < k) return '${b}B';
    if (b.abs() < k * k) return '${(b / k).toStringAsFixed(1)}KB';
    if (b.abs() < k * k * k) return '${(b / k / k).toStringAsFixed(1)}MB';
    return '${(b / k / k / k).toStringAsFixed(1)}GB';
  }
}

/// Register a callback to log frame timings (build/raster) and detect jank.
void initFrameTimingsLogging() {
  if (!(kDebugMode || kProfileMode)) return;
  SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
    for (final t in timings) {
      final buildMs = t.buildDuration.inMilliseconds;
      final rasterMs = t.rasterDuration.inMilliseconds;
      final totalMs = buildMs + rasterMs;
      final isJank = totalMs > 17; // soften threshold (~16.7ms @60Hz)
      final heavy = totalMs >= 100;

      AppLogger.log(
        '🎯 Frame build=${buildMs}ms raster=${rasterMs}ms total=${totalMs}ms '
        '${isJank ? '⚠️ JANK' : ''} ${heavy ? '🔥 HEAVY' : ''}',
        tag: 'Perf',
      );

      // aggregate to summarize later
      PerformanceLogger.instance._frameStats.add(buildMs, rasterMs, totalMs, isJank);
    }
  });
  AppLogger.info('Frame timings logging initialized', tag: 'Perf');
}

/// Initialize VM Service-based heap logging (Debug/Profile only)
Future<void> initHeapLogging({Duration interval = const Duration(seconds: 10)}) async {
  if (!(kDebugMode || kProfileMode)) return;
  await _HeapLogger.instance.start(interval: interval);
}

class _HeapLogger {
  _HeapLogger._();
  static final _HeapLogger instance = _HeapLogger._();

  VmService? _service;
  String? _isolateId;
  Timer? _timer;
  bool _starting = false;

  Future<void> start({required Duration interval}) async {
    if (_timer != null || _starting) return;
    _starting = true;
    try {
      final info = await dev.Service.getInfo();
      final uri = info.serverUri;
      if (uri == null) {
        AppLogger.warning('VM Service URI not available; heap logging disabled', tag: 'Perf');
        _starting = false;
        return;
      }

      final wsUri = Uri(
        scheme: uri.scheme == 'https' ? 'wss' : 'ws',
        host: uri.host,
        port: uri.port,
        path: uri.path.endsWith('/') ? '${uri.path}ws' : '${uri.path}/ws',
      ).toString();

      _service = await vmServiceConnectUri(wsUri);
      // Resolve current isolate id via VM listing (portable across SDKs)
      final vm = await _service!.getVM();
      if (vm.isolates == null || vm.isolates!.isEmpty) {
        AppLogger.warning('No isolates found; heap logging disabled', tag: 'Perf');
        _starting = false;
        return;
      }
      _isolateId = vm.isolates!.first.id;

      _timer = Timer.periodic(interval, (_) => _tick());
      AppLogger.info('Heap logging started interval=${interval.inSeconds}s', tag: 'Perf');
    } catch (e) {
      AppLogger.warning('Heap logging init failed: $e', tag: 'Perf');
    } finally {
      _starting = false;
    }
  }

  Future<void> _tick() async {
    final svc = _service;
    final isoId = _isolateId;
    if (svc == null || isoId == null) return;
    try {
      final mem = await svc.getMemoryUsage(isoId);
      final alloc = await svc.getAllocationProfile(isoId, reset: false);

      final heapUsage = mem.heapUsage ?? 0;
      final heapCap = mem.heapCapacity ?? 0;

      String topStr = '';
      final members = alloc.members ?? const [];
      if (members.isNotEmpty) {
        int _instances(dynamic m) => (m?.instancesCurrent as int?) ?? 0;
        String _name(dynamic m) => (m?.classRef?.name as String?) ?? 'Unknown';
        final sorted = List<dynamic>.from(members)
          ..sort((a, b) => _instances(b).compareTo(_instances(a)));
        final top = sorted.take(5).map((m) => '${_name(m)}:${_instances(m)}').join(', ');
        topStr = ' | top: $top';
      }

      AppLogger.log(
        '🧩 HEAP usage=${_fmtBytes(heapUsage)} cap=${_fmtBytes(heapCap)}$topStr',
        tag: 'Perf',
      );
    } catch (e) {
      AppLogger.warning('Heap tick failed: $e', tag: 'Perf');
    }
  }

  String _fmtBytes(int b) {
    const k = 1024;
    final abs = b.abs();
    if (abs < k) return '${b}B';
    if (abs < k * k) return '${(b / k).toStringAsFixed(1)}KB';
    if (abs < k * k * k) return '${(b / k / k).toStringAsFixed(1)}MB';
    return '${(b / k / k / k).toStringAsFixed(1)}GB';
  }
}

class _FrameStatsAggregator {
  int _total = 0;
  int _jank = 0;
  int _worstTotal = 0;
  int _worstBuild = 0;
  int _worstRaster = 0;

  void add(int buildMs, int rasterMs, int totalMs, bool isJank) {
    _total++;
    if (isJank) _jank++;
    if (totalMs >= _worstTotal) {
      _worstTotal = totalMs;
      _worstBuild = buildMs;
      _worstRaster = rasterMs;
    }
  }

  _FrameSummary? takeAndReset() {
    if (_total == 0) return null;
    final summary = _FrameSummary(
      total: _total,
      jank: _jank,
      worstTotalMs: _worstTotal,
      worstBuildMs: _worstBuild,
      worstRasterMs: _worstRaster,
    );
    _total = 0;
    _jank = 0;
    _worstTotal = 0;
    _worstBuild = 0;
    _worstRaster = 0;
    return summary;
  }
}

class _FrameSummary {
  final int total;
  final int jank;
  final int worstTotalMs;
  final int worstBuildMs;
  final int worstRasterMs;
  _FrameSummary({
    required this.total,
    required this.jank,
    required this.worstTotalMs,
    required this.worstBuildMs,
    required this.worstRasterMs,
  });
}

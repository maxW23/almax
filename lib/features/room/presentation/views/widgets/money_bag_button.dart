import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/combined_realtime_service.dart';
import 'package:lklk/features/room/presentation/views/widgets/envelope_dialog.dart';
import 'package:lklk/features/room/presentation/views/widgets/money_bag_result_dialog.dart';
import 'package:lklk/zego_sdk_manager.dart';

const int kMoneyBagDurationSeconds = 17;
const int kBagDelaySeconds = 3; // تأخير 3 ثواني بين الحقائب

class MoneyBagButton extends StatefulWidget {
  final CombinedRealtimeService resultService;
  final void Function(ZIMMessage) onSendMessage;
  final Map<String, dynamic>? initialResult;
  final bool isVisible;
  final String currentRoomId;

  const MoneyBagButton({
    super.key,
    required this.resultService,
    required this.onSendMessage,
    this.initialResult,
    this.isVisible = true,
    required this.currentRoomId,
  });

  @override
  State<MoneyBagButton> createState() => _MoneyBagButtonState();
}

class _MoneyBagButtonState extends State<MoneyBagButton> {
  OverlayEntry? _resultOverlay;
  final List<Map<String, dynamic>> _moneyBags = [];
  final List<Map<String, dynamic>> _moneyBagResults = [];
  StreamSubscription? _resultSubscription;
  final Map<String, DateTime> _lastMessageTimes = {};
  final Map<String, Timer> _buttonTimers = {};
  final Map<String, int> _remainingSecondsMap = {};
  final Set<String> _recentlyHandledBags = {};
  final Queue<Map<String, dynamic>> _bagQueue = Queue();
  Map<String, dynamic>? _currentDisplayedBag;
  final Map<String, Map<String, dynamic>> _bagResults = {};
  bool _isProcessingBag = false;
  // Key for the EnvelopeDialog to allow notifying it when a result arrives
  GlobalKey<EnvelopeDialogState>? _envelopeKey;
  // The end time (ms) of the last bag scheduled in the queue. Used to
  // chain display times so queued bags don't expire while waiting.
  int _lastQueueEndMs = 0;

  bool isDuplicate(String bagId, String type) {
    final key = '$bagId|$type';
    return _recentlyHandledBags.contains(key);
  }

  void markHandled(String bagId, String type) {
    final key = '$bagId|$type';
    _recentlyHandledBags.add(key);
  }

  @override
  void initState() {
    super.initState();
    log('MoneyBagButton initialized for room: ${widget.currentRoomId}');
    _resultSubscription =
        widget.resultService.resultsStream.listen(_handleResultData);
    // اطلب backfill بعد الاشتراك لضمان التقاط الحقائب النشطة الحالية
    // (تجنب فقدان حدث backfill الذي قد يُرسل قبل بناء الزر)
    Future.microtask(() => widget.resultService.resyncActiveBags());
  }

  @override
  void didUpdateWidget(covariant MoneyBagButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تبديل مصدر النتائج عند تغيير الخدمة
    if (oldWidget.resultService != widget.resultService) {
      _resultSubscription?.cancel();
      _resultSubscription =
          widget.resultService.resultsStream.listen(_handleResultData);
    }

    // إعادة تهيئة الحالة عند تغيير الغرفة لمنع ترحيل حالة قديمة
    if (oldWidget.currentRoomId != widget.currentRoomId) {
      // إغلاق أي طبقة معروضة
      _dismissResultOverlay();
      // إلغاء جميع المؤقتات
      for (final t in _buttonTimers.values) {
        t.cancel();
      }
      _buttonTimers.clear();

      setState(() {
        _moneyBags.clear();
        _moneyBagResults.clear();
        _bagQueue.clear();
        _bagResults.clear();
        _remainingSecondsMap.clear();
        _recentlyHandledBags.clear();
        _currentDisplayedBag = null;
        _isProcessingBag = false;
        _lastQueueEndMs = 0;
      });
    }
  }

  void _handleResultData(Map<String, dynamic> result) {
    final type = result['type'];
    final roomID = result['room_id']?.toString();
    final bagId = (type == 'money_bag_result')
        ? result['gift_id']?.toString()
        : result[r'$id']?.toString();

    // normalize createdAt to int (ms)
    int createdAtMs = DateTime.now().millisecondsSinceEpoch;
    final rawCreated = result['createdAt'] ?? result['timestamp'];
    if (rawCreated != null) {
      if (rawCreated is String) {
        final parsed = int.tryParse(rawCreated) ?? 0;
        createdAtMs = (parsed < 100000000000) ? parsed * 1000 : parsed;
      } else if (rawCreated is int) {
        createdAtMs =
            (rawCreated < 100000000000) ? rawCreated * 1000 : rawCreated;
      }
    }
    result['createdAt'] = createdAtMs;

    if (type != null && roomID == widget.currentRoomId && bagId != null) {
      if (type == 'money_bag') {
        // If the realtime service already provided a display window, use it.
        if (result.containsKey('_displayEndAt') &&
            result['_displayEndAt'] is int) {
          final endMs = result['_displayEndAt'] as int;
          final startMs = result['_displayStartAt'] is int
              ? result['_displayStartAt'] as int
              : (endMs - (kMoneyBagDurationSeconds * 1000));
          // keep local chain tracker in sync
          _lastQueueEndMs = endMs;
          result['_displayStartAt'] = startMs;
          result['_displayEndAt'] = endMs;
        } else {
          // schedule display times for the queued bag so that multiple bags
          // are chained. Use the bag's createdAt if it's later than the last
          // scheduled end; otherwise start after last scheduled end.
          final createdAtMs = result['createdAt'] as int? ??
              DateTime.now().millisecondsSinceEpoch;
          final startMs =
              createdAtMs > _lastQueueEndMs ? createdAtMs : _lastQueueEndMs;
          final endMs = startMs + (kMoneyBagDurationSeconds * 1000);
          result['_displayStartAt'] = startMs;
          result['_displayEndAt'] = endMs;
          _lastQueueEndMs = endMs;
        }

        setState(() {
          _moneyBags.removeWhere((bag) => bag[r'$id'] == bagId);
          _moneyBags.add(result);
          _lastMessageTimes[bagId] = DateTime.now();

          log('[_MoneyBagButton] ➕ Queued bag $bagId (start: ${DateTime.fromMillisecondsSinceEpoch(result['_displayStartAt'] as int)}, end: ${DateTime.fromMillisecondsSinceEpoch(result['_displayEndAt'] as int)})');

          // Add to queue and update display
          _bagQueue.addLast(result);
          if (!_isProcessingBag) {
            _updateDisplayedBag();
          }
        });
      } else if (type == 'money_bag_result') {
        log('💰 Processing money_bag_result message for room: $roomID, bag: $bagId');

        if (!result.containsKey('createdAt')) {
          result['createdAt'] = DateTime.now().millisecondsSinceEpoch;
        }

        if (!isDuplicate(bagId, type)) {
          markHandled(bagId, type);
          _lastMessageTimes[bagId] = DateTime.now();

          setState(() {
            _moneyBagResults.removeWhere((r) => r['gift_id'] == bagId);
            _moneyBagResults.add(result);

            // Store the result for this bag
            _bagResults[bagId] = result;

            // If this result corresponds to the currently displayed bag
            if (_currentDisplayedBag != null &&
                _currentDisplayedBag![r'$id'] == bagId) {
              // Stop the timer as we have the result
              _buttonTimers[bagId]?.cancel();
              _remainingSecondsMap[bagId] = 0;
              // Notify envelope dialog (if open) to stop its timer and open result
              try {
                _envelopeKey?.currentState?.notifyResultArrived();
                log('[_MoneyBagButton] 🔔 Notified EnvelopeDialog for bag $bagId result');
              } catch (e) {
                log('[_MoneyBagButton] ❌ Failed to notify EnvelopeDialog: $e');
              }
            }
          });
        } else {
          log('⚠️ Duplicate money_bag_result ignored for bagId: $bagId');
        }
      }
    } else {
      log('❌ Ignoring message - Type: $type, RoomID: $roomID, CurrentRoomID: ${widget.currentRoomId}');
    }
  }

  void _updateDisplayedBag() {
    if (_currentDisplayedBag == null &&
        _bagQueue.isNotEmpty &&
        !_isProcessingBag) {
      setState(() {
        _currentDisplayedBag = _bagQueue.removeFirst();
        final bagId = _currentDisplayedBag![r'$id']?.toString();
        if (bagId != null) {
          // Start timer based on the assigned display end time so remaining
          // seconds are consistent across UI and service layers.
          final endMs = _currentDisplayedBag!['_displayEndAt'] as int?;
          if (endMs != null) {
            log('[_MoneyBagButton] ⏳ Starting timer for displayed bag $bagId until ${DateTime.fromMillisecondsSinceEpoch(endMs)}');
            _startButtonTimer(endMs, bagId);
          } else {
            // fallback: start from now for backward compatibility
            final fallbackEnd = DateTime.now().millisecondsSinceEpoch +
                (kMoneyBagDurationSeconds * 1000);
            log('[_MoneyBagButton] ⚠️ No display end for $bagId, fallback end: ${DateTime.fromMillisecondsSinceEpoch(fallbackEnd)}');
            _startButtonTimer(fallbackEnd, bagId);
          }
        }
      });
    }
  }

  // now the timer receives the display end timestamp (ms) so we compute
  // remaining seconds as (end - now). This keeps the timer consistent with
  // assigned display windows in the queue.
  void _startButtonTimer(int displayEndMs, String bagId) {
    _buttonTimers[bagId]?.cancel();

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final remaining = ((displayEndMs - nowMs) / 1000).floor();
    _remainingSecondsMap[bagId] = remaining > 0 ? remaining : 0;

    if ((_remainingSecondsMap[bagId] ?? 0) > 0) {
      _buttonTimers[bagId] =
          Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && (_remainingSecondsMap[bagId] ?? 0) > 0) {
          setState(() {
            _remainingSecondsMap[bagId] = _remainingSecondsMap[bagId]! - 1;
          });
        } else {
          timer.cancel();
          // Move to next bag when timer expires
          if (_currentDisplayedBag != null &&
              _currentDisplayedBag![r'$id'] == bagId) {
            _processNextBagWithDelay();
          }
        }
      });
    } else {
      _processNextBagWithDelay();
    }
  }

  void _processNextBagWithDelay() {
    // حفظ معرف الحقيبة الحالية قبل مسحها
    final currentBagId = _currentDisplayedBag?[r'$id']?.toString();

    setState(() {
      _isProcessingBag = true;
      // لا تقم بتعيين _currentDisplayedBag إلى null هنا، دع عملية التنظيف تتم بشكل منفصل
    });

    // تنظيف الحقيبة الحالية فقط
    if (currentBagId != null) {
      _buttonTimers[currentBagId]?.cancel();
      _buttonTimers.remove(currentBagId);
      _remainingSecondsMap.remove(currentBagId);
      _bagResults.remove(currentBagId);
      _recentlyHandledBags
          .removeWhere((key) => key.startsWith('$currentBagId|'));
      _lastMessageTimes.remove(currentBagId);
    }

    // انتظر 3 ثواني قبل عرض الحقيبة التالية
    Future.delayed(const Duration(seconds: kBagDelaySeconds), () {
      if (mounted) {
        setState(() {
          _isProcessingBag = false;
          _currentDisplayedBag = null; // الآن يمكن مسح الحقيبة الحالية
          _updateDisplayedBag();
          log('[_MoneyBagButton] ▶️ Advanced to next bag (queue length: ${_bagQueue.length})');
        });
      }
    });
  }

  int _calculateRemainingSeconds(int createdAtMs) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final elapsed = ((nowMs - createdAtMs) / 1000).floor();
    final remaining = kMoneyBagDurationSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  void _showEnvelopeDialog(Map<String, dynamic> result) {
    final type = result['type'];
    final bagId = (result['type'] == 'money_bag_result')
        ? result['gift_id']?.toString()
        : result[r'$id']?.toString();
    log('🎯 _showEnvelopeDialog called with type: $type, bag: $bagId');

    if (result.isEmpty || type == null || bagId == null) {
      log('❌ No valid result to show in envelope dialog');
      _dismissResultOverlay();
      return;
    }

    if (type == 'money_bag_result' &&
        (result['message'] == null || result['message'].isEmpty)) {
      log('❌ money_bag_result has no message, cannot show dialog');
      _dismissResultOverlay();
      return;
    }

    _dismissResultOverlay();

    log('✅ Creating overlay entry for envelope dialog');

    // create a key for this dialog so we can notify it when results arrive
    _envelopeKey = GlobalKey<EnvelopeDialogState>();

    _resultOverlay = OverlayEntry(
      builder: (context) {
        log('🏗️ Building envelope dialog widget for type: $type');
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                log('👆 User tapped outside envelope dialog');
                _dismissResultOverlay();
              },
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            Center(
              child: EnvelopeDialog(
                key: _envelopeKey,
                result: result,
                onDismiss: () {
                  log('❌ Envelope dialog dismissed');
                  _dismissResultOverlay();
                },
                onOpen: () {
                  log('🚀 Envelope dialog opened for type: $type');
                  _dismissResultOverlay();

                  // If we have a result for this bag, show it directly
                  final resultBagId = result[r'$id']?.toString();
                  if (resultBagId != null &&
                      _bagResults.containsKey(resultBagId)) {
                    log('💰 Opening result dialog for money_bag_result');
                    _showResultDialog(_bagResults[resultBagId]!);
                  }
                },
                moneyBagDurationSeconds: kMoneyBagDurationSeconds,
                displayEndAtMs: result['_displayEndAt'] as int?,
              ),
            ),
          ],
        );
      },
    );

    try {
      Overlay.of(context).insert(_resultOverlay!);
      log('✅ Overlay inserted successfully');
    } catch (e) {
      log('❌ Error inserting overlay: $e');
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    log('💡 _showResultDialog called with result: $result');

    if (result.isEmpty || result['type'] == null) {
      log('❌ Result is empty or type is null, dismissing overlay.');
      _dismissResultOverlay();
      return;
    }

    _dismissResultOverlay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resultOverlay = OverlayEntry(
        builder: (context) {
          return Stack(
            children: [
              GestureDetector(
                onTap: _dismissResultOverlay,
                child: Container(color: Colors.black.withValues(alpha: 0.5)),
              ),
              Center(
                child: MoneyBagResultDialog(
                  result: result,
                  onDismiss: () {
                    _dismissResultOverlay();
                  },
                  onOkPressed: () {
                    // Remove only the currently displayed bag and immediately
                    // advance to the next queued bag without affecting others.
                    final currentId = _currentDisplayedBag?[r'$id']?.toString();
                    if (currentId != null) {
                      // perform same cleanup as in _processNextBagWithDelay but without waiting
                      _buttonTimers[currentId]?.cancel();
                      _buttonTimers.remove(currentId);
                      _remainingSecondsMap.remove(currentId);
                      _bagResults.remove(currentId);
                      _recentlyHandledBags
                          .removeWhere((key) => key.startsWith('$currentId|'));
                      _lastMessageTimes.remove(currentId);
                    }

                    setState(() {
                      _currentDisplayedBag = null;
                      _isProcessingBag = false;
                    });

                    // Immediately display next bag if present
                    _updateDisplayedBag();

                    log('[_MoneyBagButton] ✅ Result OK pressed for $currentId, showing next if any');
                    _dismissResultOverlay();
                  },
                ),
              ),
            ],
          );
        },
      );

      try {
        Overlay.of(context).insert(_resultOverlay!);
        log('✅ MoneyBagResultDialog overlay inserted successfully.');
      } catch (e, st) {
        log('❌ Error inserting overlay: $e\n$st');
      }
    });
  }

  void _dismissResultOverlay() {
    _resultOverlay?.remove();
    _resultOverlay = null;
    // clear the envelope dialog key when overlay is dismissed
    _envelopeKey = null;
    log('🧹 Overlay dismissed');
  }

  void _handleBagTap() {
    if (_currentDisplayedBag != null && !_isProcessingBag) {
      final type = _currentDisplayedBag!['type'];
      final bagId = _currentDisplayedBag![r'$id']?.toString();
      log('🎯 _handleBagTap called for bagId: $bagId, type: $type');

      // If we have a result for this bag, show it directly
      if (bagId != null && _bagResults.containsKey(bagId)) {
        _showResultDialog(_bagResults[bagId]!);
      } else if (type == 'money_bag') {
        _sendGrabMessage(_currentDisplayedBag);
        _showEnvelopeDialog(_currentDisplayedBag!);
      } else if (type == 'money_bag_result') {
        _showEnvelopeDialog(_currentDisplayedBag!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _clearOldResults();

    if (_currentDisplayedBag == null &&
        _bagQueue.isNotEmpty &&
        !_isProcessingBag) {
      _updateDisplayedBag();
    }

    if (_currentDisplayedBag == null || _isProcessingBag) {
      return const SizedBox.shrink();
    }

    return _buildBagButton(_currentDisplayedBag!);
  }

  Widget _buildBagButton(Map<String, dynamic> bagData) {
    final type = bagData['type'];
    final bagId = bagData[r'$id']?.toString();
    final createdAt = bagData['createdAt'];
    final remainingSeconds = bagId != null
        ? (_remainingSecondsMap[bagId] ?? _calculateRemainingSeconds(createdAt))
        : _calculateRemainingSeconds(createdAt);

    // Check if we have a result for this bag
    final hasResult = bagId != null && _bagResults.containsKey(bagId);

    return Stack(
      alignment: Alignment.topRight,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: _handleBagTap,
              child: Image.asset(
                AssetsData.bagBtn,
                height: 50,
                width: 50,
                // color: hasResult
                //     ? Colors.green
                //     : null, // Change color if result is ready
              ),
            ),
            if (type == 'money_bag' && remainingSeconds > 0 && !hasResult)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$remainingSeconds',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (hasResult)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'جاهز',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        if (_bagQueue.isNotEmpty)
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: const Color(0xFFFF0000),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${_bagQueue.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _clearOldResults() {
    final now = DateTime.now();

    // تنظيف الحقائب القديمة
    _moneyBags.removeWhere((bag) {
      final bagId = bag[r'$id']?.toString();
      // إذا الحقيبة موجودة في الطابور أو هي الحقيبة المعروضة، لا تمسحها الآن
      if (bagId != null) {
        final inQueue = _bagQueue.any((b) => b[r'$id']?.toString() == bagId);
        final isCurrent = _currentDisplayedBag != null &&
            _currentDisplayedBag![r'$id']?.toString() == bagId;
        if (inQueue || isCurrent) return false;
      }
      if (bagId != null && _lastMessageTimes.containsKey(bagId)) {
        final timeDiff = now.difference(_lastMessageTimes[bagId]!);
        if (timeDiff.inSeconds > 30) {
          _buttonTimers[bagId]?.cancel();
          _remainingSecondsMap.remove(bagId);
          _bagResults.remove(bagId);
          _bagQueue.removeWhere((b) => b[r'$id'] == bagId);
          if (_currentDisplayedBag != null &&
              _currentDisplayedBag![r'$id'] == bagId) {
            _currentDisplayedBag = null;
          }
          return true;
        }
      }
      return false;
    });

    // تنظيف نتائج الحقائب القديمة
    _moneyBagResults.removeWhere((result) {
      final bagId = (result['type'] == 'money_bag_result')
          ? result['gift_id']?.toString()
          : result[r'$id']?.toString();
      if (bagId != null && _lastMessageTimes.containsKey(bagId)) {
        final timeDiff = now.difference(_lastMessageTimes[bagId]!);
        if (timeDiff.inSeconds > 300) {
          _bagResults.remove(bagId);
          return true;
        }
      }
      return false;
    });
  }

  void _sendGrabMessage([Map<String, dynamic>? bagData]) async {
    try {
      final userAuth = await AuthService.getUserFromSharedPreferences();
      final text = userAuth?.id.toString().trim();

      final msg = ZIMBarrageMessage(message: text ?? "");
      final customData = {
        "gift_type": "lucky_bag",
        "UserImage": "${userAuth?.img}",
        "UserVipLevel": int.tryParse(userAuth?.vip.toString() ?? '0'),
        "UserName": "${userAuth?.name}",
        "UserID": text,
        "room_id": widget.currentRoomId,
        "SenderID": bagData?["reciver"]?.toString(),
        "bag_id": bagData?[r'$id']?.toString(),
        "how": bagData?["gift_id"]?.toString(),
        "who": bagData?["selected_usr"]?.toString(),
        "createdAt": DateTime.now().millisecondsSinceEpoch
      };

      msg.extendedData = jsonEncode(customData);
      final result = await ZIM.getInstance()!.sendMessage(
            msg,
            widget.currentRoomId,
            ZIMConversationType.room,
            ZIMMessageSendConfig(),
          );
      widget.onSendMessage(result.message);
    } catch (e) {
      log("Send error: $e");
    }
  }

  @override
  void dispose() {
    _resultSubscription?.cancel();
    _dismissResultOverlay();

    // إلغاء جميع المؤقتات
    for (final timer in _buttonTimers.values) {
      timer.cancel();
    }

    _moneyBags.clear();
    _moneyBagResults.clear();
    _lastMessageTimes.clear();
    _remainingSecondsMap.clear();
    _bagQueue.clear();
    _bagResults.clear();

    super.dispose();
  }
}

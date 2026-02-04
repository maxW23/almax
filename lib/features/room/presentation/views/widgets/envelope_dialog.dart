import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

class EnvelopeDialog extends StatefulWidget {
  final Map<String, dynamic> result;
  final VoidCallback onDismiss;
  final VoidCallback onOpen;
  final int moneyBagDurationSeconds;
  // Optional: receive display end timestamp (ms) to compute remaining time
  final int? displayEndAtMs;

  const EnvelopeDialog({
    super.key,
    required this.result,
    required this.onDismiss,
    required this.onOpen,
    this.moneyBagDurationSeconds = 17,
    this.displayEndAtMs,
  });

  @override
  State<EnvelopeDialog> createState() => EnvelopeDialogState();
}

class EnvelopeDialogState extends State<EnvelopeDialog> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _canOpen = false;

  @override
  void initState() {
    super.initState();

    final type = widget.result['type'];

    if (type == 'money_bag_result') {
      _canOpen = true;
      _remainingSeconds = 0;
      return;
    }

    // Prefer explicit display end timestamp if provided (keeps queue timing in sync)
    if (widget.displayEndAtMs != null) {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final remaining = ((widget.displayEndAtMs! - nowMs) / 1000).floor();
      _remainingSeconds = remaining > 0 ? remaining : 0;
      log('[EnvelopeDialog] ⏱ displayEndAt=${DateTime.fromMillisecondsSinceEpoch(widget.displayEndAtMs!)} remaining=$_remainingSeconds');

      if (_remainingSeconds > 0) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_remainingSeconds > 0) {
            setState(() {
              _remainingSeconds--;
            });
          } else {
            setState(() {
              _canOpen = true;
            });
            timer.cancel();
          }
        });
      } else {
        _canOpen = true;
      }
    } else {
      final createdAt = widget.result['createdAt'];
      if (createdAt != null) {
        final createdTime = DateTime.fromMillisecondsSinceEpoch(createdAt);
        final now = DateTime.now();
        final elapsed = now.difference(createdTime).inSeconds;
        _remainingSeconds = widget.moneyBagDurationSeconds - elapsed;

        if (_remainingSeconds > 0) {
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (_remainingSeconds > 0) {
              setState(() {
                _remainingSeconds--;
              });
            } else {
              setState(() {
                _canOpen = true;
              });
              timer.cancel();
            }
          });
        } else {
          _canOpen = true;
        }
      } else {
        _canOpen = true;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Called by parent when a corresponding `money_bag_result` arrives.
  /// Stops the countdown and triggers `onOpen` to show the result.
  void notifyResultArrived() {
    try {
      _timer?.cancel();
      setState(() {
        _remainingSeconds = 0;
        _canOpen = true;
      });
      // Trigger the parent handler to open the result overlay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onOpen();
      });
    } catch (e) {
      log('[EnvelopeDialog] Error in notifyResultArrived: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userImage = widget.result['img'] as String?;
    final giftSender = widget.result['gift_sender'] ?? 'مستخدم مجهول';
    final type = widget.result['type'];

    final title = type == 'money_bag_result' ? 'نتيجة الحقيبة' : 'حقيبة الحظ';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          GestureDetector(
            onTap: _canOpen ? widget.onOpen : null,
            child: Container(
              width: 280,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(AssetsData.envelope,
                        width: 280, height: 350, fit: BoxFit.fill),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: userImage != null && userImage.isNotEmpty
                              ? ClipOval(
                                  child:
                                      CircularUserImage(imagePath: userImage),
                                )
                              : const Icon(Icons.person,
                                  size: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 175),
                      Text(
                        giftSender,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        type == 'money_bag_result'
                            ? 'انقر لرؤية النتيجة'
                            : '$_remainingSeconds',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

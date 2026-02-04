// money_bag_button.dart

import 'package:lklk/core/utils/logger.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:lklk/generated/l10n.dart';

class MoneyBagResultDialog extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onDismiss;
  final VoidCallback onOkPressed;

  const MoneyBagResultDialog({
    super.key,
    required this.result,
    required this.onDismiss,
    required this.onOkPressed,
  });

  // دالة جديدة لتحليل رسالة النتيجة
  // دالة لتحليل الرسالة
  List<Map<String, String>> _parseResultMessage(String message) {
    final List<Map<String, String>> results = [];

    try {
      // الرسالة ممكن تكون أكثر من سطر أو أكثر من نتيجة
      final lines = message.split('\n');

      for (final line in lines) {
        if (line.contains('name:') && line.contains('/coin:')) {
          final nameStart = line.indexOf('name:') + 5; // بعد "name:"
          final coinIndex = line.indexOf('/coin:');

          if (nameStart >= 0 && coinIndex > nameStart) {
            final userName = line.substring(nameStart, coinIndex).trim();
            final coinAmount =
                line.substring(coinIndex + 6).trim(); // بعد "/coin:"

            if (userName.isNotEmpty && coinAmount.isNotEmpty) {
              results.add({
                'name': userName,
                'coins': coinAmount,
              });
            }
          }
        }
      }
    } catch (e) {
      log('Error parsing result message: $e');
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    String rawMessage = result['message'] ?? 'لا توجد معلومات';
    final giftSender = result['gift_sender'] ?? 'مستخدم مجهول';
    final userImage = result['img'] as String?;

    // تحليل رسالة النتيجة
    final parsedResults = _parseResultMessage(rawMessage);

    DateTime toDateTime(dynamic timestampValue) {
      if (timestampValue == null) return DateTime.now();
      if (timestampValue is int) {
        if (timestampValue > 9999999999) {
          return DateTime.fromMillisecondsSinceEpoch(timestampValue);
        } else {
          return DateTime.fromMillisecondsSinceEpoch(timestampValue * 1000);
        }
      } else if (timestampValue is String) {
        final intValue = int.tryParse(timestampValue) ?? 0;
        if (intValue > 9999999999) {
          return DateTime.fromMillisecondsSinceEpoch(intValue);
        } else {
          return DateTime.fromMillisecondsSinceEpoch(intValue * 1000);
        }
      }
      return DateTime.now();
    }

    DateTime timestamp = toDateTime(result['timestamp'] ?? result['createdAt']);
    try {
      final timestampValue = result['timestamp'];
      if (timestampValue is int) {
        timestamp = DateTime.fromMillisecondsSinceEpoch(timestampValue * 1000);
      } else if (timestampValue is String) {
        final intValue = int.tryParse(timestampValue) ?? 0;
        timestamp = DateTime.fromMillisecondsSinceEpoch(intValue * 1000);
      } else {
        timestamp = DateTime.now();
      }
    } catch (e) {
      timestamp = DateTime.now();
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Container(
            width: 320, // زيادة العرض قليلاً لتحسين التخطيط
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB71C1C),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '🎁 نتيجة حقيبة الحظ 🎁 ',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
                                  size: 30, color: Colors.white),
                        ),
                        Text(
                          'من: $giftSender',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height:
                                140, // زيادة الارتفاع لاستيعاب المزيد من المستخدمين
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(AssetsData.bagResultBG),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: parsedResults.isNotEmpty
                                ? ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: parsedResults.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(
                                      color: Color(0xFFB71C1C),
                                      height: 8,
                                      thickness: 0.5,
                                    ),
                                    itemBuilder: (context, index) {
                                      final resultItem = parsedResults[index];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // 👇 الكوينز على اليمين
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Text(
                                                        resultItem['coins'] ??
                                                            '',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          foreground: Paint()
                                                            ..style =
                                                                PaintingStyle
                                                                    .stroke
                                                            ..strokeWidth = 1.3
                                                            ..color =
                                                                Colors.black,
                                                        ),
                                                      ),
                                                      AutoSizeText(
                                                        resultItem['coins'] ??
                                                            '',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              AppColors.golden,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Image.asset(
                                                    AssetsData.coins,
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 10),

                                            // 👇 الاسم على اليسار
                                            Expanded(
                                              flex: 2,
                                              child: AutoSizeText(
                                                resultItem['name'] ?? '',
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFB71C1C),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text(
                                      rawMessage,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB71C1C),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: onOkPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFD32F2F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                          child: Text(
                            S.of(context).ok,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onDismiss,
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

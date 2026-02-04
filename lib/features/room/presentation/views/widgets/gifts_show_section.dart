import 'dart:convert';
import 'dart:async';
import 'package:lklk/core/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/features/home/presentation/manger/gifts_show_cubit/gifts_show_cubit.dart';
import 'package:lklk/features/room/domain/entities/gift_entity.dart';
import 'package:lklk/zego_sdk_manager.dart';
import 'package:lklk/core/room_visibility_manager.dart';

class GiftsShowSection extends StatefulWidget {
  const GiftsShowSection({super.key});

  @override
  State<GiftsShowSection> createState() => _GiftsShowSectionState();
}

class _GiftsShowSectionState extends State<GiftsShowSection> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    // كود استلام الهديا
    final giftsShowCubit = context.read<GiftsShowCubit>();
    _subscription = ZEGOSDKManager()
        .zimService
        .onRoomMessageReceivedStreamCtrl
        .stream
        .listen((messageList) {
      for (var message in messageList) {
        String? messageContent;
        if (message is ZIMBarrageMessage) {
          messageContent = message.message;
        }

        if (messageContent == null) continue;

        // ✅ تجاهل أي رسالة مش JSON
        if (!_isValidJson(messageContent)) {
          log("⚠️ Ignored non-JSON message in GiftsShowSection: $messageContent");
          continue;
        }

        final data = jsonDecode(messageContent);

        // ✅ تجاهل أي رسالة مش هدية
        if (data is! Map || data['Message'] == null) {
          log("⚠️ Ignored message without 'Message' key: $data");
          continue;
        }

        if (data['Message']['operationType'] != 20001) {
          log("⚠️ Ignored non-gift message with operationType=${data['Message']['operationType']}");
          continue;
        }

        // 🎁 من هون يبدأ منطق الهدية
        final dynamic gifts = data['Message']['data']['gifts'];
        if (gifts != null) {
          for (var gift in gifts) {
            try {
              final giftEntity = GiftEntity.fromMap(gift);

              // منع إعادة عرض الهدايا التي وصلَت أثناء التصغير: فلترة حسب آخر وقت استئناف للغرفة الحالية
              final lastResumeMs = RoomVisibilityManager().currentRoomLastResumeAtMs;
              int giftTsMs = giftEntity.timestamp; // server timestamp, may be sec or ms
              if (giftTsMs > 0 && giftTsMs < 1000000000000) {
                // looks like seconds -> convert to ms
                giftTsMs = giftTsMs * 1000;
              }
              final shouldShow = lastResumeMs <= 0 || giftTsMs >= lastResumeMs;

              if (!shouldShow) {
                log('⏭️ Skipping gift received while minimized (ts=$giftTsMs < resume=$lastResumeMs)');
                continue;
              }

              // مرر جميع الأنواع إلى GiftsShowCubit (Lucky سيتم التقاطها في giftImageBloc)
              giftsShowCubit.showGiftAnimation(
                giftEntity,
                data['Message']['targetID']?.cast<String>() ?? [],
              );
            } catch (e) {
              log('❌ Error converting gift: $e');
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  bool _isValidJson(String str) {
    try {
      jsonDecode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;
    final double w = MediaQuery.of(context).size.width;

    return BlocConsumer<GiftsShowCubit, GiftsShowState>(
      buildWhen: (previous, current) {
        if (current is GiftShow) {
          final gt = current.giftEntity.giftType.toLowerCase();
          final isLucky = gt.contains('lucky') ||
              current.giftEntity.giftType.contains('حظ');
          // لا تعِد بناء الواجهة لرسائل lucky حتى لا تقطع عرض SVGA للأنواع الأخرى
          return !isLucky;
        }
        return true;
      },
      listener: (context, state) {
        if (state is GiftShow) {
          log("🎯 BlocConsumer listener GiftShow triggered");
        }
      },
      builder: (context, state) {
        if (state is GiftShow) {
          final String? actualLink = state.giftEntity.link;
          final String gt = state.giftEntity.giftType.toLowerCase();
          final bool isEntry = gt == 'entry' || gt.contains('entry');
          return FutureBuilder<String?>(
            future: (() async {
              // Delay start ~1s for entry only to avoid quick restart (network → local switch)
              if (isEntry) {
                await Future.delayed(const Duration(milliseconds: 600));
              }
              return await SvgaUtils.getValidFilePathWithDownload(
                state.giftEntity.giftId.toString(),
                downloadUrl: actualLink,
              );
            })(),
            builder: (context, snapshot) {
              // Show nothing during the delay/loading period to avoid double start
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox();
              }

              // الحصول على المسار النهائي مع معالجة القيم الفارغة
              final filePath = snapshot.data;

              if (filePath != null && filePath.isNotEmpty) {
                return SizedBox(
                  child: CustomSVGAWidget(
                    height: h,
                    width: w,
                    pathOfSvgaFile: filePath,
                    allowDrawingOverflow: false,
                    clearsAfterStop: true,
                    fit: BoxFit.fitWidth,
                  ),
                );
              } else {
                if (actualLink != null && actualLink.isNotEmpty) {
                  return SizedBox(
                    child: CustomSVGAWidget(
                      height: h,
                      width: w,
                      pathOfSvgaFile: actualLink,
                      allowDrawingOverflow: false,
                      clearsAfterStop: true,
                      fit: BoxFit.fitWidth,
                      // For entry: play exactly once; don't repeat by timer
                      durationSeconds: isEntry
                          ? null
                          : ((state.giftEntity.timer > 0)
                              ? state.giftEntity.timer
                              : null),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              }
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}

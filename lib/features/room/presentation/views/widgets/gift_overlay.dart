import 'dart:developer' as dev;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/gifts_show_cubit/gifts_show_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/gift_animation_data.dart';
import 'package:lklk/features/room/presentation/views/widgets/seat_position_manager.dart';
import 'package:lklk/live_audio_room_manager.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/core/room_visibility_manager.dart';

class GiftOverlay extends StatefulWidget {
  const GiftOverlay({
    super.key,
    required this.enabled,
    required this.room,
    required this.gridHeight,
  });

  final bool enabled;
  final RoomEntity room;
  final double gridHeight;

  @override
  State<GiftOverlay> createState() => _GiftOverlayState();
}

class _GiftOverlayState extends State<GiftOverlay> {
  final List<GiftAnimationData> _activeGifts = <GiftAnimationData>[];
  // تم إزالة نظام الرتل الداخلي: جميع الهدايا تُعرض مباشرة فوق بعضها (Stack)
  // منع التكرار اللحظي لنفس الحدث (عند انبعاث الحالة مرتين سريعاً)
  final Set<String> _recentEventKeys = <String>{};
  final Map<String, Timer> _recentKeyTimers = <String, Timer>{};

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      // لا تشغل أنيميشن عندما تكون معطلة (TickerMode أيضاً يُطبّق خارجياً)
      return const SizedBox.shrink();
    }

    return BlocListener<GiftsShowCubit, GiftsShowState>(
      listener: (context, state) async {
        if (!mounted || !widget.enabled) return;
        if (state is! GiftShow) return;

        final giftsMany = state.giftEntity.giftCount.toString();
        final giftSender = state.giftEntity.userId.toString();
        String? seatImageUrl = state.giftEntity.imgGift?.toString();
        final link = state.giftEntity.link?.toString();

        if ((seatImageUrl == null || seatImageUrl.isEmpty) &&
            _looksLikeImageUrl(link)) {
          final normalized = _normalizeGiftUrl(link!);
          if (normalized != null) seatImageUrl = normalized;
        }

        if (seatImageUrl == null || giftsMany == "0") {
          _log('Invalid gift data, skipping', {
            'giftImage': seatImageUrl,
            'link': link,
            'giftsMany': giftsMany,
          });
          return;
        }

        // خريطة userId -> seatIndex لمرة واحدة
        final seatList = ZegoLiveAudioRoomManager().seatList;
        final Map<String, int> userIdToSeatIndex = {};
        for (final sItem in seatList) {
          final u = sItem.currentUser.value;
          if (u != null) {
            userIdToSeatIndex[u.iduser.toString()] = sItem.seatIndex;
          }
        }

        // المرسل
        final senderSeatIndex = userIdToSeatIndex[giftSender];
        // نقطة الوسط والصورة الكبيرة: أسفل شبكة المقاعد مباشرة (حسب عدد المايكات)
        final centerOffset = _calculateCenterOffset(context);
        // إذا لم يكن المرسل على المايك، ابدأ من المركز
        bool startFromCenterIfSenderMissing = false;
        late final Offset senderOffset;
        if (senderSeatIndex == null) {
          startFromCenterIfSenderMissing = true;
          senderOffset = centerOffset;
          _log('Sender seat not found; starting from center',
              {'senderId': giftSender});
        } else {
          senderOffset = _calculateSeatPosition(
            context: context,
            seatIndex: senderSeatIndex,
            gridHeight: widget.gridHeight,
          );
        }

        _log('🎯 CENTER: Calculated center position', {
          'microphoneNumber': widget.room.microphoneNumber,
          'centerOffset': centerOffset.toString(),
          'gridHeight': _calculateGridHeight(widget.room.microphoneNumber),
        });

        // قطر الصورة المركزية: أكبر قليلاً من فقاعة الحركة (50)، لكن مقيد
        const double movingDiameter = 50.0;
        const int columns = 5;
        final media = MediaQuery.of(context);
        final seatWidth = media.size.width / columns;
        final double centerDiameter =
            (seatWidth * 0.9).clamp(movingDiameter, 120.0);

        // استخرج المستلمين الفعليين بدون تكرار
        final Set<String> recipientSet = <String>{};
        if (state.usersID.isNotEmpty) {
          for (final raw in state.usersID) {
            // دعم كلا الفاصلين: التطويل العربي 'ـ' والشرطة السفلية '_'
            final parts = raw.split(RegExp(r"[ـ_]+"));
            for (final id in parts) {
              if (id.isNotEmpty) recipientSet.add(id);
            }
          }
        } else {
          // كل المقاعد المشغولة
          recipientSet.addAll(userIdToSeatIndex.keys);
        }

        _log('👥 Recipients parsed', {
          'raw': state.usersID,
          'parsedCount': recipientSet.length,
          'parsed': recipientSet.toList(),
        });

        // تدفئة كاش الصور في الدُفعات الكبيرة
        if (recipientSet.length >= 6) {
          try {
            precacheImage(NetworkImage(seatImageUrl), context);
          } catch (_) {}
        }

        // معرف دقيق للهدية مع timestamp الصحيح من الخادم
        final giftId = state.giftEntity.giftId.toString();
        final giftType = state.giftEntity.giftType.toString();
        final giftPoints = state.giftEntity.giftPoints.toString();
        final giftTimestamp = state.giftEntity.timestamp;
        // استخدام timestamp الخادم، أو الوقت الحالي كـ fallback
        final currentTime = giftTimestamp > 0
            ? giftTimestamp
            : DateTime.now().millisecondsSinceEpoch;

        // فلترة الهدايا الأقدم من آخر وقت استئناف للغرفة الحالية
        final lastResumeMs = RoomVisibilityManager().currentRoomLastResumeAtMs;
        if (lastResumeMs > 0 &&
            giftTimestamp > 0 &&
            giftTimestamp < lastResumeMs) {
          _log('⏭️ Overlay skip: gift ts older than resume', {
            'giftTs': giftTimestamp,
            'resume': lastResumeMs,
          });
          return;
        }

        // معرف أساسي للهدية (بدون timestamp)
        final baseKey =
            '${giftId}_${giftType}_${giftSender}_${recipientSet.join('_')}_${giftsMany}_$giftPoints';

        _log('🎁 OVERLAY: Gift event received', {
          'giftId': giftId,
          'type': giftType,
          'sender': giftSender,
          'count': giftsMany,
          'points': giftPoints,
          'recipients': recipientSet.length,
          'baseKey': baseKey,
          'serverTimestamp': giftTimestamp,
          'usedTimestamp': currentTime,
          'timestampSource': giftTimestamp > 0 ? 'server' : 'local',
        });

        // فحص التكرار اللحظي (نفس الهدية في نفس 200ms)
        bool isDuplicate = false;
        String? duplicateKey;

        for (final existingKey in _recentEventKeys) {
          if (existingKey.startsWith(baseKey)) {
            // استخراج timestamp من المفتاح الموجود
            final parts = existingKey.split('_ts_');
            if (parts.length == 2) {
              final existingTime = int.tryParse(parts[1]) ?? 0;
              final timeDiff = currentTime - existingTime;

              // إذا كان الفرق أقل من 200ms، اعتبرها مكررة
              if (timeDiff < 200) {
                isDuplicate = true;
                duplicateKey = existingKey;
                break;
              }
            }
          }
        }

        if (isDuplicate) {
          _log('🚫 BLOCKED: Duplicate gift detected (within 200ms)', {
            'baseKey': baseKey,
            'duplicateKey': duplicateKey,
            'recentCount': _recentEventKeys.length,
          });
          return;
        }

        // إنشاء مفتاح فريد مع timestamp
        final uniqueKey = '${baseKey}_ts_$currentTime';
        _recentEventKeys.add(uniqueKey);

        _log('✅ NEW: Gift added to overlay processed list', {
          'uniqueKey': uniqueKey,
          'recentCount': _recentEventKeys.length,
        });

        // حرر المفتاح بعد 2 ثانية (نافذة قصيرة لمنع التكرار اللحظي فقط)
        _recentKeyTimers[uniqueKey]?.cancel();
        _recentKeyTimers[uniqueKey] = Timer(const Duration(seconds: 2), () {
          _recentEventKeys.remove(uniqueKey);
          _recentKeyTimers.remove(uniqueKey);
          _log('🧹 CLEANUP: Gift removed from overlay processed list', {
            'uniqueKey': uniqueKey,
            'remainingCount': _recentEventKeys.length,
          });
        });

        // اجمع جميع المستلمين وإزاحاتهم في عنصر واحد لعرض واحد فقط (عداد واحد لكل مرسل)
        final List<String> recipients = recipientSet.toList();
        final List<Offset> recipientOffsets = <Offset>[];
        for (final userId in recipients) {
          // أولوية: الحصول على موضع المستخدم الفعلي من SeatPositionManager
          final actualPos = SeatPositionManager().getUserPosition(userId);
          if (actualPos != null) {
            _log('📌 Using SeatPositionManager for recipient', {
              'userId': userId,
              'position': actualPos.toString(),
            });
            // خفّض الهدف 40px للأسفل لتحسين محاذاة الاصطدام مع أسفل المايك
            recipientOffsets.add(actualPos + const Offset(0, 40));
            continue;
          }

          // fallback 1: حسب فهرس المقعد
          final seatIndex = userIdToSeatIndex[userId];
          _log('🎯 Resolving recipient seat', {
            'userId': userId,
            'hasSeat': seatIndex != null,
            if (seatIndex != null) 'seatIndex': seatIndex,
          });
          if (seatIndex != null) {
            final pos = _calculateSeatPosition(
              context: context,
              seatIndex: seatIndex,
              gridHeight: widget.gridHeight,
            );
            // خفّض الهدف 40px للأسفل في حالة الحساب بالفهرس أيضاً
            recipientOffsets.add(pos + const Offset(0, 40));
            continue;
          }

          // fallback 2: بالقرب من المركز مع تشويش بسيط
          final h = userId.hashCode;
          final dx = ((h % 3) - 1) * 30.0; // -30, 0, 30
          final dy = (((h ~/ 3) % 3) - 1) * 20.0; // -20, 0, 20
          // خفّض الهدف 40px للأسفل في حالة fallback قرب المركز
          recipientOffsets
              .add(Offset(centerOffset.dx + dx, centerOffset.dy + dy + 40));
        }

        // استدعاء واحد فقط: يمرر كل المستلمين وإزاحاتهم إلى الودجت
        _addGiftAnimation(
          context: context,
          imageUrl: seatImageUrl,
          targetOffset: recipientOffsets.isNotEmpty
              ? recipientOffsets.first
              : centerOffset,
          senderOffset: senderOffset,
          centerOffset: centerOffset,
          centerDiameter: centerDiameter,
          giftsMany: giftsMany,
          giftTimer: state.giftEntity.timer,
          senderId: giftSender,
          giftType: state.giftEntity.giftType,
          receiverIds: recipients,
          receiverOffsets: recipientOffsets,
          startFromCenterIfSenderMissing: startFromCenterIfSenderMissing,
        );
      },
      child: Stack(
        children: [
          ..._activeGifts.map((giftData) {
            return RepaintBoundary(
              child: GiftAnimationWidget(
                key: ValueKey(giftData),
                giftData: giftData,
                giftId: giftData.hashCode.toString(), // معرف فريد للStack
                onAnimationComplete: () => _onGiftAnimationComplete(giftData),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _addGiftAnimation({
    required BuildContext context,
    required String imageUrl,
    required Offset targetOffset,
    required Offset senderOffset,
    required Offset centerOffset,
    required double centerDiameter,
    String? giftsMany,
    int? giftTimer,
    Duration delay = Duration.zero,
    String? senderId, // معرف المرسل
    String? receiverId, // معرف المستلم
    String? giftType, // نوع الهدية
    List<String>? receiverIds, // قائمة كل المستلمين
    List<Offset>? receiverOffsets, // إزاحات كل المستلمين
    bool startFromCenterIfSenderMissing = false,
  }) {
    _log('ADD gift animation request', {
      'imageUrl': imageUrl,
      'senderOffset': senderOffset.toString(),
      'targetOffset': targetOffset.toString(),
      'centerOffset': centerOffset.toString(),
      'giftTimer': giftTimer,
      'giftsMany': giftsMany,
      'activeCount': _activeGifts.length,
    });
    // احسب العداد العددي الفعلي من giftsMany (افتراضي = 1)
    final int parsedCount = int.tryParse(giftsMany ?? '1') ?? 1;
    final giftData = GiftAnimationData(
      imageUrl: imageUrl,
      targetOffset: targetOffset,
      senderOffset: senderOffset,
      centerOffset: centerOffset,
      centerDiameter: centerDiameter,
      giftsMany: giftsMany,
      count: parsedCount,
      delay: delay,
      microphoneNumber: widget.room.microphoneNumber, // إضافة عدد الميكروفونات
      giftTimer: giftTimer, // مدة الهدية من الخادم
      senderId: senderId, // تمرير معرف المرسل
      receiverId: receiverId, // تمرير معرف المستلم
      giftType: giftType, // نوع الهدية
      receiverIds: receiverIds,
      receiverOffsets: receiverOffsets,
      startFromCenterIfSenderMissing: startFromCenterIfSenderMissing,
    );
    if (!mounted) return;
    setState(() {
      // عرض فوري: إضافة الهدية مباشرة إلى الطبقة، الأحدث تظهر فوق القديمة
      _activeGifts.add(giftData);
      _log('STACK gift', {
        'activeCount': _activeGifts.length,
        'giftTimer': giftTimer,
        'calculatedDuration': giftData.duration.inMilliseconds,
      });
    });
  }

  void _onGiftAnimationComplete(GiftAnimationData completed) {
    if (!mounted) return;
    _log('COMPLETE gift (widget callback)', {
      'activeBefore': _activeGifts.length,
    });
    setState(() {
      _activeGifts.remove(completed);
    });
    _log('STATE after complete', {
      'activeAfter': _activeGifts.length,
    });
  }

  // ignore: unused_element
  void _removeGiftAnimation(GiftAnimationData giftData) {
    if (!mounted) return;
    _log('FORCE REMOVE gift (overlay)', {
      'activeBefore': _activeGifts.length,
    });
    setState(() {
      _activeGifts.remove(giftData);
    });
    _log('STATE after force remove', {
      'activeAfter': _activeGifts.length,
    });
  }

  /// حساب موضع المركز أسفل شبكة المقاعد (حسب عدد المايكات)
  Offset _calculateCenterOffset(BuildContext context) {
    final media = MediaQuery.of(context);
    final statusBar = media.padding.top;
    const infoRowHeight = 60.0; // وفق التقدير المستخدم في RoomViewBody
    final midX = media.size.width / 2;

    // حساب ارتفاع الشبكة حسب عدد المايكات (مطابق لـ RoomViewBody)
    final gridHeight = _calculateGridHeight(widget.room.microphoneNumber);

    final midY = statusBar +
        kToolbarHeight +
        infoRowHeight +
        gridHeight +
        70; // إزاحة لأسفل +20px إضافية
    return Offset(midX, midY);
  }

  /// حساب ارتفاع الشبكة (مطابق تماماً لـ RoomViewBody._calculateGridHeight)
  double _calculateGridHeight(String micNumber) {
    int num = int.parse(micNumber);
    return num == 20
        ? 340.0
        : num == 15
            ? 255.0
            : num == 10
                ? 170.0
                : 170.0; // افتراضي للأعداد الأخرى
  }

  Offset _calculateSeatPosition({
    required BuildContext context,
    required int seatIndex,
    required double gridHeight,
  }) {
    const columns = 5;
    final row = seatIndex ~/ columns;
    final column = seatIndex % columns;

    final screenWidth = MediaQuery.of(context).size.width;
    final seatWidth = screenWidth / columns;
    final rowsCount =
        (int.tryParse(widget.room.microphoneNumber)?.toDouble() ?? 20) /
            columns;
    final seatHeight = gridHeight / rowsCount.ceil();

    final appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    final x = column * seatWidth + (seatWidth / 2) - (25 * 1.2) + 5;
    final y = appBarHeight +
        statusBarHeight +
        (row * seatHeight) +
        (seatHeight / 2) +
        33;

    _log('Seat position', {
      'rowHeight': seatHeight,
      'y': y,
    });
    return Offset(x, y);
  }

  bool _looksLikeImageUrl(String? url) {
    if (url == null) return false;
    final u = url.trim().toLowerCase();
    return u.endsWith('.png') ||
        u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.webp') ||
        u.endsWith('.gif');
  }

  String? _normalizeGiftUrl(String url) {
    final t = url.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    if (t.startsWith('//')) return 'https:$t';
    if (t.startsWith('lklklive.com')) return 'https://$t';
    if (t.startsWith('/')) return 'https://lklklive.com$t';
    return null;
  }

  void _log(String message, [dynamic extra]) {
    assert(() {
      final text = 'GIFT_OVERLAY: $message${extra != null ? ' $extra' : ''}';
      // ignore: avoid_print
      dev.log(text, name: 'GiftOverlay');
      return true;
    }());
  }
}

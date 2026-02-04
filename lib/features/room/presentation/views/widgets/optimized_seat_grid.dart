import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focused_menu_custom/focused_menu.dart';
import 'package:focused_menu_custom/modals.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/optimized_seat_item_view.dart';
import 'package:lklk/live_audio_room_manager.dart';
import 'managers/audio_manager.dart';
// INVITE_FREEZE: imports below were used for invite-to-mic feature in optimized grid
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'users_bottomsheet.dart';
// import '../../services/mic_invite_service.dart';

/// شبكة مقاعد محسّنة للأداء العالي
/// - استخدام ListView.builder بدلاً من Wrap لتحسين الأداء
/// - تجميع المقاعد في صفوف لتقليل عدد العناصر المبنية
/// - تحسين إدارة الذاكرة والتخزين المؤقت
class OptimizedSeatGrid extends StatefulWidget {
  const OptimizedSeatGrid({
    super.key,
    required this.seatList,
    required this.roomCubit,
    required this.userCubit,
    required this.room,
    required this.role,
    required this.onSend,
    required this.isApplyStateNotifier,
    required this.audioManager,
  });

  final List<dynamic> seatList;
  final RoomCubit roomCubit;
  final UserCubit userCubit;
  final RoomEntity room;
  final ZegoLiveAudioRoomRole role;
  final void Function(ZIMMessage) onSend;
  final ValueNotifier<bool> isApplyStateNotifier;
  final AudioManager audioManager;

  @override
  State<OptimizedSeatGrid> createState() => _OptimizedSeatGridState();
}

class _OptimizedSeatGridState extends State<OptimizedSeatGrid> {
  // لا تحسب أبعاد الشبكة في initState لتجنّب MediaQuery قبل الاكتمال
  // استخدم LayoutBuilder داخل build للحساب ديناميكياً وبأمان

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final seatWidth = 72.w + 8.w; // عرض المقعد + هامش
        final columnsPerRow = (screenWidth / seatWidth).floor().clamp(1, 6);
        final totalSeats = widget.seatList.length;
        final totalRows = (totalSeats / columnsPerRow).ceil();

        return SizedBox(
          width: screenWidth,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalRows,
            itemBuilder: (context, rowIndex) {
              return _buildSeatRow(rowIndex, columnsPerRow, totalSeats);
            },
          ),
        );
      },
    );
  }

  Widget _buildSeatRow(int rowIndex, int columnsPerRow, int totalSeats) {
    final startIndex = rowIndex * columnsPerRow;
    final endIndex = (startIndex + columnsPerRow).clamp(0, totalSeats);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(endIndex - startIndex, (columnIndex) {
          final seatIndex = startIndex + columnIndex;
          return _buildOptimizedSeatItem(seatIndex);
        }),
      ),
    );
  }

  Widget _buildOptimizedSeatItem(int seatIndex) {
    if (seatIndex >= widget.seatList.length) {
      return SizedBox(width: 72.w, height: 90.h);
    }

    return RepaintBoundary(
      child: ValueListenableBuilder<Map<String, Map<String, bool>>>(
        valueListenable: ZegoLiveAudioRoomManager().lockedSeatsPerRoomNotifier,
        builder: (context, lockedSeatsPerRoom, _) {
          final lockedSeats =
              lockedSeatsPerRoom[widget.room.id.toString()] ?? {};
          final isLocked = lockedSeats[seatIndex.toString()] ?? false;

          return ValueListenableBuilder<UserEntity?>(
            valueListenable:
                ZegoLiveAudioRoomManager().seatList[seatIndex].currentUser,
            builder: (context, user, _) {
              // الحصول على مستوى الصوت من AudioManager
              final soundLevel = widget.audioManager.getSoundLevelForUser(
                user?.iduser ?? '',
              );

              final seatWidget = OptimizedZegoSeatItemView(
                roomCubit: widget.roomCubit,
                userCubit: widget.userCubit,
                micNum: widget.seatList.length,
                indexmic: seatIndex,
                seatIndex: seatIndex,
                roomId: widget.room.id.toString(),
                soundLevel: ValueNotifier<double>(soundLevel),
              );

              // عرض القائمة المنسدلة فقط للمضيف
              if (widget.role == ZegoLiveAudioRoomRole.host) {
                return FocusedMenuHolder(
                  menuWidth: 110,
                  blurSize: 5,
                  menuItemExtent: 38,
                  duration: const Duration(milliseconds: 300),
                  animateMenuItems: true,
                  blurBackgroundColor: Colors.transparent,
                  menuOffset: 2,
                  bottomOffsetHeight: 20,
                  enableMenuScroll: false,
                  menuItems: _getOptimizedMenuItems(seatIndex, isLocked, user),
                  onPressed: () {},
                  child: seatWidget,
                );
              }

              return seatWidget;
            },
          );
        },
      ),
    );
  }

  /// قائمة مبسطة من عناصر القائمة لتحسين الأداء
  List<FocusedMenuItem> _getOptimizedMenuItems(
      int seatIndex, bool isLocked, UserEntity? user) {
    // تبسيط القائمة لتحسين الأداء
    if (user != null) {
      return [
        FocusedMenuItem(
          title: Text("طرد من المقعد"),
          onPressed: () => _kickFromSeat(seatIndex),
        ),
      ];
    } else {
      // Original behavior (before invite feature): only lock/unlock for empty seats
      return [
        FocusedMenuItem(
          title: Text(isLocked ? "إلغاء القفل" : "قفل المقعد"),
          onPressed: () => _toggleSeatLock(seatIndex, isLocked),
        ),
      ];
    }
  }

  void _kickFromSeat(int seatIndex) {
    // تنفيذ طرد المستخدم من المقعد
    ZegoLiveAudioRoomManager().leaveSeat(seatIndex);
  }

  void _toggleSeatLock(int seatIndex, bool isCurrentlyLocked) {
    // تبديل حالة قفل المقعد بشكل فردي للمقعد المحدد
    ZegoLiveAudioRoomManager()
        .lockSpecificSeat(seatIndex, widget.room.id.toString());
  }
}

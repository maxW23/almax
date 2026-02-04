import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_messages_cubit/room_messages_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/dice_send_section.dart';
import 'package:lklk/features/room/presentation/views/widgets/lucky_bag_btn.dart';
import 'package:lklk/features/room/presentation/views/widgets/mute_room.dart';
import 'package:lklk/features/room/presentation/views/widgets/player_room.dart';
import 'package:lklk/features/room/presentation/views/widgets/show_hide_gifts_switch.dart';
import 'package:lklk/features/room/presentation/views/widgets/topbar_switch.dart';
import 'package:lklk/features/room/presentation/views/widgets/trash_icon_deletechat.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/internal/business/business_define.dart';

class MoreDetailsRoomBottomSheet extends StatefulWidget {
  const MoreDetailsRoomBottomSheet(
      {super.key,
      required this.roomId,
      required this.deleteAllMessages,
      required this.role,
      required this.addDeleteAllMessagesMessage,
      required this.userID,
      this.fromOverlay});
  final int roomId;
  final void Function() deleteAllMessages;
  final ZegoLiveAudioRoomRole role;
  final void Function() addDeleteAllMessagesMessage;
  final String userID;
  final bool? fromOverlay;
  static Future<void> show(
      BuildContext context,
      int roomId,
      void Function() deleteAllMessages,
      ZegoLiveAudioRoomRole role,
      void Function() addDeleteAllMessagesMessage,
      String userID,
      {bool? fromOverlay}) async {
    final cubit = BlocProvider.of<RoomMessagesCubit>(context, listen: false);

    await showModalBottomSheet(
      // backgroundColor: Colors.transparent,
      isScrollControlled: true,
      backgroundColor: AppColors.darkColor,
      barrierColor: Colors.transparent,

      context: context,
      builder: (BuildContext context) => BlocProvider.value(
        value: cubit,
        child: MoreDetailsRoomBottomSheet(
          roomId: roomId,
          deleteAllMessages: deleteAllMessages,
          role: role,
          addDeleteAllMessagesMessage: addDeleteAllMessagesMessage,
          userID: userID,
          fromOverlay: fromOverlay,
        ),
      ),
    );
  }

  @override
  State<MoreDetailsRoomBottomSheet> createState() =>
      _MoreDetailsRoomBottomSheetState();
}

class _MoreDetailsRoomBottomSheetState
    extends State<MoreDetailsRoomBottomSheet> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    final languageCubit = context.read<LanguageCubit>();
    _selectedLanguage = languageCubit.state.languageCode;
  }

  // يبني عنصر مع عرض وارتفاع ثابتين للمحاذاة الاحترافية داخل Wrap
  Widget _buildTile(
      {required double width, required double height, required Widget child}) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.52;
    // عرض البلاط الموحد: 3 أعمدة مع تباعد 12 وبادينغ أفقي 16
    final double availableWidth = MediaQuery.of(context).size.width - 32;
    const double spacing = 12;
    const double tileScale =
        1; // تقليل مساحة البلاط نفسه مع الحفاظ على المحاذاة
    final double baseTile = (availableWidth - (spacing * 2)) / 3;
    final double tileWidth = baseTile * tileScale;
    final double tileHeight = tileWidth; // مربعات متساوية لصفوف متناسقة
    const double iconScale =
        0.5; // لم يعد مستخدماً لحجم الأيقونات، سنستخدم 70x70 ثابت
    return Directionality(
      textDirection: getTextDirection(_selectedLanguage),
      child: Container(
        height: sheetHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.darkColor,
          // gradient: LinearGradient(
          //   colors: [Colors.deepPurpleAccent, Colors.pinkAccent],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white38,
              blurRadius: 10,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: SingleChildScrollView(
          // <-- Added scrollable container
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min, // <-- Use minimal vertical space
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // سطر صغير للتلميح على إمكانية السحب
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              // عنوان مميز
              AutoSizeText(
                S.of(context).moreDetails,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // شبكة موحدة (3 أعمدة × 2 صفوف) لستة عناصر بنفس الحجم والاستقامة
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.center,
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  // الصف الأول
                  _buildTile(
                    width: tileWidth,
                    height: tileHeight,
                    child: SizedBox.square(
                      dimension: 45,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SeventySendSection(roomId: widget.roomId),
                      ),
                    ),
                  ),
                  _buildTile(
                    width: tileWidth,
                    height: tileHeight,
                    child: SizedBox.square(
                      dimension: 45,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: DiceSendSection(roomId: widget.roomId),
                      ),
                    ),
                  ),
                  _buildTile(
                    width: tileWidth,
                    height: tileHeight,
                    child: SizedBox.square(
                      dimension: 45,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: PsrSendSection(roomId: widget.roomId),
                      ),
                    ),
                  ),
                  // الصف الثاني
                  _buildTile(
                    width: tileWidth,
                    height: tileHeight,
                    child: SizedBox.square(
                      dimension: 45,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: LuckyBagBtn(roomID: widget.roomId.toString()),
                      ),
                    ),
                  ),
                  _buildTile(
                    width: tileWidth,
                    height: tileHeight,
                    child: SizedBox.square(
                      dimension: 45,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: TrashIconDeletechat(
                          roomID: widget.roomId.toString(),
                          deleteAllMessages: widget.deleteAllMessages,
                          addDeleteAllMessagesMessage:
                              widget.addDeleteAllMessagesMessage,
                          role: widget.role,
                        ),
                      ),
                    ),
                  ),
                  _buildTile(
                    width: tileWidth,
                    height: tileHeight,
                    child: RepaintBoundary(
                      child: PlayerRoom(
                        fromOverlay: true,
                        miniButtonSize: 45,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // عناصر الواجهة
              const ShowHideGiftsSwitch(),
              const SizedBox(height: 20),

              ShowHideTopBarSwitch(),
              const SizedBox(height: 20),
              const MuteRoomButton(),
              const SizedBox(height: 20),

              // رسالة تحفيزية أو ترويجية
              AutoSizeText(
                S.of(context).enjoyWithFun,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20), // <-- Added bottom buffer
            ],
          ),
        ),
      ),
    );
  }
}

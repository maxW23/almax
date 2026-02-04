import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/home/presentation/views/widgets/room_grid_title_item.dart';
import 'package:lklk/features/home/presentation/views/widgets/room_list_title_item.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/widgets/overlay/defines.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/manger/rooms_cubit/rooms_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_manager.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/password_input_dialog.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:x_overlay/x_overlay.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoomItemWidgetTitlesContainer extends StatefulWidget {
  const RoomItemWidgetTitlesContainer({
    super.key,
    required this.room,
    required this.roomCubit,
    required this.userCubit,
    this.isList = false,
  });

  final RoomEntity room;
  final RoomCubit roomCubit;
  final UserCubit userCubit;
  final bool isList;

  @override
  State<RoomItemWidgetTitlesContainer> createState() =>
      _RoomItemWidgetTitlesContainerState();
}

class _RoomItemWidgetTitlesContainerState
    extends State<RoomItemWidgetTitlesContainer>
    with AutomaticKeepAliveClientMixin {
  bool _isProcessing = false;
  String _selectedLanguage = 'en';
  @override
  void initState() {
    super.initState();
    // Load current language from cubit
    final languageCubit = context.read<LanguageCubit>();
    _selectedLanguage = languageCubit.state.languageCode;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // double h = MediaQuery.of(context).size.height;
    // double w = MediaQuery.of(context).size.width;

    return RepaintBoundary(
      child: GestureDetector(
        child: Container(
          child: Directionality(
            textDirection: getTextDirection(_selectedLanguage),
            child: widget.isList
                ? RoomListTitleItem(widget: widget)
                : RoomGridTitleItem(widget: widget),
          ),
        ),
        onTap: () async {
          if (_isProcessing) return;
          _isProcessing = true;

          String? pass;
          log('room pass : ${widget.room.pass}');

          // Request microphone permission first
          if (await requestMicrophonePermission()) {
            if (XOverlayPageState.overlaying ==
                audioRoomOverlayController.pageStateNotifier.value) {
              // overlay: in overlaying, restore content page directly
              audioRoomOverlayController.restore(context,
                  //  widget.userCubit,
                  //  widget.roomCubit,
                  withSafeArea: false);
              // Refresh rooms silently to update dynamic counters (e.g., fire)
              // Useful when user minimises/returns from overlay frequently
              _refreshRoomsSilently(context);
            } else if (widget.room.pass == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) => RoomViewBloc(
                      roomCubit: widget.roomCubit,
                      roomId: widget.room.id,
                      pass: null,
                      userCubit: widget.userCubit,
                      backgroundImage: widget.room.background,
                      isForce: true,
                      // initialRoom: widget.room,
                    ),
                  ),
                ).then((_) {
                  if (mounted) _refreshRoomsSilently(context);
                });
                _isProcessing = false; // Reset processing after navigation
              });
            } else {
              pass = await showDialog<String>(
                context: context,
                builder: (context) => const PasswordSetupDialog(),
              );

              if (pass == widget.room.pass && pass != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      pageBuilder: (_, __, ___) => RoomViewBloc(
                        roomCubit: widget.roomCubit,
                        roomId: widget.room.id,
                        pass: pass,
                        userCubit: widget.userCubit,
                        backgroundImage: widget.room.background,
                        isForce: true,
                        // initialRoom: widget.room,
                      ),
                    ),
                  ).then((_) {
                    if (mounted) _refreshRoomsSilently(context);
                  });
                  _isProcessing = false; // Reset processing after navigation
                });
              } else {
                SnackbarHelper.showMessage(
                  context,
                  S.of(context).thePasswordIsWrong,
                );
                _isProcessing = false; // Reset after showing SnackBar
              }
            }
          } else {
            SnackbarHelper.showMessage(
              context,
              S.of(context).microphonePermissionIsRequired,
            );

            _isProcessing = false; // Reset after showing SnackBar
          }
        },
      ),
    );
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> _refreshRoomsSilently(BuildContext context) async {
    try {
      final roomsCubit = context.read<RoomsCubit>();
      final newRooms =
          await roomsCubit.fetchRooms(1, "RoomItemWidgetTitlesContainer return refresh");
      final manager = RoomManager();
      manager.allRooms
        ..clear()
        ..addAll(newRooms.where((r) => r != null).cast<RoomEntity>());
    } catch (_) {
      // ignore refresh errors silently
    }
  }
}

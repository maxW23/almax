import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/home_view.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/background_image.dart';
import 'package:lklk/live_audio_room_manager.dart';
import 'package:lklk/zego_sdk_manager.dart';
import 'package:lklk/core/room_switch_guard.dart';
import 'package:lklk/core/cache/room_details_cache_manager.dart';

class RoomViewBloc extends StatefulWidget {
  const RoomViewBloc({
    super.key,
    required this.roomId,
    required this.roomCubit,
    this.pass,
    required this.userCubit,
    this.fromOverlay,
    this.backgroundImage,
    required this.isForce,
  });

  final int roomId;
  final String? pass;
  final RoomCubit roomCubit;
  final UserCubit userCubit;
  final bool? fromOverlay;
  final bool isForce;
  final String? backgroundImage;

  @override
  State<RoomViewBloc> createState() => _RoomViewBlocState();
}

class _RoomViewBlocState extends State<RoomViewBloc> {
  late BuildContext pageContext;
  UserEntity? _userAuth;
  bool _isUserLoaded = false;
  bool _isNavigating = false;
  RoomCubitState? _cachedState;
  bool _showRoomView = false;
  ZegoLiveAudioRoomRole? _resolvedRole;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache background after first frame to avoid delaying the initial paint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bg = _cachedState?.room?.background ?? widget.backgroundImage;
      if (bg != null && bg.isNotEmpty && mounted) {
        precacheImage(NetworkImage(bg), context);
      }
    });
  }

  Future<void> _initialize() async {
    if (!(widget.fromOverlay ?? false)) {
      // Always clear previous room (streams + seats) first to avoid stale audio/seat UI
      await ZegoLiveAudioRoomManager().logoutRoom();

      // Try prefilling from per-room cache (only if same roomId)
      try {
        final details = await RoomDetailsCacheManager.instance
            .getCachedDetails(widget.roomId);
        if (details?.room.id == widget.roomId && mounted) {
          setState(() {
            _cachedState = RoomCubitState(
              status: RoomCubitStatus.roomLoaded,
              room: details!.room,
              usersServer: details.users,
              adminsListUsers: details.admins,
              bannedUsers: details.banned,
              topUsers: details.top,
            );
            // Do NOT set _showRoomView here; wait for fresh RoomCubit load to avoid stale UI
          });
        }
      } catch (_) {}

      // Reset cubit state to avoid mixing previous room lists
      widget.roomCubit.backInitial();
      widget.roomCubit.fetchRoomById(widget.roomId, widget.pass);
      if (widget.isForce) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          BlocProvider.of<RoomCubit>(pageContext).backInitial();
        });
      }
    } else {
      // Overlay restore: prefer using live cubit state only if it belongs to the same room
      final liveState = widget.roomCubit.state;
      if (liveState.room?.id == widget.roomId) {
        _cachedState = liveState;
      } else {
        // fallback to persisted cache for this room id
        try {
          final details = await RoomDetailsCacheManager.instance
              .getCachedDetails(widget.roomId);
          if (details != null) {
            _cachedState = RoomCubitState(
              status: RoomCubitStatus.roomLoaded,
              room: details.room,
              usersServer: details.users,
              adminsListUsers: details.admins,
              bannedUsers: details.banned,
              topUsers: details.top,
            );
          }
        } catch (_) {}
      }
      if (_cachedState?.room != null && mounted) {
        setState(() {
          _showRoomView = true;
        });
      }
      // Non-blocking refresh to keep data up-to-date
      widget.roomCubit.fetchRoomById(widget.roomId, widget.pass);
    }

    await _loadUser();
  }

  Future<void> _loadUser() async {
    _userAuth = widget.userCubit.user;
    log("----role---- ${_userAuth.toString()}  --- ");

    if (mounted) {
      setState(() {
        _isUserLoaded = true;
      });
      _tryNavigateIfReady();
    }
  }

  void _tryNavigateIfReady() {
    if (_isNavigating || !_isUserLoaded) return;

    // For non-overlay: require a fresh RoomCubit load for this room
    if (!(widget.fromOverlay ?? false)) {
      final freshState = widget.roomCubit.state;
      final bool freshForThisRoom =
          freshState.room?.id == widget.roomId && freshState.status.isRoomLoaded;
      if (!freshForThisRoom) return;
      _cachedState = freshState;
    } else {
      // For overlay: ensure cached state matches this room
      if (_cachedState?.room?.id != widget.roomId || _cachedState?.room == null) {
        return;
      }
    }

    final role = _determineUserRole(_cachedState!);
    log("----role---- $role  --- ${widget.roomId} ");
    setState(() {
      _resolvedRole = role;
      _showRoomView = true;
      _isNavigating = true;
    });
    // انتهى تبديل الغرف بنجاح - أوقف الحماية
    RoomSwitchGuard.end();
  }

  ZegoLiveAudioRoomRole _determineUserRole(RoomCubitState state) {
    if (_userAuth == null) return ZegoLiveAudioRoomRole.audience;

    final isAdmin =
        _userAuth!.adminRoomIds?.contains(widget.roomId.toString()) ?? false;
    final isOwner =
        _userAuth!.ownerIds?.contains(widget.roomId.toString()) ?? false;

    return (isAdmin || isOwner)
        ? ZegoLiveAudioRoomRole.host
        : ZegoLiveAudioRoomRole.audience;
  }

  @override
  Widget build(BuildContext context) {
    pageContext = context;

    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Black base layer to avoid any white flash
            const ColoredBox(color: Colors.black),
            BlocConsumer<RoomCubit, RoomCubitState>(
              listener: (context, state) {
                // تخزين أحدث حالة للاستخدام لاحقاً
                if (state.room?.id == widget.roomId) {
                  _cachedState = state;
                } else {
                  // Ignore state updates from other rooms to prevent leaking data
                  return;
                }

                if (state.status.isRoomError) {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    SnackBar(
                        content: Text('isRoomError : ${state.errorMessage}')),
                  );
                }

                if (state.status.isUserBanned) {
                  log("HomeView RoomViewBloc state.status.isUserBanned");
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeView(
                          userCubit: widget.userCubit,
                          roomCubit: widget.roomCubit,
                          isBanned: true,
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  });
                }

                _tryNavigateIfReady();
              },
              builder: (context, state) => const SizedBox(),
            ),
            // Always show background image if available for this room (fallback to passed image)
            if ((
                  (_cachedState?.room?.id == widget.roomId)
                      ? _cachedState?.room?.background
                      : widget.backgroundImage
                ) != null)
              BackgroundImageWidget(
                roomCubit: widget.roomCubit,
                backgroundImage: (_cachedState?.room?.id == widget.roomId)
                    ? _cachedState!.room!.background
                    : widget.backgroundImage!,
                key: ValueKey(
                    (_cachedState?.room?.id == widget.roomId)
                        ? _cachedState?.room?.background
                        : widget.backgroundImage),
              )
            else
              const SizedBox(),
            // Inline RoomView on top of background when ready
            AnimatedSwitcher(
              duration: Duration.zero,
              transitionBuilder: (child, animation) => child,
              child: (_showRoomView &&
                      _cachedState?.room != null &&
                      _cachedState?.room?.id == widget.roomId)
                  ? RoomView(
                      room: _cachedState!.room!,
                      roomCubit: widget.roomCubit,
                      userCubit: widget.userCubit,
                      bannedUser: _cachedState!.bannedUsers,
                      fromOverlay: widget.fromOverlay,
                      topUsers: _cachedState!.topUsers,
                      users: _cachedState!.usersServer,
                      role: _resolvedRole ?? _determineUserRole(_cachedState!),
                      adminUsers: _cachedState!.adminsListUsers,
                      useTransition: false,
                      showOwnBackground: false,
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

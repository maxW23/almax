import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/core/zego_delegate.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/luck_bag_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_messages_store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/live_audio_room_manager.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import '../../../domain/entities/room_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/chat_section.dart';
import 'optimized_seat_grid.dart';
import 'room_appbar.dart';
import 'room_buttons_row.dart';
import 'room_info_row.dart';

// استيراد المدراء الجدد
import 'managers/room_events_manager.dart';
import 'managers/audio_manager.dart';
import 'managers/gift_manager.dart';
import 'managers/layout_calculator.dart';
import 'managers/room_manager.dart';

/// الإصدار المحسن من RoomViewBody مع تجزئة المسؤوليات
class RoomViewBodyRefactored extends StatefulWidget {
  const RoomViewBodyRefactored({
    super.key,
    required this.room,
    required this.roomCubit,
    this.users,
    this.bannedUsers,
    required this.userCubit,
    required this.role,
    this.fromOverlay,
    required this.onSend,
    required this.messagesRoomChat,
    this.adminUsers,
  });

  final bool? fromOverlay;
  final RoomCubit roomCubit;
  final RoomEntity room;
  final List<UserEntity>? users;
  final List<UserEntity>? bannedUsers;
  final List<UserEntity>? adminUsers;
  final UserCubit userCubit;
  final ZegoLiveAudioRoomRole role;
  final void Function(ZIMMessage) onSend;
  final List<ZIMMessage> messagesRoomChat;

  @override
  State<RoomViewBodyRefactored> createState() => _RoomViewBodyRefactoredState();
}

class _RoomViewBodyRefactoredState extends State<RoomViewBodyRefactored>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // المدراء الجدد
  late RoomEventsManager _eventsManager;
  late AudioManager _audioManager;
  late GiftManager _giftManager;
  late RoomManager _roomManager;

  // المتغيرات الأساسية
  late ZegoLiveAudioRoomRole role;
  late BuildContext pageContext;
  ValueNotifier<bool> isApplyStateNotifier = ValueNotifier(false);
  late ZegoDelegate _zegoDelegate;
  final TextEditingController _controller = TextEditingController();
  final luckBagCubit = sl<LuckBagCubit>();
  final RoomMessagesStore _messagesStore = RoomMessagesStore.instance;

  // إعدادات الغرفة
  final int microphoneNumber = 9;

  @override
  void initState() {
    super.initState();
    role = widget.role;
    WidgetsBinding.instance.addObserver(this);
    _initializeManagers();
    _initializeRoom();
  }

  @override
  void dispose() {
    _disposeManagers();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    isApplyStateNotifier.dispose();
    super.dispose();
  }

  /// تهيئة جميع المدراء
  void _initializeManagers() {
    _zegoDelegate = ZegoDelegate();

    _eventsManager = RoomEventsManager(
      context: context,
      userCubit: widget.userCubit,
      roomCubit: widget.roomCubit,
      roomId: widget.room.id.toString(),
    );

    _audioManager = AudioManager(
      context: context,
      zegoDelegate: _zegoDelegate,
    );

    _giftManager = GiftManager(
      context: context,
      roomId: widget.room.id.toString(),
    );

    _roomManager = RoomManager(
      context: context,
      room: widget.room,
      zegoDelegate: _zegoDelegate,
      fromOverlay: widget.fromOverlay ?? false,
    );
  }

  /// تهيئة الغرفة
  Future<void> _initializeRoom() async {
    try {
      await _roomManager.initialize();
      _eventsManager.initialize();
      _audioManager.initialize();
      _giftManager.initialize();

      _initChatListeners();
      _listenUserChanges();

      log('Room initialized successfully', name: 'RoomViewBodyRefactored');
    } catch (e) {
      log('Error initializing room: $e', name: 'RoomViewBodyRefactored');
    }
  }

  /// تنظيف المدراء
  Future<void> _disposeManagers() async {
    await _roomManager.dispose();
    _eventsManager.dispose();
    _audioManager.dispose();
    _giftManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pageContext = context;

    // حساب أبعاد الشبكة والدردشة ديناميكياً
    final layout =
        LayoutCalculator.computeSeatAndChatHeights(context, microphoneNumber);
    final gridHeight = layout.gridHeight;

    return Stack(
      children: [
        Column(
          children: [
            // شريط العنوان
            _buildAppBar(),

            // معلومات الغرفة
            _buildRoomInfo(),

            // شبكة المقاعد
            _buildSeatsGrid(gridHeight),

            const SizedBox(height: 8),

            // قسم الدردشة
            _buildChatSection(),

            // أزرار الغرفة
            _buildRoomButtons(),
          ],
        ),

        // عرض الهدايا
        _giftManager.buildGiftsBlocWidget(),
      ],
    );
  }

  /// بناء شريط العنوان
  Widget _buildAppBar() {
    return BlocBuilder<RoomCubit, RoomCubitState>(
      buildWhen: (prev, curr) =>
          !identical(prev.usersZego, curr.usersZego) ||
          !identical(prev.bannedUsers, curr.bannedUsers) ||
          !identical(prev.adminsListUsers, curr.adminsListUsers),
      builder: (context, state) {
        return RoomAppbar(
          room: widget.room,
          roomCubit: widget.roomCubit,
          users: state.usersZego ?? widget.users ?? [],
          bannedUsers: state.bannedUsers ?? widget.bannedUsers,
          adminUsers: state.adminsListUsers ?? widget.adminUsers,
          userCubit: widget.userCubit,
          onSend: widget.onSend,
        );
      },
    );
  }

  /// بناء معلومات الغرفة
  Widget _buildRoomInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: RoomInfoRow(
        roomCubit: widget.roomCubit,
        room: widget.room,
        userCubit: widget.userCubit,
        onSend: widget.onSend,
      ),
    );
  }

  /// بناء شبكة المقاعد
  Widget _buildSeatsGrid(double gridHeight) {
    return SizedBox(
      height: gridHeight,
      child: RepaintBoundary(
        child: BlocBuilder<RoomCubit, RoomCubitState>(
          buildWhen: (prev, curr) =>
              !identical(prev.usersZego, curr.usersZego) ||
              !identical(prev.room, curr.room) ||
              prev.status != curr.status,
          builder: (context, state) {
            return seatListView(state);
          },
        ),
      ),
    );
  }

  /// بناء قسم الدردشة
  Widget _buildChatSection() {
    return Expanded(
      child: ChatSection(
        // messagesStore: _messagesStore,
        room: widget.room,
        role: role,
        roomCubit: widget.roomCubit,
        userCubit: widget.userCubit,
        roomID: widget.room.id.toString(),
        fromOverlay: widget.fromOverlay,
        onSend: widget.onSend,
        luckBagCubit: luckBagCubit,
      ),
    );
  }

  /// بناء أزرار الغرفة
  Widget _buildRoomButtons() {
    return BlocBuilder<RoomCubit, RoomCubitState>(
      buildWhen: (prev, curr) =>
          !identical(prev.usersZego, curr.usersZego) ||
          !identical(prev.room, curr.room) ||
          prev.status != curr.status,
      builder: (context, state) {
        return RoomButtonsRow(
          role: role,
          userCubit: widget.userCubit,
          roomCubit: widget.roomCubit,
          room: widget.room,
          user: widget.userCubit.user!,
          usersRoom: state.usersZego ?? widget.users ?? [],
          onSend: widget.onSend,
          deleteAllMessages: _deleteAllMessages,
          addDeleteAllMessagesMessage: _addDeleteAllMessagesMessage,
        );
      },
    );
  }

  /// مراقبة تغييرات المستخدم
  void _listenUserChanges() {
    widget.userCubit.stream.listen((state) {
      final currentUser = state.user;
      if (currentUser != null) {
        final isOwner =
            currentUser.ownerIds?.contains(widget.room.id.toString()) ?? false;
        final isAdmin =
            currentUser.adminRoomIds?.contains(widget.room.id.toString()) ??
                false;

        final newRole = (isOwner || isAdmin)
            ? ZegoLiveAudioRoomRole.host
            : ZegoLiveAudioRoomRole.audience;

        if (newRole != role && mounted) {
          setState(() {
            role = newRole;
          });
        }
      }
    });
  }

  /// تهيئة مستمعي الدردشة
  void _initChatListeners() {
    ZEGOSDKManager()
        .zimService
        .onRoomMessageReceivedStreamCtrl
        .stream
        .listen((messageList) {
      if (!mounted || messageList.isEmpty) return;
      _messagesStore.addMessages(widget.room.id.toString(), messageList);
    });
  }

  /// حذف جميع الرسائل
  void _deleteAllMessages() {
    _messagesStore.clearMessages();
    if (mounted) {
      setState(() {});
    }
  }

  /// إضافة رسالة حذف جميع الرسائل
  void _addDeleteAllMessagesMessage() {
    // يمكن إضافة منطق إضافي هنا
  }

  /// عرض قائمة المقاعد
  Widget seatListView(RoomCubitState state) {
    return OptimizedSeatGrid(
      seatList: ZegoLiveAudioRoomManager().seatList,
      room: widget.room,
      roomCubit: widget.roomCubit,
      userCubit: widget.userCubit,
      role: role,
      onSend: widget.onSend,
      isApplyStateNotifier: isApplyStateNotifier,
      audioManager: _audioManager, // تمرير مدير الصوت
    );
  }
}

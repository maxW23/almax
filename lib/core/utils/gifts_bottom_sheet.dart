import 'dart:math' as math;
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/core/utils/image_loader.dart';
import 'package:lklk/features/home/presentation/manger/gifts_show_cubit/gifts_show_cubit.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/coins_balance_page.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/store_dialog.dart';
import 'package:lklk/features/room/presentation/manger/gifts/gifts_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/live_audio_room_manager.dart';

/// محول آمن لسعر الهدية للتعامل مع صيغ مثل "1,000" أو رموز أخرى
int _normalizePriceInt(String? raw) {
  final s = raw ?? '0';
  final cleaned = s.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.isEmpty) return 0;
  return int.tryParse(cleaned) ?? 0;
}

class GiftsBottomSheetWidget extends StatefulWidget {
  const GiftsBottomSheetWidget(
      {super.key,
      required this.user,
      required this.roomId,
      required this.giftsShowCubit,
      required this.userCubit,
      required this.onSend,
      this.luckyWheelWidget,
      required this.selectedUsers});
  final String roomId;
  final UserEntity user;
  final UserCubit userCubit;
  final void Function(ZIMMessage) onSend;
  final Widget? luckyWheelWidget;
  final GiftsShowCubit giftsShowCubit;
  final List<UserEntity> selectedUsers;

  @override
  State<GiftsBottomSheetWidget> createState() => _GiftsBottomSheetWidgetState();

  static Future<void> showBasicModalBottomSheet(
    BuildContext context,
    UserEntity user,
    String roomId,
    UserCubit userCubit,
    GiftsShowCubit giftsShowCubit, // أضف هذا المعامل,
    void Function(ZIMMessage) onSend,
    List<UserEntity> selectedUsers,
  ) async {
    showModalBottomSheet(
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.darkColor,
      context: context,
      builder: (BuildContext context) {
        return GiftsBottomSheetWidget(
          user: user,
          roomId: roomId,
          userCubit: userCubit,
          giftsShowCubit: giftsShowCubit, // أضف هذا,
          onSend: onSend,
          selectedUsers: selectedUsers,
        );
      },
    );
  }
}

class _GiftsBottomSheetWidgetState extends State<GiftsBottomSheetWidget>
    with TickerProviderStateMixin {
  int? selectedIndex;
  ElementEntity? selectedItemId;
  bool isScrollable = false;
  bool showNextIcon = true;
  bool showBackIcon = true;
  List<UserEntity> selectedUsers = [];
  // حجز محلي للخصومات غير المنعكسة بعد على حالة المستخدم
  int _pendingReservedLucky = 0;
  // إزالة قفل الإرسال لتمكين إرسال هدية مع كل نقرة حتى لو كانت سريعة جداً
  // مزامنة محفظة الخادم بخلفية بعد الإرسال (throttled) لضمان عرض آخر قيمة من الخادم
  bool _walletSyncInFlight = false;
  DateTime _lastWalletSyncAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _walletSyncThrottle = Duration(milliseconds: 800);

  // دولاب الحظ (Lucky Wheel)
  bool _showLuckyWheel = false;
  AnimationController? _wheelAnimationController;
  Animation<double>? _wheelAnimation;
  int _wheelRunId = 0;
  ElementEntity? _lastLuckyGift; // آخر هدية حظ تم إرسالها
  List<UserEntity>? _lastLuckyRecipients; // آخر مستلمين لهدية الحظ
  int _lastLuckyAmount = 1; // آخر كمية لهدية الحظ
  int _currentComboAmount = 1; // الكمية الحالية للـ COMBO
  void updateSelectedItemId(ElementEntity itemId) {
    setState(() {
      selectedItemId = itemId;
      // log('itemId ${jsonEncode(itemId)}');
    });
  }

  void updateSelectedUsers(List<UserEntity> users) {
    setState(() {
      selectedUsers = users;
      log('selectedUsers $selectedUsers');
    });
  }

  @override
  void initState() {
    super.initState();
    selectedUsers = widget.selectedUsers;

    // تهيئة أنيميشن دولاب الحظ
    _wheelAnimationController = AnimationController(
      duration: const Duration(seconds: 4), // 4 ثوانِ لاكتمال الدائرة
      vsync: this,
    );

    _wheelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _wheelAnimationController!,
      curve: Curves.linear, // حركة خطية منتظمة
    ));

    // Auto-hide COMBO wheel when the 4s animation completes
    _wheelAnimationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed && _showLuckyWheel) {
        if (!mounted) return;
        setState(() => _showLuckyWheel = false);
      }
    });
    context.read<GiftCubit>().fetchGiftsElements();
  }

  // جدولة مزامنة المحفظة مع الخادم بدون حجب، مع خنق بسيط لتفادي الطلبات الكثيفة
  void _scheduleWalletSync() {
    final now = DateTime.now();
    if (_walletSyncInFlight) return;
    if (now.difference(_lastWalletSyncAt) < _walletSyncThrottle) return;
    _walletSyncInFlight = true;
    _lastWalletSyncAt = now;
    try {
      widget.userCubit.refreshWalletOnly().whenComplete(() {
        _walletSyncInFlight = false;
      });
    } catch (_) {
      _walletSyncInFlight = false;
    }
  }

  /// بدء دولاب الحظ بعد إرسال هدية حظ
  void _startLuckyWheel(
      ElementEntity gift, List<UserEntity> recipients, int amount) {
    setState(() {
      _showLuckyWheel = true;
      _lastLuckyGift = gift;
      _lastLuckyRecipients = recipients;
      _lastLuckyAmount = amount;
    });

    // Track this run to auto-hide at exactly 4s even if listeners fail
    final int myRun = ++_wheelRunId;

    // بدء أنيميشن الدائرة (4 ثوانِ)
    _wheelAnimationController?.reset();
    _wheelAnimationController?.forward();
    // Force-hide after 4s if this is still the latest run and wheel is visible
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (myRun == _wheelRunId && _showLuckyWheel) {
        setState(() => _showLuckyWheel = false);
      }
    });

    log('🎰 [LUCKY_WHEEL] بدء دولاب الحظ لهدية: ${gift.elementName}');
  }

  /// إعادة إرسال آخر هدية حظ
  Future<void> _resendLastLuckyGift() async {
    // استخدم الاختيارات الحالية إن توفرت، وإلا آخر قيم معروفة
    final gift = selectedItemId ?? _lastLuckyGift;
    final recipientsList =
        selectedUsers.isNotEmpty ? selectedUsers : (_lastLuckyRecipients ?? []);
    if (gift == null || recipientsList.isEmpty) {
      return;
    }
    final int amountToSend =
        (_currentComboAmount > 0 ? _currentComboAmount : _lastLuckyAmount);

    // Immediately renew the 4s combo window on user tap (without waiting for send result)
    if (!_showLuckyWheel) {
      setState(() {
        _showLuckyWheel = true;
      });
    }
    _wheelAnimationController?.reset();
    _wheelAnimationController?.forward();
    final int myRunTap = ++_wheelRunId;
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (myRunTap == _wheelRunId && _showLuckyWheel) {
        setState(() => _showLuckyWheel = false);
      }
    });

    log('🔄 [LUCKY_WHEEL] إعادة إرسال هدية الحظ: ${gift.elementName}');

    final giftCubit = context.read<GiftCubit>();
    final giftsShowCubit = context.read<GiftsShowCubit>();

    final selectedUsersString = _selectedUsersToString(recipientsList);
    final selectedUsersStringName = _selectedUsersToStringName(recipientsList);
    final giftId = gift.id?.toString() ?? '0';

    // تحقق الرصيد: سعر × كمية الكومبو × عدد المستلمين
    final price = _normalizePriceInt(gift.price);
    final recipientsCount = recipientsList.length;
    final totalCost = price * amountToSend * recipientsCount;
    final currentWallet =
        widget.userCubit.state.user?.wallet ?? widget.user.wallet ?? 0;
    final effectiveWallet = currentWallet - _pendingReservedLucky;

    if (recipientsCount == 0) {
      // لا يوجد مستلمين، لا ترسل
      return;
    }
    if (effectiveWallet < totalCost) {
      await _showInsufficientBalanceDialog(context);
      return;
    }

    // احجز الرصيد فوراً لمنع تجاوز الرصيد أثناء الطلبات المتتالية
    _pendingReservedLucky += totalCost;

    // إرسال غير حاجب (Fire-and-forget) لزيادة الاستجابة
    giftCubit
        .sendGift(
      giftId,
      widget.roomId,
      selectedUsersString,
      amountToSend,
      giftsShowCubit,
      widget.onSend,
      selectedUsersStringName,
    )
        .then((result) {
      if (result == 'Gift sent successfully') {
        // في هدايا الحظ: لا نخصم تفاؤلياً — نعتمد على مزامنة الخادم فقط
        final bool isLuckyGift = (gift.type?.toLowerCase() == 'lucky');
        if (isLuckyGift) {
          widget.userCubit.refreshWalletOnly();
        } else {
          // لغير الحظ، نحافظ على الخصم التفاؤلي كما هو
          widget.userCubit.optimisticWalletDeduct(totalCost);
        }
        // حرر الحجز المقابل لهذا الطلب
        _pendingReservedLucky -= totalCost;
        if (_pendingReservedLucky < 0) _pendingReservedLucky = 0;

        // تحديث الحالة الأخيرة إلى القيم الحالية
        _lastLuckyGift = gift;
        _lastLuckyRecipients = recipientsList;
        _lastLuckyAmount = amountToSend;

        // إعادة بدء الأنيميشن (4 ثوانِ جديدة)
        _wheelAnimationController?.reset();
        _wheelAnimationController?.forward();
        // Restart 4s window on user press (resend)
        final int myRun = ++_wheelRunId;
        Future.delayed(const Duration(seconds: 4), () {
          if (!mounted) return;
          if (myRun == _wheelRunId && _showLuckyWheel) {
            setState(() => _showLuckyWheel = false);
          }
        });

        log('✅ [LUCKY_WHEEL] تم إعادة إرسال هدية الحظ بنجاح');

        // مزامنة خلفية للمحفظة لضمان عرض آخر قيمة من الخادم
        _scheduleWalletSync();
      } else {
        // فشل — أزل الحجز المتعلق بهذا الطلب
        _pendingReservedLucky -= totalCost;
        if (_pendingReservedLucky < 0) _pendingReservedLucky = 0;
      }
    }).catchError((_) {
      // خطأ — أزل الحجز المتعلق بهذا الطلب
      _pendingReservedLucky -= totalCost;
      if (_pendingReservedLucky < 0) _pendingReservedLucky = 0;
    });

    // لا حاجة لتحرير القفل هنا — سيتم تحريره تلقائياً بعد 120ms بواسطة الخنق أعلاه
  }

  Future<void> _showInsufficientBalanceDialog(BuildContext context) async {
    return showDialog(
      context: context,
      useSafeArea: true,
      builder: (ctx) {
        return SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              insetPadding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.of(ctx).viewPadding.bottom,
              ),
              title: AutoSizeText(S.of(ctx).error),
              content: AutoSizeText(S.of(ctx).notHaveEnoghtMoney),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: AutoSizeText(S.of(ctx).done),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// بناء ويدجت دولاب الحظ
  Widget _buildLuckyWheel() {
    return GestureDetector(
      onTap: _resendLastLuckyGift,
      child: Container(
        width: 64.w,
        height: 64.h,
        decoration: BoxDecoration(
          color: AppColors.secondColor, // لون الدائرة
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // نص "combo"
            Text(
              'COMBO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            // الإطار الدوار (أنيميشن)
            AnimatedBuilder(
              animation: _wheelAnimation!,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(64.w, 64.h),
                  painter: _CircularProgressPainter(
                    progress: _wheelAnimation!.value,
                    strokeWidth: 4.0,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// تحويل قائمة المستخدمين إلى نص (معرفات)
  String _selectedUsersToString(List<UserEntity> users) {
    return users.map((user) => user.iduser).join('ـ');
  }

  /// تحويل قائمة المستخدمين إلى نص (أسماء)
  String _selectedUsersToStringName(List<UserEntity> users) {
    return users.map((user) => user.name).join('ـ');
  }

  @override
  void dispose() {
    _wheelAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heightScreen = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      height: heightScreen * .5,
      child: BlocBuilder<GiftCubit, GiftState>(
        builder: (context, state) {
          List<ElementEntity>? gifts = state.elements;
          if (gifts != null) {
            // Sort helper: returns a new list sorted by ascending price
            List<ElementEntity> _sortByPriceAsc(List<ElementEntity> src) {
              final list = List<ElementEntity>.from(src);
              list.sort((a, b) =>
                  _normalizePriceInt(a.price).compareTo(_normalizePriceInt(b.price)));
              return list;
            }

            // Prepare sorted lists for each tab/category
            final popularList =
                _sortByPriceAsc(gifts.where((e) => e.type == 'popular').toList());
            final luckyList =
                _sortByPriceAsc(gifts.where((e) => e.type == 'lucky').toList());
            final coupleList =
                _sortByPriceAsc(gifts.where((e) => e.type == 'couple').toList());
            final famousList =
                _sortByPriceAsc(gifts.where((e) => e.type == 'famous').toList());

            List<TabData> tabs = [
              TabData(
                index: 0,
                title: Tab(child: AutoSizeText(S.of(context).popular)),
                content: GiftPage(
                  user: widget.user,
                  updateSelectedItemId: updateSelectedItemId,
                  elements: popularList,
                  selectedIndex: selectedIndex,
                  onTap: (index) => setState(() {
                    selectedIndex = index;
                  }),
                ),
              ),
              TabData(
                index: 1,
                title: Tab(child: AutoSizeText(S.of(context).lucky)),
                content: GiftPage(
                  user: widget.user,
                  updateSelectedItemId: updateSelectedItemId,
                  elements: luckyList,
                  selectedIndex: selectedIndex,
                  onTap: (index) => setState(() {
                    selectedIndex = index;
                  }),
                ),
              ),
              TabData(
                index: 2,
                title: Tab(child: AutoSizeText(S.of(context).couple)),
                content: GiftPage(
                  user: widget.user,
                  updateSelectedItemId: updateSelectedItemId,
                  // elements: gifts,
                  elements: coupleList,
                  selectedIndex: selectedIndex,
                  onTap: (index) => setState(() {
                    selectedIndex = index;
                  }),
                ),
              ),
              // New 'Famous' tab
              TabData(
                index: 3,
                title: Tab(child: AutoSizeText(S.of(context).famous)),
                content: GiftPage(
                  user: widget.user,
                  updateSelectedItemId: updateSelectedItemId,
                  elements: famousList,
                  selectedIndex: selectedIndex,
                  onTap: (index) => setState(() {
                    selectedIndex = index;
                  }),
                ),
              ),
            ];

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              height: heightScreen * .6,
              child: Column(
                children: [
                  SizedBox(
                    height: 45.h,
                    child: BlocSelector<RoomCubit, RoomCubitState,
                        List<UserEntity>>(
                      selector: (stateRoomCubit) =>
                          stateRoomCubit.usersZego ?? [],
                      builder: (context, users) {
                        return UsersListViewGifts(
                          onSelectedUsersChanged: updateSelectedUsers,
                          user: widget.user,
                          usersRoom: users,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: DynamicTabBarWidget(
                      dynamicTabs: tabs,
                      isScrollable: isScrollable,
                      onTabControllerUpdated: (controller) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {});
                        });
                      },
                      onTabChanged: (index) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            selectedIndex = null;
                            selectedItemId = null;
                          });
                        });
                      },
                      onAddTabMoveTo: MoveToTab.last,
                      showBackIcon: showBackIcon,
                      showNextIcon: showNextIcon,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5.r),
                    child: Row(
                      children: [
                        // قسم العملات
                        Expanded(
                          child: SizedBox(
                            height: 64.h,
                            child: CoinsSection(
                              selectedUsers: selectedUsers,
                              selectedItemId: selectedItemId,
                              roomId: widget.roomId,
                              user: widget.user,
                              userCubit: widget.userCubit,
                              onSend: widget.onSend,
                              luckyWheelWidget:
                                  _showLuckyWheel ? _buildLuckyWheel() : null,
                              onAmountChanged: (v) {
                                setState(() {
                                  _currentComboAmount = v;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class UsersListViewGifts extends StatefulWidget {
  const UsersListViewGifts({
    super.key,
    required this.onSelectedUsersChanged,
    required this.user,
    required this.usersRoom,
  });

  final List<UserEntity> usersRoom;
  final Function(List<UserEntity>) onSelectedUsersChanged;
  final UserEntity user;

  @override
  State<UsersListViewGifts> createState() => _UsersListViewGiftsState();
}

class _UsersListViewGiftsState extends State<UsersListViewGifts> {
  final Set<int> _selectedIndices = {};
  List<UserEntity> _autoSelectedUsers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateSelectedIndices();
    });
  }

  @override
  void didUpdateWidget(UsersListViewGifts oldWidget) {
    super.didUpdateWidget(oldWidget);

    // إذا تغيرت قائمة المستخدمين، نحدّث القائمة المحددة تلقائياً
    if (oldWidget.usersRoom != widget.usersRoom) {
      // نحدّث _autoSelectedUsers لتحتوي فقط على المستخدمين الموجودين حالياً
      _autoSelectedUsers = _autoSelectedUsers
          .where((user) => widget.usersRoom
              .any((roomUser) => roomUser.iduser == user.iduser))
          .toList();

      _updateSelectedIndices();
    }
  }

  void _updateSelectedIndices() {
    setState(() {
      _selectedIndices.clear();
      for (int i = 0; i < widget.usersRoom.length; i++) {
        if (_autoSelectedUsers
            .any((user) => user.iduser == widget.usersRoom[i].iduser)) {
          _selectedIndices.add(i);
        }
      }
    });
  }

  void _notifySelectedUsers() {
    List<UserEntity> selectedUsers = _selectedIndices.map((index) {
      return widget.usersRoom[index];
    }).toList();
    widget.onSelectedUsersChanged(selectedUsers);
  }

  void _selectAllUsers() {
    setState(() {
      _autoSelectedUsers = List.from(widget.usersRoom);
      _selectedIndices.clear();
      _selectedIndices
          .addAll(List.generate(widget.usersRoom.length, (index) => index));
      _notifySelectedUsers();
    });
  }

  void _selectMicrophoneUsers() {
    setState(() {
      _autoSelectedUsers.clear();
      _selectedIndices.clear();

      for (final element in ZegoLiveAudioRoomManager().seatList) {
        if (element.currentUser.value?.iduser != null) {
          final userIndex = widget.usersRoom.indexWhere(
              (user) => user.iduser == element.currentUser.value?.iduser);
          if (userIndex != -1) {
            _selectedIndices.add(userIndex);
            _autoSelectedUsers.add(widget.usersRoom[userIndex]);
          }
        }
      }
      _notifySelectedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = widget.usersRoom;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: 45.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              itemCount: filteredUsers.length,
              padding: EdgeInsets.symmetric(horizontal: 5.r, vertical: 2.r),
              itemBuilder: (context, index) {
                final isSelected = _selectedIndices.contains(index);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedIndices.remove(index);
                        _autoSelectedUsers.removeWhere(
                          (user) => user.iduser == filteredUsers[index].iduser,
                        );
                      } else {
                        _selectedIndices.add(index);
                        _autoSelectedUsers.add(filteredUsers[index]);
                      }
                      _notifySelectedUsers();
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor:
                        isSelected ? AppColors.primary : AppColors.white,
                    radius: 22.r,
                    child: Padding(
                      padding: EdgeInsets.all(1.r),
                      child: CircularUserImage(
                        imagePath: filteredUsers[index].img,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10.r),
          child: SizedBox(
            width: 55.w,
            height: 45.h,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // عرض قائمة مخصصة
                  _showCustomMenu(context);
                },
                child: Icon(
                  Icons.arrow_circle_down_sharp,
                  color: AppColors.primary,
                  size: 24.r,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

// أضف هذه الدالة في _UsersListViewGiftsState
  void _showCustomMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.darkColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          insetPadding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 24.h,
            bottom: 24.h + MediaQuery.of(dialogContext).viewPadding.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 320.w),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DialogOptionTile(
                    label: S.of(dialogContext).sendToAllUsersInTheRoom,
                    icon: FontAwesomeIcons.users,
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      _selectAllUsers();
                    },
                  ),
                  Divider(
                    height: 1.h,
                    color: Colors.white24.withValues(alpha: 0.15),
                  ),
                  _DialogOptionTile(
                    label: S.of(dialogContext).sendToAllUsersInMicrophones,
                    icon: FontAwesomeIcons.microphone,
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      _selectMicrophoneUsers();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DialogOptionTile extends StatelessWidget {
  const _DialogOptionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      minTileHeight: 48.h,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      title: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Icon(
        icon,
        color: AppColors.white,
        size: 18.r,
      ),
    );
  }
}

class TabData {
  final int index;
  final Tab title;
  final Widget content;

  TabData({required this.index, required this.title, required this.content});
}

class DynamicTabBarWidget extends StatelessWidget {
  final List<TabData> dynamicTabs;
  final bool isScrollable;
  final Function(TabController) onTabControllerUpdated;
  final Function(int) onTabChanged;
  final MoveToTab onAddTabMoveTo;
  final bool showNextIcon;
  final bool showBackIcon;

  const DynamicTabBarWidget({
    super.key,
    required this.dynamicTabs,
    required this.isScrollable,
    required this.onTabControllerUpdated,
    required this.onTabChanged,
    required this.onAddTabMoveTo,
    required this.showNextIcon,
    required this.showBackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: dynamicTabs.length,
      child: Column(
        children: [
          TabBar(
            isScrollable: isScrollable,
            tabs: dynamicTabs.map((tab) => tab.title).toList(),
            onTap: onTabChanged,
          ),
          Expanded(
            child: TabBarView(
              children: dynamicTabs.map((tab) => tab.content).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

enum MoveToTab { last }
/////////////////////////////////////////////
///

class GiftPage extends StatelessWidget {
  final List<ElementEntity> elements;
  final int? selectedIndex;
  final Function(int) onTap;
  final UserEntity user;
  final Function(ElementEntity) updateSelectedItemId;
  const GiftPage({
    super.key,
    required this.elements,
    required this.selectedIndex,
    required this.onTap,
    required this.user,
    required this.updateSelectedItemId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.r),
      child: GridView.builder(
        itemCount: elements.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 100,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.7,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.r),
        itemBuilder: (context, index) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 100,
              maxHeight: 140, // Add max height constraint
            ),
            child: GiftItemElement(
              name: elements[index].elementName ?? "",
              image:
                  elements[index].imgElementLocal ?? elements[index].imgElement,
              price: elements[index].price!,
              isSelected: index == selectedIndex,
              // svga: elements[index].link!,
              index: index,
              // onTap: () {
              //   onTap(index);
              // },
              onTap: () {
                onTap(index);

                updateSelectedItemId(
                    elements[index]); // Update selected item id
              },
              icononTap: () {
                elements[index].type == 'entry'
                    ? showDialog(
                        context: context,
                        builder: (context) => CustomSVGAWidget(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              isRepeat: true,
                              pathOfSvgaFile: SvgaUtils.getValidFilePath(
                                      elements[index].elamentId.toString()) ??
                                  elements[index].linkPathLocal ??
                                  elements[index].linkPath!,
                            ))
                    : showDialog(
                        context: context,
                        builder: (context) => StoreDialog(
                          image: SvgaUtils.getValidFilePath(
                                  elements[index].elamentId.toString()) ??
                              elements[index].linkPathLocal ??
                              elements[index].linkPath!,
                          type: elements[index].type!,
                          user: user,
                        ),
                      );
              },
            ),
          );
        },
      ),
    );
  }
}

////////////////////////////////////////
///

class GiftItemElement extends StatelessWidget {
  const GiftItemElement({
    super.key,
    required this.name,
    required this.image,
    required this.price,
    required this.isSelected,
    required this.onTap,
    required this.index,
    required this.icononTap,
  });
  final String name, price;
  final String? image;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback icononTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: .8),
                  width: 2,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 60.h,
              width: 60.w,
              child: image != null
                  ? ImageLoader(
                      imageUrl: image!,
                      width: 60.w,
                      height: 60.h,
                      shape: const RoundedRectangleBorder(),
                      fit: BoxFit.contain,
                      sharpnessScale: 1.3,
                      placeholderColor: Colors.grey.shade200,
                      fallbackWidget: Center(
                        child: Icon(
                          Icons.error_outline,
                          color: const Color(0xFFFF0000),
                          size: 40.r,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.error_outline,
                        color: const Color(0xFFFF0000),
                        size: 40.r,
                      ),
                    ),
            ),
            SizedBox(
              height: 2.h,
            ),
            AutoSizeText(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AssetsData.coins,
                  height: 17.h,
                ),
                AutoSizeText(
                  ' $price ',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.golden,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CoinsSection extends StatefulWidget {
  const CoinsSection({
    super.key,
    required this.selectedItemId,
    required this.roomId,
    required this.user,
    required this.selectedUsers,
    required this.userCubit,
    required this.onSend,
    this.luckyWheelWidget,
    this.onAmountChanged,
  });

  final ElementEntity? selectedItemId;
  final UserEntity user;
  final String roomId;
  final List<UserEntity> selectedUsers;
  final UserCubit userCubit;
  final void Function(ZIMMessage) onSend;
  final Widget? luckyWheelWidget;
  final ValueChanged<int>? onAmountChanged;
  @override
  State<CoinsSection> createState() => _CoinsSectionState();
}

class _CoinsSectionState extends State<CoinsSection> {
  int selectedGiftAmount = 1; // Default value

  late UserEntity currentUser;
  int _pendingReserved = 0; // حجز محلي لتفادي خصم متكرر قبل مزامنة الحالة
  bool _isSending = false; // منع النقرات المتعددة

  @override
  void initState() {
    currentUser = widget.user;
    _fetchProfileUser();
    super.initState();
    // Defer notifying parent to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onAmountChanged?.call(selectedGiftAmount);
    });
  }

  String _selectedUsersToString(List<UserEntity> users) {
    return users.map((user) => user.iduser).join('ـ');
  }

  String _selectedUsersToStringName(List<UserEntity> users) {
    return users.map((user) => user.name).join('ـ');
  }

  Future<void> _fetchProfileUser() async {
    final user =
        await widget.userCubit.getProfileUser("giftsbsheet", fast: true);
    if (user != null && mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GiftCubit, GiftState>(
      builder: (context, state) {
        return BlocListener<UserCubit, UserCubitState>(
          bloc: widget.userCubit,
          listener: (context, state) {
            if (state.status.isLoadedProfile) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  currentUser = state.user!;
                  _pendingReserved =
                      0; // تمّت المزامنة مع الخادم، أزل الحجز المحلي
                });
              });
            } else if (state.status.isLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  currentUser = state.user!;
                  _pendingReserved =
                      0; // تمّت المزامنة مع الخادم، أزل الحجز المحلي
                });
              });
            }
          },
          child: SizedBox(
            height: 64.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 6.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoinsBalancePage(
                          userCubit: widget.userCubit,
                          diamond: currentUser.diamond ?? 0,
                          wallet: currentUser.wallet ?? 0,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AssetsData.coins,
                          height: 24.h,
                        ),
                        SizedBox(width: 2.w),
                        Builder(builder: (context) {
                          final int serverWallet = currentUser.wallet ?? 0;
                          final bool isLucky =
                              (widget.selectedItemId?.type?.toLowerCase() ==
                                  'lucky');
                          final int effective = isLucky
                              ? (serverWallet - _pendingReserved)
                              : serverWallet;
                          final displayValue = effective < 0 ? 0 : effective;
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeInBack,
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: AutoSizeText(
                              '$displayValue',
                              key: ValueKey<int>(displayValue),
                              style: TextStyle(
                                color: AppColors.amber,
                                fontWeight: FontWeight.w600,
                                fontSize: 20.sp,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (widget.selectedItemId != null)
                    (widget.luckyWheelWidget ?? sendBtnWithX(context, state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Row sendBtnWithX(BuildContext context, GiftState state) {
    return Row(
      children: [
        xbtn(context),
        sendbtn(state, context),
      ],
    );
  }

  Widget sendbtn(GiftState state, BuildContext context) {
    return Container(
      height: 36.h,
      width: 60.w,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(40.r),
          topRight: Radius.circular(40.r),
        ),
        gradient: const LinearGradient(
          colors: [
            AppColors.purpleColor,
            AppColors.darkColor,
          ],
        ),
      ),
      child: GestureDetector(
        onTap: widget.selectedItemId == null || state.isLoading() || _isSending
            ? null
            : () async {
                if (!mounted) return;

                final giftsShowCubit = context.read<GiftsShowCubit>();
                final giftCubit = context.read<GiftCubit>();
                final selectedUsersString =
                    _selectedUsersToString(widget.selectedUsers);
                final selectedUsersStringName =
                    _selectedUsersToStringName(widget.selectedUsers);
                final price = _normalizePriceInt(widget.selectedItemId?.price);
                final recipientsCount = widget.selectedUsers.length;
                if (recipientsCount == 0) {
                  emptyUserDialog(context);
                  return;
                }
                final giftId = widget.selectedItemId!.id?.toString() ?? '0';
                final validRecipients = selectedUsersString;
                final validAmount =
                    selectedGiftAmount > 0 ? selectedGiftAmount : 1;
                final int totalCost = price * validAmount * recipientsCount;
                final effectiveWallet =
                    (currentUser.wallet ?? 0) - _pendingReserved;

                if (effectiveWallet < totalCost) {
                  await failureDialog(context);
                  return;
                }

                _isSending = true;
                final bool isLuckyGift =
                    (widget.selectedItemId?.type?.toLowerCase() == 'lucky');
                // للحظ فقط: احجز محلياً قبل الإرسال لإظهار خصم فوري
                if (isLuckyGift) {
                  setState(() {
                    _pendingReserved += totalCost;
                  });
                }

                final result = await giftCubit.sendGift(
                    giftId,
                    widget.roomId,
                    validRecipients,
                    validAmount,
                    giftsShowCubit,
                    widget.onSend,
                    selectedUsersStringName);

                // معالجة بعد النجاح
                if (result == 'Gift sent successfully') {
                  if (isLuckyGift) {
                    await widget.userCubit.refreshWalletOnly();
                    _pendingReserved = 0; // أزل الحجز بعد المزامنة
                  } else {
                    // لغير الحظ: حافظ على الخصم التفاؤلي + مزامنة خفيفة
                    widget.userCubit.optimisticWalletDeduct(totalCost);
                    _pendingReserved += totalCost;
                    await widget.userCubit
                        .getProfileUser("giftsbsheet", fast: true);
                    _pendingReserved = 0;
                  }

                  // بدء دولاب الحظ إذا كانت هدية حظ
                  if (isLuckyGift) {
                    final parentState = context.findAncestorStateOfType<
                        _GiftsBottomSheetWidgetState>();
                    parentState?._startLuckyWheel(
                      widget.selectedItemId!,
                      widget.selectedUsers,
                      validAmount,
                    );
                  }
                } else {
                  // فشل الإرسال: أزل الحجز فوراً إذا كان محجوزاً
                  if (isLuckyGift) {
                    setState(() {
                      _pendingReserved -= totalCost;
                      if (_pendingReserved < 0) _pendingReserved = 0;
                    });
                  }
                }
                _isSending = false;
              },
        child: Center(
          child: state.isLoading()
              ? SizedBox(
                  height: 22.h,
                  width: 22.h,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 3,
                  ),
                )
              : AutoSizeText(
                  S.of(context).send,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Container xbtn(BuildContext context) {
    return Container(
      height: 36.h,
      width: 60.w,
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.r),
          bottomLeft: Radius.circular(40.r),
        ),
        gradient: const LinearGradient(
          colors: [AppColors.darkColor, AppColors.purpleColor],
        ),
      ),
      child: GestureDetector(
        onTap: () {
          _showGiftAmountBottomSheet(context);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
          child: AutoSizeText(
            'X $selectedGiftAmount',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> failureDialog(
    BuildContext context,
  ) {
    return showDialog(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              insetPadding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.of(context).viewPadding.bottom,
              ),
              title: AutoSizeText(S.of(context).error),
              content: AutoSizeText(S.of(context).notHaveEnoghtMoney),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: AutoSizeText(S.of(context).done),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> emptyUserDialog(BuildContext context) {
    return showDialog(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              insetPadding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.of(context).viewPadding.bottom,
              ),
              title: AutoSizeText(
                S.of(context).error,
              ),
              content: AutoSizeText(
                S.of(context).pleaseSelectUsers,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: AutoSizeText(S.of(context).okay),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGiftAmountBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.darkColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 240.h,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Center(
                    child: AutoSizeText(
                      '1',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedGiftAmount = 1;
                    });
                    widget.onAmountChanged?.call(selectedGiftAmount);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Center(
                    child: AutoSizeText(
                      '7',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedGiftAmount = 7;
                    });
                    widget.onAmountChanged?.call(selectedGiftAmount);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Center(
                    child: AutoSizeText(
                      '17',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedGiftAmount = 17;
                    });
                    widget.onAmountChanged?.call(selectedGiftAmount);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Center(
                    child: AutoSizeText(
                      '77',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedGiftAmount = 77;
                    });
                    widget.onAmountChanged?.call(selectedGiftAmount);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// رسام الدائرة المتقدمة لدولاب الحظ
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // رسم الدائرة المتقدمة (الإطار الأبيض الدوار)
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // رسم القوس من 0 إلى progress * 2π (دورة كاملة)
    final startAngle = -math.pi / 2; // البداية من الأعلى
    final sweepAngle = 2 * math.pi * progress; // الزاوية حسب التقدم

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _CircularProgressPainter &&
        oldDelegate.progress != progress;
  }
}

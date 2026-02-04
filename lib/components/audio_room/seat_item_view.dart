import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/constants/svip_colors.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/core/utils/list_emoji.dart';
import 'package:lklk/core/utils/logger.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/domain/entities/avatar_data_zego.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/manger/emoji_cubit/emoji_cubit.dart';
import 'package:lklk/features/room/presentation/manger/room_exit_service.dart';
import 'package:lklk/features/room/presentation/views/widgets/image_user_section_with_fram.dart';
import 'package:lklk/features/room/presentation/views/widgets/name_user_widget.dart';
import 'package:lklk/features/room/presentation/views/widgets/seat_position_manager.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';

import '../../live_audio_room_manager.dart';

class ZegoSeatItemView extends StatefulWidget {
  const ZegoSeatItemView({
    super.key,
    required this.seatIndex,
    required this.micNum,
    required this.indexmic,
    required this.roomCubit,
    required this.userCubit,
    required this.soundLevel,
    required this.roomId,
  });

  final int seatIndex;
  final int micNum;
  final int indexmic;
  final String roomId;
  final ValueNotifier<double> soundLevel;

  final RoomCubit roomCubit;
  final UserCubit userCubit;

  @override
  State<ZegoSeatItemView> createState() => _ZegoSeatItemViewState();
}

class _ZegoSeatItemViewState extends State<ZegoSeatItemView> {
  late BuildContext pageContext;
  String? currentRequestID;
  ValueNotifier<bool> isApplyStateNoti = ValueNotifier(false);
  late String senderIDEmoji;
  late bool isEmojiShow = false;
  final ExpressService expressService = ExpressService();
  List<StreamSubscription<dynamic>?> subscriptions = [];
  Timer? _userDataCheckTimer;

  // GlobalKey للحصول على موضع صورة المستخدم الفعلي
  final GlobalKey _userImageKey = GlobalKey();

  // سجل للتأكد من تسجيل موضع المستخدم مرة واحدة فقط لكل مستخدم لتقليل addPostFrameCallback المتكرر
  final Set<String> _positionRegistered = <String>{};

  static const bool _enableSeatLogs = false;

  void _seatLog(String message, {String? name}) {
    if (!_enableSeatLogs) return;
    if (name != null) {
      log(message, name: name);
    } else {
      log(message);
    }
  }

  @override
  void initState() {
    super.initState();

    final zimService = ZEGOSDKManager().zimService;
    final expressService = ZEGOSDKManager().expressService;

    // Register this seat's user image key so SeatPositionManager can resolve
    // seat positions by index using RenderBox for exact placement.
    SeatPositionManager().registerSeatKey(widget.seatIndex, _userImageKey);

    subscriptions.addAll([
      zimService.onRoomCommandReceivedEventStreamCtrl.stream.listen(
        (event) {
          onRoomCommandReceived(
            event,
            widget.userCubit,
            widget.roomCubit,
          );
        },
        onError: (error) {
          _seatLog('Room command stream error: $error');
        },
        onDone: () => _seatLog('Room command stream is closed'),
      ),
      expressService.roomStateChangedStreamCtrl.stream
          .listen(onExpressRoomStateChanged),
      zimService.roomStateChangedStreamCtrl.stream
          .listen(onZIMRoomStateChanged),
      zimService.connectionStateStreamCtrl.stream
          .listen(onZIMConnectionStateChanged),
      zimService.onInComingRoomRequestStreamCtrl.stream
          .listen(onInComingRoomRequest),
      zimService.onOutgoingRoomRequestAcceptedStreamCtrl.stream
          .listen(onOutgoingRoomRequestAccepted),
      zimService.onOutgoingRoomRequestRejectedStreamCtrl.stream
          .listen(onOutgoingRoomRequestRejected),
      expressService.roomUserListUpdateStreamCtrl.stream
          .listen(onRoomUserListUpdate),
    ]);

    // بدء مؤقت للتحقق الدوري من المستخدمين الذين لا تظهر صورهم
    _startUserDataCheckTimer();
  }

  @override
  void dispose() {
    _userDataCheckTimer?.cancel();
    for (final subscription in subscriptions) {
      subscription?.cancel();
    }
    super.dispose();
  }

  /// الحصول على الموضع الفعلي لصورة المستخدم في المايك
  Offset? getUserImagePosition() {
    try {
      final RenderBox? renderBox =
          _userImageKey.currentContext?.findRenderObject() as RenderBox?;
      // تأكد أن الـ RenderBox موجود ومرفق بالشجرة ولديه حجم قبل الحساب
      if (renderBox != null && renderBox.attached && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        // إرجاع موضع منتصف الصورة مع التعديل المطلوب
        return Offset(
          position.dx + (size.width / 2) - 20, // تحريك 20 لليسار
          position.dy + (size.height / 2) - 20, // تحريك 20 للأعلى
        );
      }
    } catch (e) {
      _seatLog('Error getting user image position: $e');
    }
    return null;
  }

  /// تسجيل موضع المستخدم في المدير
  void _registerUserPosition(String userId) {
    if (_positionRegistered.contains(userId)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final position = getUserImagePosition();
      if (position != null) {
        SeatPositionManager().registerUserPosition(userId, position);
        _positionRegistered.add(userId);
        _seatLog('📍 Registered position for user $userId at $position',
            name: 'ZegoSeatItemView');
      } else {
        _seatLog('❌ Failed to get position for user $userId',
            name: 'ZegoSeatItemView');
      }
    });
  }

  /// بدء مؤقت للتحقق الدوري من المستخدمين الذين لا تظهر صورهم
  /// محسن للحد الأقصى 20 مستخدم
  void _startUserDataCheckTimer() {
    _userDataCheckTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _checkMissingUserData();
    });
  }

  /// فحص المستخدمين الذين لا تظهر صورهم ومحاولة جلب بياناتهم
  void _checkMissingUserData() {
    try {
      final missingDataUsers = <String>[];

      // فحص جميع المقاعد للبحث عن مستخدمين بدون صور
      for (final seat in ZegoLiveAudioRoomManager().seatList) {
        final user = seat.currentUser.value;
        if (user != null) {
          // التحقق من وجود أي مصدر للصورة
          final hasAvatarUrl =
              user.avatarUrlNotifier.value?.isNotEmpty ?? false;
          final hasUserImage = user.userImage.value?.isNotEmpty ?? false;
          final hasImg = user.img?.isNotEmpty ?? false;

          if (!hasAvatarUrl && !hasUserImage && !hasImg) {
            missingDataUsers.add(user.iduser);
          }
        }
      }

      if (missingDataUsers.isNotEmpty) {
        _seatLog(
            "🔍 وُجد ${missingDataUsers.length} مستخدم بدون صور: $missingDataUsers",
            name: 'ZegoSeatItemView');

        // محاولة جلب البيانات للمستخدمين المفقودين
        ZEGOSDKManager()
            .zimService
            .queryUsersInfo(missingDataUsers)
            .then((result) {
          _seatLog(
              "🔄 تم جلب بيانات ${result.userList.length} مستخدم من ${missingDataUsers.length} مفقود",
              name: 'ZegoSeatItemView');

          for (final userInfo in result.userList) {
            try {
              // Prefer extendedData (rich metadata) and fallback to avatarUrl
              final String source = userInfo.extendedData.isNotEmpty
                  ? userInfo.extendedData
                  : userInfo.baseInfo.userAvatarUrl;
              final avatarData = AvatarData.fromEncodedString(source);
              _updateSeatUserData(
                  userInfo.baseInfo.userID, source, avatarData.imageUrl);
            } catch (e) {
              _seatLog(
                  "❌ خطأ في معالجة البيانات المفقودة للمستخدم ${userInfo.baseInfo.userID}: $e",
                  name: 'ZegoSeatItemView');
            }
          }
        }).catchError((error) {
          _seatLog("❌ فشل في جلب البيانات المفقودة: $error",
              name: 'ZegoSeatItemView');
        });
      }
    } catch (e) {
      _seatLog("❌ خطأ في فحص البيانات المفقودة: $e", name: 'ZegoSeatItemView');
    }
  }

  /// تحديث بيانات المستخدم في المقاعد مباشرة
  void _updateSeatUserData(String userId, String? avatarUrl, String? imageUrl) {
    try {
      // البحث عن المستخدم في قائمة المقاعد وتحديث بياناته
      for (final seat in ZegoLiveAudioRoomManager().seatList) {
        final user = seat.currentUser.value;
        if (user != null && user.iduser == userId) {
          _seatLog("🔄 تحديث بيانات المقعد للمستخدم $userId",
              name: 'ZegoSeatItemView');

          // تحديث avatarUrlNotifier
          if (avatarUrl != null && avatarUrl.isNotEmpty) {
            user.avatarUrlNotifier.value = avatarUrl;
            _seatLog("✅ تم تحديث avatarUrl للمستخدم $userId",
                name: 'ZegoSeatItemView');
          }

          // تحديث userImage كبديل
          if (imageUrl != null && imageUrl.isNotEmpty) {
            user.userImage.value = imageUrl;
            _seatLog("✅ تم تحديث userImage للمستخدم $userId",
                name: 'ZegoSeatItemView');
          }

          break;
        }
      }
    } catch (e) {
      _seatLog("❌ خطأ في تحديث بيانات المقعد للمستخدم $userId: $e",
          name: 'ZegoSeatItemView');
    }
  }

  void onRoomUserListUpdate(ZegoRoomUserListUpdateEvent event) {
    if (event.userList.isNotEmpty) {
      _seatLog("المستخدمون في الغرفة: ${event.userList.length}",
          name: 'ZegoSeatItemView');
    }

    if (event.updateType == ZegoUpdateType.Add) {
      final userIDList = <String>[];
      for (final element in event.userList) {
        userIDList.add(element.userID);
      }

      _seatLog("تحديث معلومات المستخدمين الجدد: $userIDList",
          name: 'ZegoSeatItemView');

      // استدعاء queryUsersInfo لجلب البيانات المحدثة
      ZEGOSDKManager().zimService.queryUsersInfo(userIDList).then((result) {
        _seatLog(
            "🔄 تم جلب معلومات ${result.userList.length} مستخدم من ${userIDList.length} مطلوب",
            name: 'ZegoSeatItemView');

        // تحديث البيانات في RoomCubit
        for (final userInfo in result.userList) {
          try {
            final String source = userInfo.extendedData.isNotEmpty
                ? userInfo.extendedData
                : userInfo.baseInfo.userAvatarUrl;
            final avatarData = AvatarData.fromEncodedString(source);
            _seatLog(
                "📥 بيانات المستخدم ${userInfo.baseInfo.userID}: source=${source.isNotEmpty ? 'موجود' : 'فارغ'}, imageUrl=${avatarData.imageUrl}",
                name: 'ZegoSeatItemView');

            // تحديث بيانات المقعد باستخدام المصدر المفضل
            _updateSeatUserData(
                userInfo.baseInfo.userID, source, avatarData.imageUrl);
          } catch (e) {
            _seatLog(
                "❌ خطأ في معالجة بيانات المستخدم ${userInfo.baseInfo.userID}: $e",
                name: 'ZegoSeatItemView');
          }
        }

        // التحقق من المستخدمين الذين لم يتم جلب بياناتهم
        final receivedUserIds =
            result.userList.map((u) => u.baseInfo.userID).toSet();
        final missingUserIds =
            userIDList.where((id) => !receivedUserIds.contains(id)).toList();
        if (missingUserIds.isNotEmpty) {
          _seatLog("⚠️ لم يتم جلب بيانات هؤلاء المستخدمين: $missingUserIds",
              name: 'ZegoSeatItemView');

          // محاولة إعادة جلب البيانات للمستخدمين المفقودين بعد تأخير قصير (20 مستخدم كحد أقصى)
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              _seatLog(
                  "🔄 إعادة محاولة جلب بيانات المستخدمين المفقودين: $missingUserIds",
                  name: 'ZegoSeatItemView');
              ZEGOSDKManager().zimService.queryUsersInfo(missingUserIds);
            }
          });
        }
      }).catchError((error) {
        _seatLog("❌ فشل في جلب معلومات المستخدمين: $error",
            name: 'ZegoSeatItemView');

        // محاولة إعادة الجلب بعد تأخير قصير في حالة الفشل (محسن للحد الأقصى 20 مستخدم)
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _seatLog(
                "🔄 إعادة محاولة جلب بيانات المستخدمين بعد فشل: $userIDList",
                name: 'ZegoSeatItemView');
            ZEGOSDKManager().zimService.queryUsersInfo(userIDList);
          }
        });
      });
    } else if (event.updateType == ZegoUpdateType.Delete) {
      final ids = event.userList.map((u) => u.userID);
      _seatLog("إزالة المستخدمين: $ids", name: 'ZegoSeatItemView');
      for (final id in ids) {
        widget.roomCubit.removeUserById(id);
        // تنظيف السجل لضمان عدم تراكم المعرفات بعد مغادرة المستخدم
        _positionRegistered.remove(id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    pageContext = context;
    return ValueListenableBuilder<UserEntity?>(
      valueListenable:
          ZegoLiveAudioRoomManager().seatList[widget.seatIndex].currentUser,
      builder: (context, user, _) {
        if (user != null) {
          return SizedBox(
              width: 72.w, height: 90.h, child: userSeatWidget(user));
        } else {
          return SizedBox(width: 72.w, height: 90.h, child: emptySeatView());
        }
      },
    );
  }

  Widget nameUserMic(UserEntity userInfo) {
    return ValueListenableBuilder<String?>(
      valueListenable: userInfo.nameUser,
      builder: (context, nameUser, child) {
        return ValueListenableBuilder<String?>(
          valueListenable: userInfo.avatarUrlNotifier,
          builder: (BuildContext context, String? avatarUrl, Widget? child) {
            final avatarData = AvatarData.fromEncodedString(avatarUrl);
            String vip = (avatarData.vipLevel != null &&
                    avatarData.vipLevel!.trim().isNotEmpty &&
                    avatarData.vipLevel!.toLowerCase() != 'null')
                ? avatarData.vipLevel!.trim()
                : ((userInfo.vip != null &&
                        userInfo.vip!.trim().isNotEmpty &&
                        userInfo.vip!.toLowerCase() != 'null')
                    ? userInfo.vip!.trim()
                    : '0');
            log("VIP RESOLVED vip: $vip (raw: ${avatarData.vipLevel}, userInfo.vip: ${userInfo.vip})");
            // Compute explicit VIP color and pass it to NameUserWidget to avoid any masking issues
            final int vipLevelInt = int.tryParse(vip) ?? 0;
            final Color vipColor = updateSVIPSettings(vipLevelInt, true);

            return Padding(
              padding: EdgeInsets.only(right: 2.w, left: 2.w, bottom: 4.h),
              child: NameUserWidget(
                name: nameUser ?? userInfo.name ?? "",
                textAlign: TextAlign.center,
                isWhite: true,
                vip: vip,
                nameColor: vipColor,
                useGradient: false,
                style: TextStyle(
                  color: updateSVIPSettings(vipLevelInt, true),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget userSeatWidget(UserEntity userInfo) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: 0,
          child: RepaintBoundary(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: widget.soundLevel,
                  builder: (context, currentSoundLevel, child) {
                    // استخدام مستوى الصوت الفعلي بدلاً من قيمة ثابتة
                    final shouldShowWave = currentSoundLevel > 0.25;

                    return ValueListenableBuilder<String?>(
                      valueListenable: userInfo.avatarUrlNotifier,
                      builder: (BuildContext context, String? avatarUrl,
                          Widget? child) {
                        final avatarData =
                            AvatarData.fromEncodedString(avatarUrl);
                        String vip = (avatarData.vipLevel != null &&
                                avatarData.vipLevel!.trim().isNotEmpty &&
                                avatarData.vipLevel!.toLowerCase() != 'null')
                            ? avatarData.vipLevel!.trim()
                            : ((userInfo.vip != null &&
                                    userInfo.vip!.trim().isNotEmpty &&
                                    userInfo.vip!.toLowerCase() != 'null')
                                ? userInfo.vip!.trim()
                                : '0');
                        // تحسين منطق اختيار مصدر الصورة مع أولوية أفضل
                        String? img;
                        if (avatarData.imageUrl != null &&
                            avatarData.imageUrl!.isNotEmpty) {
                          img = avatarData.imageUrl;
                        } else if (userInfo.userImage.value != null &&
                            userInfo.userImage.value!.isNotEmpty) {
                          img = userInfo.userImage.value;
                        } else if (userInfo.img != null &&
                            userInfo.img!.isNotEmpty) {
                          img = userInfo.img;
                        }

                        // Debug logging محسن لتتبع مشاكل الصور
                        try {
                          if (img == null || img.isEmpty) {
                            _seatLog(
                              'SeatItemView: ❌ NO IMAGE for user ${userInfo.iduser} | '
                              'name: ${userInfo.nameUser.value ?? userInfo.name} | '
                              'avatarUrl: $avatarUrl | decoded: ${avatarData.imageUrl} | '
                              'userImage: ${userInfo.userImage.value} | img: ${userInfo.img}',
                              name: 'ZegoSeatItemView',
                            );
                          } else {
                            _seatLog(
                              'SeatItemView: ✅ Using image for ${userInfo.iduser}: $img',
                              name: 'ZegoSeatItemView',
                            );
                          }
                        } catch (_) {}

                        // تحسين معالجة الإطارات مع تحقق أفضل
                        final frameID = avatarData.frameId;
                        String? frame;
                        if (frameID != null && frameID.toString().isNotEmpty) {
                          try {
                            frame =
                                SvgaUtils.getValidFilePath(frameID.toString());
                            if (frame == null &&
                                (avatarData.frameLink != null &&
                                    avatarData.frameLink!.isNotEmpty)) {
                              frame = avatarData
                                  .frameLink; // fallback to remote URL
                            }
                            if (frame != null) {
                              _seatLog(
                                  'SeatItemView: ✅ Frame resolved for ${userInfo.iduser}: ${frameID}${avatarData.frameLink != null ? ' (fallback URL)' : ''}',
                                  name: 'ZegoSeatItemView');
                            } else {
                              _seatLog(
                                  'SeatItemView: ❌ Frame missing for ${userInfo.iduser}: $frameID',
                                  name: 'ZegoSeatItemView');
                            }
                          } catch (e) {
                            _seatLog(
                                'SeatItemView: ❌ Frame error for ${userInfo.iduser}: $e',
                                name: 'ZegoSeatItemView');
                            frame = null;
                          }
                        } else if (avatarData.frameLink != null &&
                            avatarData.frameLink!.isNotEmpty) {
                          frame = avatarData.frameLink;
                        }
                        // Final fallback: use any pre-resolved frame path stored on the user entity
                        frame ??= userInfo.framePathNotifier.value;

                        // تسجيل موضع المستخدم مرة واحدة فقط بعد اكتمال الرسم لتقليل إعادة التنفيذ
                        if (!_positionRegistered.contains(userInfo.iduser)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              if (mounted) {
                                _registerUserPosition(userInfo.iduser);
                              }
                            });
                          });
                        }

                        return SizedBox(
                          width: 72.w,
                          height: 72.h,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              if (shouldShowWave)
                                RepaintBoundary(
                                  child: OverflowBox(
                                    maxWidth: double.infinity,
                                    maxHeight: double.infinity,
                                    child: CustomSVGAWidget(
                                      height: 81,
                                      width: 81,
                                      pathOfSvgaFile: _getWaveAsset(vip),
                                      clearsAfterStop: true,
                                      isRepeat: true,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              Container(
                                key:
                                    _userImageKey, // إضافة الـ key للحصول على الموضع
                                child: ImageUserSectionWithFram(
                                  height: frame != null ? 57.h : 45.h,
                                  width: frame != null ? 57.w : 45.w,
                                  radius: frame != null ? 20.r : 18.r,
                                  img: img,
                                  isImage: img != null && img.isNotEmpty,
                                  linkPath: frame,
                                  padding: 0,
                                  paddingImageOnly: 0,
                                  // إضافة معالجة أفضل لحالات الفشل
                                  key: ValueKey(
                                      '${userInfo.iduser}_${img}_$frame'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                _buildEmojiOverlay(userInfo),
                _buildPrivateEmojiOverlay(userInfo),
              ],
            ),
          ),
        ),
        Positioned(bottom: 0, right: 0, left: 0, child: nameUserMic(userInfo)),
      ],
    );
  }

  String _getWaveAsset(String? vipLevel) {
    final vip = vipLevel ?? '0';
    switch (vip) {
      case '1':
        return AssetsData.wave1;
      case '2':
        return AssetsData.wave2;
      case '3':
        return AssetsData.wave3;
      case '4':
        return AssetsData.wave4;
      case '5':
        return AssetsData.wave5;
      case '6':
        return AssetsData.wave6;
      default:
        return AssetsData.wave1;
    }
  }

  Widget _buildEmojiOverlay(UserEntity userInfo) {
    return BlocBuilder<EmojiCubit, EmojiState>(
      builder: (context, state) {
        if (state is EmojiSentSuccess &&
            senderIDEmoji == userInfo.iduser &&
            isEmojiShow) {
          final isSoHappy = state.emoji == "assets/smiles/so_happy.gif";
          return Image.asset(
            state.emoji,
            height: isSoHappy ? 75.h : 50.h,
            width: isSoHappy ? 75.w : 50.w,
            fit: BoxFit.cover,
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildPrivateEmojiOverlay(UserEntity userInfo) {
    return BlocBuilder<EmojiPrivateCubit, EmojiState>(
      builder: (context, state) {
        if (state is EmojiSentSuccessPrivate &&
            state.senderID == userInfo.iduser) {
          final isSoHappy = state.emoji == "assets/smiles/so_happy.gif";
          return Image.asset(
            state.emoji,
            height: isSoHappy ? 75.h : 50.h,
            width: isSoHappy ? 75.w : 50.w,
            fit: BoxFit.cover,
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget userAvatar(UserEntity userInfo) {
    return ValueListenableBuilder<String?>(
      valueListenable: userInfo.userImage,
      builder: (context, userImage, child) {
        return ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(30.r)),
          child: (userImage != null && userImage.isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: userImage,
                  fit: BoxFit.cover,
                  // إعدادات كاش محسنة لحجم المقعد الفعلي (45-57 نقطة)
                  // استخدام ضعف الحجم الفعلي لدعم الشاشات عالية الدقة
                  memCacheWidth: 120,
                  memCacheHeight: 120,
                  maxWidthDiskCache: 120,
                  maxHeightDiskCache: 120,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  progressIndicatorBuilder: (context, url, _) =>
                      const CupertinoActivityIndicator(),
                  errorWidget: (context, url, error) => child!,
                )
              : _buildFallbackAvatar(userInfo),
        );
      },
      child: _buildFallbackAvatar(userInfo),
    );
  }

  Widget _buildFallbackAvatar(UserEntity userInfo) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.grey,
        border: Border(bottom: BorderSide.none),
      ),
      child: Center(
        child: SizedBox(
          height: 22.h,
          child: AutoSizeText(
            userInfo.iduser.isNotEmpty ? userInfo.iduser.substring(0, 1) : "U",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Styles.textStyle12bold.copyWith(
              color: AppColors.whiteIcon,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget emptySeatView() {
    return ValueListenableBuilder<Map<String, Map<String, bool>>>(
      valueListenable: ZegoLiveAudioRoomManager().lockedSeatsPerRoomNotifier,
      builder: (context, lockedSeatsPerRoom, _) {
        Map<String, bool> lockedSeats = lockedSeatsPerRoom[widget.roomId] ?? {};
        bool isLocked = lockedSeats[widget.seatIndex.toString()] ?? false;

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 13),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .5),
                  width: 0.5.w,
                ),
              ),
              child: CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.black.withValues(alpha: .2),
                child: Icon(
                  isLocked
                      ? FontAwesomeIcons.lock
                      : FontAwesomeIcons.microphone,
                  color: AppColors.whiteWithOpacity5,
                  size: 22.h,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AutoSizeText(
                '${widget.indexmic + 1}',
                style: Styles.textStyle12bold.copyWith(
                  color: AppColors.whiteIcon,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void onRoomCommandReceived(
    OnRoomCommandReceivedEvent event,
    UserCubit userCubit,
    RoomCubit roomCubit,
  ) {
    try {
      final Map<String, dynamic> messageMap = jsonDecode(event.command);
      _seatLog('Parsed message map: $messageMap',
          name: 'onRoomCommandReceived');

      // معالجة الأوامر المتعلقة بالغرفة
      if (messageMap.containsKey('room_command_type')) {
        final type = messageMap['room_command_type'];
        final receiverID = messageMap['receiver_id'];

        if (receiverID == ZEGOSDKManager().currentUser!.iduser) {
          _handleRoomCommand(type);
        }
      }

      // معالجة الرموز التعبيرية
      if (messageMap.containsKey('type') && messageMap['type'] != null) {
        senderIDEmoji = messageMap['senderID'];
        _handleEmojiCommand(messageMap);
      }
    } catch (e) {
      _seatLog('Failed to parse command: $e', name: 'onRoomCommandReceived');
    }
  }

  void _handleRoomCommand(String type) {
    switch (type) {
      case 'muteSpeaker':
        _seatLog('You have been muted by the host');
        try {
          context.read<LiveKitAudioCubit>().toggleMic(false);
        } catch (_) {}
        break;
      case 'unMuteSpeaker':
        _seatLog('You have been unmuted by the host');
        try {
          context.read<LiveKitAudioCubit>().toggleMic(true);
        } catch (_) {}
        break;
      case 'kickOutRoom':
        _seatLog('You have been kicked out of the room');
        RoomExitService.exitRoom(
            context: context,
            userCubit: widget.userCubit,
            roomCubit: widget.roomCubit,
            delayDuration: Duration(milliseconds: 500));
        break;
    }
  }

  void _handleEmojiCommand(Map<String, dynamic> messageMap) {
    final int? timestamp = messageMap['timestamp'];
    if (timestamp != null) {
      final DateTime messageTime =
          DateTime.fromMillisecondsSinceEpoch(timestamp);
      final DateTime currentTime = DateTime.now();
      final Duration difference = currentTime.difference(messageTime);
      isEmojiShow = difference.inSeconds <= 4;

      if (mounted) {
        setState(() {});
      }

      if (isEmojiShow) {
        final String? emojiName = messageMap['content'];
        if (emojiName != null) {
          final emojiEntity = emojiEntitiesGif.firstWhere(
              (emoji) => emoji.name == emojiName,
              orElse: () => emojiEntitiesGif.first);
          context.read<EmojiCubit>().selectEmoji(emojiEntity.path);

          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) {
              isEmojiShow = false;
              setState(() {});
            }
          });
        }
      }
    }
  }

  // zim listener methods
  void onInComingRoomRequest(OnInComingRoomRequestReceivedEvent event) {}

  void onInComingRoomRequestCancelled(
      OnInComingRoomRequestCancelledEvent event) {}

  void onInComingRoomRequestTimeOut() {}

  void onOutgoingRoomRequestAccepted(OnOutgoingRoomRequestAcceptedEvent event) {
    isApplyStateNoti.value = false;
    for (final seat in ZegoLiveAudioRoomManager().seatList) {
      if (seat.currentUser.value == null) {
        ZegoLiveAudioRoomManager()
            .takeSeat(seat.seatIndex, widget.roomId)
            .then((result) {
          if (mounted &&
              ((result == null) ||
                  result.errorKeys
                      .contains(ZEGOSDKManager().currentUser!.iduser))) {}
        }).catchError((error) {});
        break;
      }
    }
  }

  void onOutgoingRoomRequestRejected(OnOutgoingRoomRequestRejectedEvent event) {
    isApplyStateNoti.value = false;
    currentRequestID = null;
  }

  void onExpressRoomStateChanged(ZegoRoomStateEvent event) {
    debugAppLogger.debug('AudioRoomPage:onExpressRoomStateChanged: $event');

    if ((event.reason == ZegoRoomStateChangedReason.KickOut) ||
        (event.reason == ZegoRoomStateChangedReason.ReconnectFailed) ||
        (event.reason == ZegoRoomStateChangedReason.LoginFailed)) {}
  }

  void onZIMRoomStateChanged(ZIMServiceRoomStateChangedEvent event) {
    debugAppLogger.debug('AudioRoomPage:onZIMRoomStateChanged: $event');
    if (event.state == ZIMRoomState.disconnected) {
      _seatLog("HomeView ZegoSeatItemView ZIMRoomState.disconnected");
      RoomExitService.exitRoom(
          context: context,
          userCubit: widget.userCubit,
          roomCubit: widget.roomCubit,
          delayDuration: Duration(milliseconds: 500));
    }
  }

  void onZIMConnectionStateChanged(
      ZIMServiceConnectionStateChangedEvent event) {
    debugAppLogger.debug('AudioRoomPage:onZIMConnectionStateChanged: $event');

    if (event.state == ZIMConnectionState.disconnected) {
      _seatLog("HomeView ZegoSeatItemView ZIMConnectionState.disconnected");
      RoomExitService.exitRoom(
          context: context,
          userCubit: widget.userCubit,
          roomCubit: widget.roomCubit,
          delayDuration: Duration(milliseconds: 500));
    }
  }
}

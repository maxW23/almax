import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/domain/entities/avatar_data_zego.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/image_user_section_with_fram.dart';
import 'package:lklk/features/room/presentation/views/widgets/name_user_widget.dart';
import 'package:lklk/core/constants/svip_colors.dart';
import 'package:lklk/live_audio_room_manager.dart';

/// نسخة محسّنة من ZegoSeatItemView مع تحسينات للأداء العالي
/// - تقليل عدد ValueListenableBuilder
/// - تحسين إدارة الذاكرة للصور
/// - تحسين عرض موجات الصوت
/// - تقليل إعادة البناء غير الضرورية
class OptimizedZegoSeatItemView extends StatefulWidget {
  const OptimizedZegoSeatItemView({
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
  State<OptimizedZegoSeatItemView> createState() =>
      _OptimizedZegoSeatItemViewState();
}

class _OptimizedZegoSeatItemViewState extends State<OptimizedZegoSeatItemView>
    with AutomaticKeepAliveClientMixin {
  // Cache للبيانات المعالجة لتجنب إعادة المعالجة
  String? _cachedAvatarUrl;
  AvatarData? _cachedAvatarData;
  String? _cachedUserName;
  String? _cachedVipLevel;
  String? _cachedImageUrl;
  String? _cachedFramePath;

  // تتبع حالة الصوت لتجنب التحديثات غير الضرورية
  bool _lastSoundState = false;

  // مؤقت لتجميع تحديثات الصوت
  Timer? _soundUpdateTimer;
  bool _pendingSoundUpdate = false;

  @override
  bool get wantKeepAlive => true; // الحفاظ على الحالة لتجنب إعادة البناء

  @override
  void initState() {
    super.initState();
    // تأجيل المراقبة الثقيلة لتحسين وقت البناء الأولي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initOptimizedListeners();
    });
  }

  void _initOptimizedListeners() {
    // مراقبة تحديثات الصوت مع تجميع (throttling)
    widget.soundLevel.addListener(_onSoundLevelChanged);
  }

  void _onSoundLevelChanged() {
    if (!mounted) return;

    final currentLevel = widget.soundLevel.value;
    final shouldShowWave = currentLevel > 0.25;

    // تجنب التحديثات غير الضرورية
    if (shouldShowWave == _lastSoundState) return;

    _lastSoundState = shouldShowWave;

    // تجميع التحديثات لتجنب الإفراط في إعادة البناء
    if (!_pendingSoundUpdate) {
      _pendingSoundUpdate = true;
      _soundUpdateTimer?.cancel();
      _soundUpdateTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _pendingSoundUpdate = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    widget.soundLevel.removeListener(_onSoundLevelChanged);
    _soundUpdateTimer?.cancel();
    super.dispose();
  }

  /// معالجة وتخزين بيانات المستخدم مؤقتاً لتجنب إعادة المعالجة
  void _processCachedUserData(UserEntity userInfo, String? avatarUrl) {
    if (_cachedAvatarUrl == avatarUrl) return; // لا حاجة لإعادة المعالجة

    _cachedAvatarUrl = avatarUrl;
    _cachedAvatarData = AvatarData.fromEncodedString(avatarUrl);
    // Resolve VIP with robust fallback like frame fix
    final String? parsedVip = _cachedAvatarData?.vipLevel;
    final String? userVip = userInfo.vip;
    _cachedVipLevel = (parsedVip != null && parsedVip.trim().isNotEmpty && parsedVip.toLowerCase() != 'null')
        ? parsedVip.trim()
        : ((userVip != null && userVip.trim().isNotEmpty && userVip.toLowerCase() != 'null')
            ? userVip.trim()
            : '0');
    _cachedImageUrl = _cachedAvatarData?.imageUrl ?? userInfo.userImage.value;
    _cachedFramePath =
        SvgaUtils.getValidFilePath(_cachedAvatarData?.frameId?.toString());
    _cachedUserName = userInfo.nameUser.value ?? userInfo.name ?? "";

    // Debug logging: trace resolved avatar data for this seat
    // ignore: avoid_print
    AppLogger.debug(
        '[OptimizedSeatItem] seatIndex=${widget.seatIndex} userId=${userInfo.iduser} avatarUrlEncoded=${avatarUrl ?? 'null'} decoded.imageUrl=${_cachedAvatarData?.imageUrl ?? 'null'} fallback.userImage=${userInfo.userImage.value ?? 'null'} resolved.img=${_cachedImageUrl ?? 'null'} framePath=${_cachedFramePath ?? 'null'} vip.resolved=${_cachedVipLevel} (raw=${parsedVip}, user.vip=${userVip})');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // مطلوب لـ AutomaticKeepAliveClientMixin

    return ValueListenableBuilder<UserEntity?>(
      valueListenable:
          ZegoLiveAudioRoomManager().seatList[widget.seatIndex].currentUser,
      builder: (context, user, _) {
        if (user != null) {
          return SizedBox(
            width: 72.w,
            height: 90.h,
            child: _buildOptimizedUserSeat(user),
          );
        } else {
          return SizedBox(
            width: 72.w,
            height: 90.h,
            child: _buildOptimizedEmptySeat(),
          );
        }
      },
    );
  }

  Widget _buildOptimizedUserSeat(UserEntity userInfo) {
    return ValueListenableBuilder<String?>(
      valueListenable: userInfo.avatarUrlNotifier,
      builder: (context, avatarUrl, _) {
        // معالجة البيانات مع التخزين المؤقت
        _processCachedUserData(userInfo, avatarUrl);

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 0,
              child: RepaintBoundary(
                child: _buildOptimizedAvatarSection(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: RepaintBoundary(
                child: _buildOptimizedNameSection(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptimizedAvatarSection() {
    return SizedBox(
      width: 72.w,
      height: 72.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // عرض موجة الصوت فقط عند الحاجة
          if (_lastSoundState)
            OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: CustomSVGAWidget(
                height: 81,
                width: 81,
                pathOfSvgaFile: _getOptimizedWaveAsset(_cachedVipLevel),
                clearsAfterStop: true,
                isRepeat: true,
                fit: BoxFit.cover,
              ),
            ),
          // صورة المستخدم مع الإطار
          ImageUserSectionWithFram(
            height: _cachedFramePath != null ? 57.h : 45.h,
            width: _cachedFramePath != null ? 57.w : 45.w,
            radius: _cachedFramePath != null ? 20.r : 18.r,
            img: _cachedImageUrl,
            isImage: _cachedImageUrl != null && _cachedImageUrl!.isNotEmpty,
            linkPath: _cachedFramePath,
            padding: 0,
            paddingImageOnly: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedNameSection() {
    return Padding(
      padding: EdgeInsets.only(right: 2.w, left: 2.w, bottom: 4.h),
      child: NameUserWidget(
        name: _cachedUserName ?? "",
        textAlign: TextAlign.center,
        isWhite: true,
        vip: _cachedVipLevel ?? '0',
        nameColor: updateSVIPSettings(int.tryParse(_cachedVipLevel ?? '0') ?? 0, true),
        useGradient: false,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildOptimizedEmptySeat() {
    return ValueListenableBuilder<Map<String, Map<String, bool>>>(
      valueListenable: ZegoLiveAudioRoomManager().lockedSeatsPerRoomNotifier,
      builder: (context, lockedSeatsPerRoom, _) {
        final lockedSeats = lockedSeatsPerRoom[widget.roomId] ?? {};
        final isLocked = lockedSeats[widget.seatIndex.toString()] ?? false;

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

  String _getOptimizedWaveAsset(String? vipLevel) {
    // استخدام البيانات المخزنة مؤقتاً
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
}

import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdsBottomsheet extends StatefulWidget {
  const AdsBottomsheet({super.key, required this.userCubit});
  final UserCubit userCubit;
  @override
  State<AdsBottomsheet> createState() => _AdsBottomsheetState();
  static Future<void> showBasicModalBottomSheet(
      BuildContext context, UserCubit userCubit) async {
    await showModalBottomSheet(
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) => AdsBottomsheet(userCubit: userCubit),
    );
  }
}

class _AdsBottomsheetState extends State<AdsBottomsheet> {
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  String? _errorMessage;
  DateTime? _lastAdTime;
  bool _cooldownActive = false;
  Duration _remainingTime = Duration.zero;
  Timer? _cooldownTimer;
  String _adsNumber = "0";
  bool _maxAdsReached = false;
  @override
  void initState() {
    super.initState();
    _loadAdsNumber();
    _loadLastAdTime();
    _loadRewardedAd();
  }

  Future<void> _loadAdsNumber() async {
    final adsNumber = await widget.userCubit.myAdsNumber();
    int currentAds = int.tryParse(adsNumber) ?? 0;

    setState(() {
      _adsNumber = adsNumber;
      _maxAdsReached = currentAds >= 15;
    });
  }

  Future<void> _loadLastAdTime() async {
    final prefs = await SharedPreferences.getInstance();
    int? lastAdTimeMillis = prefs.getInt('lastAdTime');
    if (lastAdTimeMillis != null) {
      setState(() {
        _lastAdTime = DateTime.fromMillisecondsSinceEpoch(lastAdTimeMillis);
      });
      _updateCooldownState();
    }
  }

  void _updateCooldownState() {
    if (_lastAdTime == null) {
      setState(() => _cooldownActive = false);
      return;
    }

    final difference = DateTime.now().difference(_lastAdTime!);
    if (difference < const Duration(minutes: 1)) {
      setState(() {
        _cooldownActive = true;
        _remainingTime = const Duration(minutes: 1) - difference;
      });

      _cooldownTimer?.cancel();
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final newDifference = DateTime.now().difference(_lastAdTime!);
        if (newDifference >= const Duration(minutes: 1)) {
          timer.cancel();
          setState(() => _cooldownActive = false);
        } else {
          setState(() {
            _remainingTime = const Duration(minutes: 1) - newDifference;
          });
        }
      });
    } else {
      setState(() => _cooldownActive = false);
    }
  }

  void _loadRewardedAd() {
    setState(() => _isAdLoaded = false); // إعادة تعيين حالة التحميل

    RewardedAd.load(
      adUnitId: 'ca-app-pub-3966750631612930/2914324019',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          log('AADDSS loaded: ${ad.responseInfo}');
          setState(() {
            _rewardedAd = ad;
            _isAdLoaded = true;
            _errorMessage = null; // مسح الأخطاء السابقة
          });
        },
        onAdFailedToLoad: (error) {
          log('AADDSS failed: ${error.code} - ${error.message}');
          setState(() => _errorMessage = S.of(context).adLoadError);
          // إعادة المحاولة بعد 5 ثوانٍ
          Future.delayed(const Duration(seconds: 5), _loadRewardedAd);
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          log('AADDSS dismissed');
          ad.dispose();
          Navigator.pop(context);
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          log('AADDSS failed to show: ${error.message}');
          ad.dispose();
          _loadRewardedAd();
          setState(() => _errorMessage = S.of(context).adShowError);
        },
      );

      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        log('AADDSS Reward earned: ${reward.amount} ${reward.type}');
        _addCoinsToUser(reward.amount);
      });
      setState(() => _rewardedAd = null);
    } else {
      log('AADDSS not ready');
      setState(() => _errorMessage = S.of(context).adNotReady);
    }
  }

  Future<void> _addCoinsToUser(num coins) async {
    try {
      await widget.userCubit.ads();
      final prefs = await SharedPreferences.getInstance();
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('lastAdTime', currentTime);
      setState(() {
        _errorMessage = S.of(context).rewardReceived;
        _lastAdTime = DateTime.fromMillisecondsSinceEpoch(currentTime);
      });
      _updateCooldownState();
    } catch (e) {
      log('AADDSS Reward error: $e');
      setState(() => _errorMessage = S.of(context).rewardError);
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20).copyWith(bottom: 30),
      decoration: _bottomSheetDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          const SizedBox(height: 15),
          _buildTitle(),
          const SizedBox(height: 10),
          _buildTitleInfo(),
          const SizedBox(height: 25),
          _buildWatchButton(),
          if (_errorMessage != null) _buildErrorMessage(),
        ],
      ),
    );
  }

  BoxDecoration _bottomSheetDecoration() => const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        gradient: LinearGradient(
          colors: [AppColors.secondColorDark, AppColors.secondColor],
          stops: [0.1, 0.9],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 15,
            spreadRadius: 2,
            offset: Offset(0, -5),
          )
        ],
      );

  Widget _buildDragHandle() => Container(
        width: 45,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
        ),
      );

  Widget _buildTitle() => AutoSizeText(
        S.of(context).watchAdButton,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      );
  Widget _buildTitleInfo() => AutoSizeText(
        S.of(context).adsNumber(_adsNumber),
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: Colors.white54,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      );

  Widget _buildWatchButton() {
    if (_maxAdsReached) {
      return Column(
        children: [
          AutoSizeText(
            S.of(context).maxAdsReachedError,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_cooldownActive) {
      return Column(
        children: [
          AutoSizeText(
            S.of(context).cooldownMessage(
                  _remainingTime.inMinutes
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0'),
                  _remainingTime.inSeconds
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0'),
                ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            value: 1 - (_remainingTime.inSeconds / 60),
          ),
        ],
      );
    }

    if (!_isAdLoaded) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      onPressed: _showRewardedAd,
      icon: const Icon(Icons.play_circle_fill_rounded,
          size: 28, color: AppColors.secondColorDark),
      label: AutoSizeText(
        S.of(context).watchAdButton,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.secondColorDark,
        ),
      ),
    );
  }

  Widget _buildErrorMessage() => Padding(
        padding: const EdgeInsets.only(top: 15),
        child: AutoSizeText(
          _errorMessage!,
          style: const TextStyle(
            color: AppColors.amber,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
}

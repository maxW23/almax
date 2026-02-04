// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lklk/core/services/auth_service.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/core/zego_delegate.dart';
import 'package:lklk/features/auth/domain/use_cases/google_signin_use_case.dart';
import 'package:lklk/features/auth/presentation/view/auth_view.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/item_widget.dart';
import 'package:lklk/features/profile_users/presentaion/views/privacy_policy_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/language_settings_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/user_profile_edit_page.dart';
import 'package:lklk/features/room/presentation/views/widgets/flages_countrys.dart';
import 'package:lklk/features/profile_users/presentaion/views/help_screen.dart';
import 'package:lklk/core/utils/functions/image_helper.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/features/home/presentation/manger/show_or_hide_vip5/show_or_hide_vip5_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/code_cubit/code_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lklk/zego_sdk_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.user,
    required this.userCubit,
    required this.roomCubit,
  });
  final UserEntity user;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedLanguage;
  @override
  void initState() {
    super.initState();
    // Load current language from cubit
    final languageCubit = context.read<LanguageCubit>();
    _selectedLanguage = languageCubit.state.languageCode;
  }

  Future<void> clearDownloadsAndCache() async {
    try {
      final downloadDir =
          Directory("${AppDirectories.instance.appDirectory.path}/downloads");
      if (downloadDir.existsSync()) {
        downloadDir.deleteSync(recursive: true);
      }
      if (Hive.isBoxOpen('giftCacheBox')) {
        final box = Hive.box<List>('giftCacheBox');
        await box.clear();
      } else {
        final box = await Hive.openBox<List>('giftCacheBox');
        await box.clear();
        await box.close();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('askForGiftDownload', true);
      SnackbarHelper.showMessage(context, S.of(context).cacheCleared);
    } catch (e) {
      SnackbarHelper.showMessage(context, S.of(context).cacheClearError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguageCubit, Locale>(
      listener: (context, locale) {
        setState(() => _selectedLanguage = locale.languageCode);
      },
      child: Directionality(
        textDirection: getTextDirection(_selectedLanguage),
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/Settings_icon.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 8),
                  AutoSizeText(
                    S.of(context).settings,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              elevation: 0,
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              children: [
                if (widget.user.vip == '5')
                  BlocProvider<ShowOrHideVip5Cubit>(
                    create: (context) => ShowOrHideVip5Cubit(),
                    child: ShowOrHideVip5(user: widget.user),
                  ),
                if (widget.user.vip == '5') const SizedBox(height: 10),

                // ===== Personal Information =====
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: AutoSizeText(
                    _selectedLanguage == 'ar' ? 'معلومات شخصية' : 'Personal Information',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                // Profile (navigate to UserProfileEditPage)
                ItemWidget(
                  selectedLanguage: _selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: _selectedLanguage == 'ar' ? 'الملف الشخصي' : 'Profile',
                  svgAsset: 'assets/icons/settings_icons/profile_icon.svg',
                  fillColor: false,
                  showDivider: true,
                  onTap: () {
                    final u = context.read<UserCubit>().user ?? widget.user;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UserProfileEditPage(user: u, userCubit: widget.userCubit),
                      ),
                    );
                  },
                ),
                // Profile Image change
                ItemWidget(
                  selectedLanguage: _selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: _selectedLanguage == 'ar' ? 'الصورة الشخصية' : 'Profile Image',
                  svgAsset: 'assets/icons/room_settings/room_image_icon.svg',
                  fillColor: false,
                  showDivider: true,
                  onTap: () async => await _changeProfileImage(context),
                ),
                // Country
                ItemWidget(
                  selectedLanguage: _selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).country,
                  svgAsset: 'assets/icons/room_settings/room_flag_icon.svg',
                  fillColor: false,
                  showDivider: true,
                  onTap: () async {
                    String? newCountry = await showDialog<String>(
                      context: context,
                      builder: (context) => const CountryFlagPicker(),
                    );
                    if (newCountry != null) {
                      await widget.userCubit.editUserCountry(newCountry);
                      widget.userCubit.getProfileUser("SettingsPage country");
                      SnackbarHelper.showMessage(
                        context,
                        '${S.of(context).country} $newCountry \n${S.of(context).maybeTheChangesTakeAboutTenSeconds}',
                        durationinMilli: 3500,
                      );
                    }
                  },
                ),

                // ===== General Settings =====
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: AutoSizeText(
                    S.of(context).settings,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),

                // Language (page with toggles)
                ItemWidget(
                  selectedLanguage: _selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).language,
                  svgAsset: 'assets/icons/settings_icons/Language_icon.svg',
                  fillColor: false,
                  showDivider: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LanguageSettingsPage()),
                    );
                  },
                ),

                // Clear gifts cache
                ItemWidget(
                  selectedLanguage: _selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).clearGiftsCache,
                  svgAsset: 'assets/icons/settings_icons/clear_cache_icon.svg',
                  fillColor: false,
                  showDivider: true,
                  onTap: () async => await _showClearCacheSheet(context),
                ),

                // ===== Privacy Settings =====
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: AutoSizeText(
                    _selectedLanguage == 'ar' ? 'الخصوصية' : 'Privacy Settings',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                // Privacy policy (moved here)
                ItemWidget(
                  selectedLanguage: _selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).privacypolicy,
                  svgAsset: 'assets/icons/room_settings/room_lock.svg',
                  fillColor: false,
                  showDivider: true,
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                    );
                  },
                ),
                // Report a problem
                ItemWidget(
                  selectedLanguage: _selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: _selectedLanguage == 'ar' ? 'تبليغ عن مشكلة' : 'Report a Problem',
                  svgAsset: 'assets/icons/settings_icons/Report_Problem_icon.svg',
                  fillColor: false,
                  showDivider: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HelpScreen(initialCategory: S.of(context).problem_category),
                      ),
                    );
                  },
                ),
                // Contact Us
                ItemWidget(
                  selectedLanguage: _selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: _selectedLanguage == 'ar' ? 'اتصل بنا' : 'Contact Us',
                  svgAsset: 'assets/icons/settings_icons/contact_us_icon.svg',
                  fillColor: false,
                  showDivider: true,
                  onTap: () {
                    final label = _selectedLanguage == 'ar' ? 'تواصل' : 'Contact';
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HelpScreen(initialCategory: label),
                      ),
                    );
                  },
                ),

                // Account Settings
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: AutoSizeText(
                  S.of(context).accountSettings,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),

                // Delete account (bottom sheet)
                ItemWidget(
                  selectedLanguage: _selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).deleteYourAccount,
                  svgAsset: 'assets/icons/settings_icons/Delete_Account_icon.svg',
                  fillColor: false,
                  showDivider: true,
                  onTap: () => _showDeleteAccountSheet(context),
                ),

                // Sign out (bottom sheet)
                ItemWidget(
                  selectedLanguage: _selectedLanguage,
                  roomCubit: widget.roomCubit,
                  title: S.of(context).logOut,
                  svgAsset: 'assets/icons/settings_icons/signout_icon.svg',
                  fillColor: false,
                  showDivider: false,
                  onTap: () => _showSignOutSheet(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== Bottom sheets & actions =====
  Future<void> _showSignOutSheet(BuildContext context) async {
    await _showActionBottomSheet(
      context: context,
      iconAsset: 'assets/icons/settings_icons/Sign_out_X.svg',
      titleText: S.of(context).warningTitle,
      messageText: _selectedLanguage == 'ar'
          ? 'هل تريد تسجيل الخروج من هذا الجهاز؟'
          : 'You want to sign out from this device',
      confirmText: S.of(context).logOut,
      confirmColor: Colors.blue,
      onConfirm: () async => await _performLogout(context),
    );
  }

  Future<void> _showDeleteAccountSheet(BuildContext context) async {
    await _showActionBottomSheet(
      context: context,
      iconAsset: 'assets/icons/settings_icons/delete_account_X.svg',
      titleText: S.of(context).warningTitle,
      messageText: S.of(context).deleteWarningMessage,
      confirmText: S.of(context).confirm,
      confirmColor: Colors.blue,
      onConfirm: () async => await _performDeleteAccount(context),
    );
  }

  Future<void> _showActionBottomSheet({
    required BuildContext context,
    required String iconAsset,
    required String titleText,
    required String messageText,
    required String confirmText,
    required Color confirmColor,
    required Future<void> Function() onConfirm,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
                SvgPicture.asset(iconAsset, width: 72, height: 72),
                const SizedBox(height: 12),
                AutoSizeText(
                  titleText,
                  style: const TextStyle(
                    color: Color(0xFFFF0000),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                AutoSizeText(
                  messageText,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF0000),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: AutoSizeText(S.of(context).cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await onConfirm();
                        },
                        child: AutoSizeText(confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final googleSignInUseCase = GoogleSignInUseCase();
    await googleSignInUseCase.logout();
    await AuthService.clearUserAndTokenFromSharedPreferences();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await DefaultCacheManager().emptyCache();
    await Hive.deleteFromDisk();
    await ZEGOSDKManager().logoutRoom();
    ZegoDelegate().stopMediaPlayer();
    ZegoDelegate().dispose();
    await ZEGOSDKManager().disconnectUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => AuthView(
          roomCubit: context.read<RoomCubit>(),
          userCubit: context.read<UserCubit>(),
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _performDeleteAccount(BuildContext context) async {
    final googleSignInUseCase = GoogleSignInUseCase();
    await googleSignInUseCase.logout();
    await widget.userCubit.deleteAccount();
    await AuthService.clearUserAndTokenFromSharedPreferences();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await DefaultCacheManager().emptyCache();
    await Hive.deleteFromDisk();
    ZegoDelegate().stopMediaPlayer();
    await ZEGOSDKManager().logoutRoom();
    await ZEGOSDKManager().disconnectUser();
    ZegoDelegate().dispose();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => AuthView(
          roomCubit: widget.roomCubit,
          userCubit: widget.userCubit,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  // Change profile image using the same flow as ImageUserSectionWithEdit
  Future<void> _changeProfileImage(BuildContext context) async {
    File? file = await ImageHelper.pickImage(
      cropToSquare: true,
      targetHeight: 400,
      targetWidth: 400,
      isCrop: true,
      context: context,
      useCustomCropper: true,
    );
    if (file == null) {
      SnackbarHelper.showMessage(
        context,
        _selectedLanguage == 'ar'
            ? 'الصورة كبيرة جدًا ولا يمكن تحميلها'
            : 'Image is too large and cannot be uploaded',
      );
      return;
    }
    await widget.userCubit.editUserProfile(image: file);
    await widget.userCubit.getProfileUser("SettingsPage change image");
    SnackbarHelper.showMessage(
      context,
      '${S.of(context).waitforcheckyouimage} ',
    );
  }

  // Bottom sheet confirmation for clearing temporary gifts cache
  Future<void> _showClearCacheSheet(BuildContext context) async {
    final title = S.of(context).warningTitle;
    final message = _selectedLanguage == 'ar'
        ? 'هل تريد حذف كاش الهدايا المؤقتة من هذا الجهاز؟'
        : 'Do you want to clear the temporary gifts cache from this device?';
    await _showActionBottomSheet(
      context: context,
      iconAsset: 'assets/icons/settings_icons/clear_cache_icon.svg',
      titleText: title,
      messageText: message,
      confirmText: S.of(context).clearGiftsCache,
      confirmColor: Colors.blue,
      onConfirm: () async => await clearDownloadsAndCache(),
    );
  }
}

class LogOutSection extends StatelessWidget {
  const LogOutSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: AutoSizeText(
          S.of(context).logOut,
          style: const TextStyle(
            color: const Color(0xFFFF0000),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () async {
          final googleSignInUseCase = GoogleSignInUseCase();
          await googleSignInUseCase.logout();
          await AuthService.clearUserAndTokenFromSharedPreferences();
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          await DefaultCacheManager().emptyCache();
          await Hive.deleteFromDisk();
          await ZEGOSDKManager().logoutRoom();
          ZegoDelegate().stopMediaPlayer();
          ZegoDelegate().dispose();
          await ZEGOSDKManager().disconnectUser();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AuthView(
                roomCubit: context.read<RoomCubit>(),
                userCubit: context.read<UserCubit>(),
              ),
            ),
            (Route<dynamic> route) => false,
          );
        },
      ),
    );
  }
}

class PrivacyPolicySection extends StatelessWidget {
  const PrivacyPolicySection({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PrivacyPolicyPage(),
          ),
        );
      },
      child: AutoSizeText(
        S.of(context).privacypolicy,
        textAlign: TextAlign.start,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DeleteAccountSection extends StatelessWidget {
  const DeleteAccountSection({
    super.key,
    required this.widget,
    required this.selectedLanguage,
  });

  final SettingsPage widget;
  final String selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AutoSizeText(
        S.of(context).deleteYourAccount,
        style: const TextStyle(
          color: const Color(0xFFFF0000),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        showDeleteConfirmationDialog(context, selectedLanguage);
      },
    );
  }

  void showDeleteConfirmationDialog(
      BuildContext context, String selectedLanguage) {
    final originalContext = context;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Directionality(
          textDirection: getTextDirection(selectedLanguage),
          child: AlertDialog(
            title: AutoSizeText(
              S.of(context).warningTitle,
              style: const TextStyle(
                color: const Color(0xFFFF0000),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: AutoSizeText(
              S.of(context).deleteWarningMessage,
              style: const TextStyle(fontSize: 16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: AutoSizeText(
                  S.of(context).cancel,
                  style: const TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await deleteAccountMethod(originalContext);
                },
                child: AutoSizeText(
                  S.of(context).confirm,
                  style: const TextStyle(
                    color: const Color(0xFFFF0000),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> deleteAccountMethod(BuildContext context) async {
    final googleSignInUseCase = GoogleSignInUseCase();
    await googleSignInUseCase.logout();
    await widget.userCubit.deleteAccount();
    await AuthService.clearUserAndTokenFromSharedPreferences();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await DefaultCacheManager().emptyCache();
    await Hive.deleteFromDisk();
    ZegoDelegate().stopMediaPlayer();
    await ZEGOSDKManager().logoutRoom();
    await ZEGOSDKManager().disconnectUser();
    ZegoDelegate().dispose();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => AuthView(
          roomCubit: widget.roomCubit,
          userCubit: widget.userCubit,
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }
}

class ShowOrHideVip5 extends StatefulWidget {
  const ShowOrHideVip5({super.key, required this.user});
  final UserEntity user;
  @override
  State<ShowOrHideVip5> createState() => _ShowOrHideVip5State();
}

class _ShowOrHideVip5State extends State<ShowOrHideVip5> {
  late bool isLoading;
  late bool isActive;

  @override
  void initState() {
    isLoading = false;
    isActive = widget.user.display == 'on';
    super.initState();
  }

  Future<void> _fetchUserProfile() async {
    final user = await context
        .read<UserCubit>()
        .getProfileUser("ShowOrHideVip5 _fetchUserProfile");
    if (user != null) {
      setState(() {
        isActive = user.display == 'on';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShowOrHideVip5Cubit, ShowOrHideVip5State>(
      listener: (context, state) {
        if (state is ShowOrHideVip5Done) {
          _fetchUserProfile();
          setState(() {
            isLoading = false;
          });
        } else if (state is ShowOrHideVip5Error) {
          setState(() {
            isLoading = false;
          });
          SnackbarHelper.showMessage(
            context,
            S.of(context).failedToUpdateVIP5Status,
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText(
            S.of(context).showVIP5,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Switch(
            activeThumbColor: AppColors.successColor,
            value: isActive,
            onChanged: isLoading
                ? null
                : (value) {
                    setState(() {
                      isActive = value;
                      isLoading = true;
                    });
                    context.read<ShowOrHideVip5Cubit>().showOrHideVIP5();
                  },
          ),
        ],
      ),
    );
  }
}

class CodeSection extends StatelessWidget {
  const CodeSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CodeCubit(),
      child: const CodeSectionBody(),
    );
  }
}

class CodeSectionBody extends StatelessWidget {
  const CodeSectionBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AutoSizeText(
          S.of(context).codeEvent,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        BlocBuilder<CodeCubit, String?>(
          bloc: context.read<CodeCubit>()..fetchCode(),
          builder: (context, code) {
            if (code == "loading") {
              return const SizedBox(
                height: 20,
                width: 20,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.black,
                  ),
                ),
              );
            } else if (code == null) {
              return AutoSizeText(
                "${S.of(context).codeIs} : $code",
                textAlign: TextAlign.center,
                style: const TextStyle(color: const Color(0xFFFF0000)),
              );
            } else if (code.startsWith('Error')) {
              return AutoSizeText(code,
                  style: const TextStyle(color: const Color(0xFFFF0000)));
            } else {
              return InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: code));
                  SnackbarHelper.showMessage(
                    context,
                    S.of(context).doneCopiedToClipboard,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      code,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.copy,
                      size: 14,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class BorderRowWhite extends StatelessWidget {
  const BorderRowWhite({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/core/widgets/linear_gradient_widget.dart';
import 'package:lklk/core/widgets/language_switcher.dart';
import 'package:lklk/features/auth/presentation/view/widget/animated_auth_body.dart';
import 'package:lklk/features/auth/presentation/view/widget/privacy_agreement_widget.dart';
import 'package:lklk/generated/l10n.dart';

import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/presentation/manger/room_cubit/room_cubit_cubit.dart';

class AuthView extends StatefulWidget {
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  const AuthView({super.key, required this.userCubit, required this.roomCubit});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool _hasAgreedToPrivacyPolicy = false;
  bool _isPrivacyChecked = false;

  @override
  void initState() {
    super.initState();
    _checkPrivacyAgreement();
  }

  Future<void> _checkPrivacyAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasAgreedToPrivacyPolicy =
          prefs.getBool('hasAgreedToPrivacyPolicy') ?? true;
      _isPrivacyChecked = true;
    });
  }

  void _updateAgreement(bool value) {
    setState(() {
      _hasAgreedToPrivacyPolicy = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPrivacyChecked) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocListener<UserCubit, UserCubitState>(
      listener: (context, state) {
        if (state.status.isError) {
          SnackbarHelper.showMessage(context, state.message ?? "");
        }
      },
      child: Stack(
        children: [
          const LinearGradientWidget(),
          SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: AppColors.transparent,
              appBar: AppBar(
                backgroundColor: AppColors.transparent,
                title: AutoSizeText(
                  S.of(context).signIn,
                  style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black54)
                      ]),
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: LanguageSwitcher(isFlagOnly: true),
                  ),
                ],
              ),
              body: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: AnimatedAuthBody(
                      userCubit: widget.userCubit,
                      roomCubit: widget.roomCubit,
                      enabled: _hasAgreedToPrivacyPolicy,
                    ),
                  ),
                  PrivacyAgreementWidget(
                    agreed: _hasAgreedToPrivacyPolicy,
                    onChanged: _updateAgreement,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

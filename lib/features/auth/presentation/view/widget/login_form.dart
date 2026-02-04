import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/services/zego_service_login.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/utils/logger.dart';

class LoginForm extends StatefulWidget {
  const LoginForm(
      {super.key, required this.userCubit, required this.roomCubit});
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _buttonAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).pleaseEnterEmail;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return S.of(context).invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).pleaseEnterPassword;
    }
    if (value.length < 6) {
      return S.of(context).passwordMustBeAtLeast6Chars;
    }
    return null;
  }

  void _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // هنا من الممكن معالجة البيانات مثل إرسالها إلى السيرفر
      widget.userCubit.signIn(widget.roomCubit, context,
          email: emailController.text,
          password: passwordController.text,
          isGoogle: false);
      Future.delayed(const Duration(milliseconds: 400));
      if (widget.userCubit.state.status == UserCubitStatus.authenticated) {
        await zegoLoginService(
          context,
          userCubit: widget.userCubit,
          roomCubit: widget.roomCubit,
        );
      }

      AppLogger.debug('البريد: ${emailController.text}');
      AppLogger.debug('كلمة المرور: ${passwordController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: S.of(context).email,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: S.of(context).password,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
            validator: _validatePassword,
          ),
          const SizedBox(height: 24),
          ScaleTransition(
            scale: _buttonAnimation,
            child: ElevatedButton(
              onPressed: _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: AutoSizeText(
                S.of(context).login,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

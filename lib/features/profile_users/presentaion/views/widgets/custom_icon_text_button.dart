import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/profile_users/presentaion/manger/freind_progress/freind_progress_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/custom_icon_text_button_body.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';

class CustomIconTextButton extends StatefulWidget {
  const CustomIconTextButton({
    super.key,
    this.title,
    this.title2,
    required this.icon,
    this.friendStatus,
    required this.onPressedFriend,
    required this.onPressedNotFriend,
    this.activeIconColor = const Color(0xFFFF0000),
    this.inactiveIconColor = Colors.grey,
    this.enableFriendSnackbars = false,
  });

  final String? title;
  final String? title2;
  final IconData icon;
  final String? friendStatus;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final VoidCallback onPressedFriend;
  final VoidCallback onPressedNotFriend;
  // When true, this widget will show snackbars for friend actions.
  // Keep false for generic usages (e.g., chat) to avoid duplicate snackbars.
  final bool enableFriendSnackbars;

  @override
  State<CustomIconTextButton> createState() => _CustomIconTextButtonState();
}

class _CustomIconTextButtonState extends State<CustomIconTextButton> {
  late bool _isPressed;

  @override
  void initState() {
    super.initState();
    if (widget.friendStatus == 'you are friend' || // back
        widget.friendStatus == "loading accept") {
      _isPressed = false;
    } else {
      _isPressed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FreindProgressCubit, FreindProgressState>(
        listenWhen: (previous, current) {
      // Only react to relevant states
      final relevant = current is FreindProgressSuccessSend ||
          current is FreindProgressSuccessDelete ||
          current is FreindProgressWaitingAccepting ||
          current is FreindProgressAlreadyFriend ||
          current is FreindProgressError;
      if (!relevant) return false;

      // If state type changed, always listen
      if (current.runtimeType != previous.runtimeType) return true;

      // If both are errors, listen when the message changed
      if (current is FreindProgressError && previous is FreindProgressError) {
        return current.message.trim() != previous.message.trim();
      }

      return false;
    }, listener: (context, state) {
      // Guard: only show snackbars when explicitly enabled for friend button
      if (!widget.enableFriendSnackbars) return;

      // Clear, localized messages for both actions
      final langCode = Localizations.localeOf(context).languageCode;
      final isAr = langCode.toLowerCase().startsWith('ar');

      if (state is FreindProgressSuccessSend) {
        final msg = isAr
            ? 'تم إرسال طلب الصداقة بنجاح'
            : 'Friend request sent successfully';
        SnackbarHelper.showMessage(context, msg);
      } else if (state is FreindProgressWaitingAccepting) {
        final msg = isAr ? 'تم الارسال' : 'Request sent';
        SnackbarHelper.showMessage(context, msg);
      } else if (state is FreindProgressAlreadyFriend) {
        final msg = isAr ? 'أنتما صديقان بالفعل' : 'You are already friends';
        SnackbarHelper.showMessage(context, msg);
      } else if (state is FreindProgressSuccessDelete) {
        final msg = isAr
            ? 'تم إلغاء طلب الصداقة بنجاح'
            : 'Friend request cancelled successfully';
        SnackbarHelper.showMessage(context, msg);
      } else if (state is FreindProgressError) {
        final raw = (state.message).trim();
        final lower = raw.toLowerCase();
        if (lower == 'you are not friend') {
          // Show exactly as server responded, with no prefixes/localization
          SnackbarHelper.showMessage(context, 'you are not friend');
        } else if (lower.contains('formatexception')) {
          // Suppress FormatException snackbars; a more meaningful message may follow
          return;
        } else {
          final msg = isAr ? 'حدث خطأ: $raw' : 'Error: $raw';
          SnackbarHelper.showMessage(context, msg);
        }
      }
    }, builder: (context, state) {
      // if (state is FreindProgressLoading) {
      //   return Padding(
      //     padding: const EdgeInsets.all(12),
      //     child: const Center(
      //       child: CircularProgressIndicator(),
      //     ),
      //   );
      // } else {
      return Stack(
        children: [
          CustomIconTextButtonBody(
            icon: widget.icon,
            title: widget.title!,
            title2: widget.title2!,
            isPressed: _isPressed,
            activeIconColor: widget.activeIconColor,
            inactiveIconColor: widget.inactiveIconColor,
            onPressed: () {
              setState(() {
                _isPressed = !_isPressed;
              });
              if (_isPressed) {
                widget.onPressedFriend();
              } else {
                widget.onPressedNotFriend();
              }
            },
          ),
        ],
      );
    }
        // },
        );
  }
}

class CustomIconTextButtonRelation extends StatefulWidget {
  const CustomIconTextButtonRelation({
    super.key,
    this.title,
    this.title2,
    required this.icon,
    // this.friendStatus,
    required this.onPressedFriend,
    required this.onPressedNotFriend,
    this.activeIconColor = const Color(0xFFFF0000),
    this.inactiveIconColor = Colors.grey,
  });

  final String? title;
  final String? title2;
  final IconData icon;
  // final String? friendStatus;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final VoidCallback onPressedFriend;
  final VoidCallback onPressedNotFriend;

  @override
  State<CustomIconTextButtonRelation> createState() =>
      _CustomIconTextButtonRelationState();
}

class _CustomIconTextButtonRelationState
    extends State<CustomIconTextButtonRelation> {
  late bool _isPressed;

  @override
  void initState() {
    super.initState();
    _isPressed = true; //
    // if (widget.friendStatus == 'you are not friend' ||
    //     widget.friendStatus == null ||
    //     widget.friendStatus == "loading accept") {
    //   _isPressed = false;
    // } else {
    //   _isPressed = true;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FreindProgressCubit, FreindProgressState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Stack(
          children: [
            CustomIconTextButtonBody(
              icon: widget.icon,
              title: widget.title!,
              title2: widget.title2!,
              isPressed: _isPressed,
              activeIconColor: widget.activeIconColor,
              inactiveIconColor: widget.inactiveIconColor,
              onPressed: () {
                setState(() {
                  _isPressed = !_isPressed;
                });
                if (_isPressed) {
                  widget.onPressedFriend();
                } else {
                  widget.onPressedNotFriend();
                }
              },
            ),
            // if (state is FreindProgressLoading)
            //   const Positioned.fill(
            //     child: Center(
            //       child: CircularProgressIndicator(),
            //     ),
            //   ),
          ],
        );
      },
    );
  }
}

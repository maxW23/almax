// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/profile_users/presentaion/manger/join_to_wakala/join_to_wakala_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/custom_button_icon_andtext.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/out_from_wakala_widget.dart';
import 'package:lklk/generated/l10n.dart';

class JoinToWakalaSectionMiniWakel extends StatelessWidget {
  const JoinToWakalaSectionMiniWakel({
    super.key,
    required this.widget,
  });

  final OtherUserProfile widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BlocBuilder<JoinToWakalaCubit, JoinToWakalaState>(
          // Wrap with BlocBuilder for JoinToWakalaCubit
          builder: (context, state) {
            return CustomButtonIconAndtext(
              color: AppColors.golden,
              icon: FontAwesomeIcons.crown,
              text: S.of(context).joinToWakala,
              onPressed: () async {
                //log('user.iduser! ${widget.user.iduser!}');

                if (state is! JoinToWakalaSuccess) {
                  await context
                      .read<JoinToWakalaCubit>()
                      .joinToWakala(widget.user.iduser);
                }
              },
            );
          },
        ),
        OutFromWakalaWidget(widget: widget),
      ],
    );
  }
}

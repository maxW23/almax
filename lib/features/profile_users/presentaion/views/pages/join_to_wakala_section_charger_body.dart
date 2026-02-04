// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/profile_users/presentaion/manger/join_to_wakala/join_to_wakala_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/out_of_wakala/out_from_wakala_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/custom_button_icon_andtext.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile.dart';
import 'package:lklk/generated/l10n.dart';

class JoinToWakalaSectionChargerBody extends StatelessWidget {
  const JoinToWakalaSectionChargerBody({
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
              onPressed: () {
                //log('user.iduser! ${widget.user.iduser!}');

                if (state is! JoinToWakalaSuccess) {
                  context
                      .read<JoinToWakalaCubit>()
                      .joinToWakala(widget.user.iduser);
                }
              },
            );
          },
        ),
        BlocBuilder<OutFromWakalaCubit, OutFromWakalaState>(
          // Wrap with BlocBuilder for OutFromWakalaCubit
          builder: (context, state) {
            return CustomButtonIconAndtext(
              color: AppColors.danger,
              icon: FontAwesomeIcons.times,
              text: S.of(context).leaveWakala,
              onPressed: () {
                //log('user.iduser! ${widget.user.iduser!}');

                if (state is! OutFromWakalaSuccess) {
                  // Only dispatch the event if not already left
                  context
                      .read<OutFromWakalaCubit>()
                      .outFromWakala(widget.user.iduser);
                }
              },
            );
          },
        ),
      ],
    );
  }
}

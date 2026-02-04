// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/profile_users/presentaion/manger/join_to_wakala/join_to_wakala_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/join_to_wakala_section_charger_body.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile.dart';

class JoinToWakalaSectionCharger extends StatelessWidget {
  const JoinToWakalaSectionCharger({
    super.key,
    required this.widget,
  });

  final OtherUserProfile widget;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JoinToWakalaCubit>(
        create: (context) => JoinToWakalaCubit(),
        child: JoinToWakalaSectionChargerBody(widget: widget));
  }
}

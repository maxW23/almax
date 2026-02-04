import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/empty_screen.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/profile_users/presentaion/manger/post_center_cubit/post_center_cubit.dart';

class PostCenterWakala extends StatelessWidget {
  const PostCenterWakala({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PostCenterCubit>(
      create: (context) => PostCenterCubit(),
      child: const PostCenterWakalaBody(),
    );
  }
}

class PostCenterWakalaBody extends StatelessWidget {
  const PostCenterWakalaBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: BlocBuilder<PostCenterCubit, PostCenterState>(
        bloc: PostCenterCubit()..fetchWakalaInfo(),
        builder: (context, state) {
          if (state is PostCenterSuccess) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header Section
                    _buildWakalaHeader(size, context),
                    const SizedBox(height: 30),

                    // Main Info Cards
                    _buildMainInfoCards(state, context),
                    const SizedBox(height: 30),

                    // Join Button
                    _buildJoinButton(context),
                    const SizedBox(height: 40),

                    // Stats Section
                    _buildStatsSection(state, context),
                  ],
                ),
              ),
            );
          } else if (state is PostCenterError) {
            return _buildErrorState(context);
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: AppColors.black,
            ));
          }
        },
      ),
    );
  }

  Widget _buildWakalaHeader(Size size, BuildContext context) {
    return Column(
      children: [
        Icon(
          FontAwesomeIcons.usersLine,
          size: size.width * 0.15,
          color: AppColors.black,
        ),
        const SizedBox(height: 15),
        AutoSizeText(
          sl<UserCubit>().state.user?.wakalaName ??
              S.of(context).wakala.toUpperCase(),
          textAlign: TextAlign.center,
          style: Styles.textStyle24.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfoCards(PostCenterSuccess state, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
              icon: FontAwesomeIcons.idCard,
              title: S.of(context).wakelID,
              value: state.wakalaInfo.wakelId),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _InfoCard(
            icon: FontAwesomeIcons.user,
            title: S.of(context).wakelName,
            value: state.wakalaInfo.wakelName,
          ),
        ),
      ],
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondColorsemi,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
        ),
        onPressed: () {
          SnackbarHelper.showMessage(context, S.of(context).soon);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FontAwesomeIcons.link,
              size: 18,
              color: AppColors.white,
            ),
            const SizedBox(width: 12),
            AutoSizeText(
              S.of(context).joinToOtherWakala,
              style: Styles.textStyle16.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(PostCenterSuccess state, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.black.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteGrey.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  FontAwesomeIcons.chartColumn,
                  color: AppColors.black,
                  size: 20,
                ),
                AutoSizeText(
                  S.of(context).monthlyStats.toUpperCase(),
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // const Icon(FontAwesomeIcons.ellipsisVertical, size: 18),
                Icon(
                  FontAwesomeIcons.chartLine,
                  color: AppColors.black,
                  size: 20,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: FontAwesomeIcons.coins,
                  title: S.of(context).gold,
                  value: state.wakalaInfo.gold,
                  color: AppColors.golden,
                ),
                _StatItem(
                  icon: FontAwesomeIcons.gem,
                  title: S.of(context).diamond,
                  value: state.wakalaInfo.diamond,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const EmptyScreen(),
        const SizedBox(height: 30),
        AutoSizeText(
          S.of(context).youarenotinwakala,
          style: Styles.textStyle20.copyWith(
            color: AppColors.grey.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // ElevatedButton(
        //   onPressed: () => context.read<PostCenterCubit>().fetchWakalaInfo(),
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: AppColors.black,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        //   ),
        //   child: AutoSizeText(
        //     S.of(context).tryAgain,
        //     style: Styles.textStyle16.copyWith(color: Colors.white),
        //   ),
        // ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.black),
          const SizedBox(height: 12),
          AutoSizeText(
            title,
            style: Styles.textStyle14.copyWith(
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            value,
            style: Styles.textStyle18.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(height: 12),
        AutoSizeText(
          title,
          style: Styles.textStyle14.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        AutoSizeText(
          value,
          style: Styles.textStyle18.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

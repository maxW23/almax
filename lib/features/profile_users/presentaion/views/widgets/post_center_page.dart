import 'package:lklk/core/utils/logger.dart';

import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/post_center_wakala.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/target_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/target_value_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/wakala_name_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/wakala_users_page.dart';
import 'package:lklk/generated/l10n.dart';

class PostCenterPage extends StatefulWidget {
  const PostCenterPage({super.key});

  @override
  State<PostCenterPage> createState() => _PostCenterPageState();
}

class _PostCenterPageState extends State<PostCenterPage> {
  final user = sl<UserCubit>().state.user;
  late final bool isWakel;
  late final bool isPower;

  @override
  void initState() {
    super.initState();
    isWakel = user!.type == "mini" || user!.type == "charge";
    isPower = user!.power == "null" || user!.power == null;
  }

  @override
  Widget build(BuildContext context) {
    log("stateeee  ${user?.type}");
    return SafeArea(
      top: false,
      child: Scaffold(
        body: SafeArea(
          child: DynamicTabBarWidget(
            onTabControllerUpdated: (controller) {},
            onTabChanged: (index) {},
            labelColor: AppColors.black,
            isScrollable: false,
            showNextIcon: true,
            showBackIcon: true,
            indicator: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.black,
                  width: 2,
                ),
              ),
            ),
            dynamicTabs: [
              if (isWakel)
                TabData(
                  index: 3,
                  title: Tab(
                    child: AutoSizeText(
                      S.of(context).target,
                      maxLines: 1,
                      maxFontSize: 12,
                      minFontSize: 9,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  content: TargetPage(),
                ),
              if (isWakel)
                TabData(
                  index: 2,
                  title: Tab(
                    child: AutoSizeText(
                      S.of(context).users,
                      maxLines: 1,
                      maxFontSize: 12,
                      minFontSize: 9,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  content: WakalaUsersPage(),
                ),
              if (isWakel && isPower)
                TabData(
                  index: 1,
                  title: Tab(
                    child: AutoSizeText(
                      S.of(context).wakalaNamee,
                      maxLines: 1,
                      maxFontSize: 12,
                      minFontSize: 9,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  content: WakalaNamePage(),
                ),
              TabData(
                index: 0,
                title: Tab(
                  child: AutoSizeText(
                    S.of(context).postCenter,
                    maxLines: 1,
                    maxFontSize: 12,
                    minFontSize: 9,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                content: PostCenterWakala(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

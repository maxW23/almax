import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/chat/presentation/manger/home_message_cubit/home_message_cubit.dart';
import 'package:lklk/features/chat/presentation/manger/message_cubit/message_cubit.dart';
import 'package:lklk/features/chat/presentation/views/chat_view_messages_page.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/friend_list_page.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/visitors_list_page.dart';
import 'package:lklk/generated/l10n.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key, required this.userCubit, required this.roomCubit});
  final UserCubit userCubit;
  final RoomCubit roomCubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.primary, // بنفسجي فاتح
            AppColors.secondColor, // بنفسجي غامق
          ],
        ),
      ),
      child: SafeArea(
        child: MultiBlocProvider(
            providers: [
              BlocProvider<MessageCubit>(
                  lazy: true, create: (context) => MessageCubit()),
              BlocProvider<HomeMessageCubit>(
                create: (context) => HomeMessageCubit(),
              ),
            ],
            child: DynamicTabBarWidget(
              
              onTabControllerUpdated: (controller) {
                // _tabController = controller;
              },
              dynamicTabs: [
                TabData(
                  index: 2,
                  
                  title: Tab(
                    child: AutoSizeText(S.of(context).visitors),
                  ),
                  content: Container(
                    color: AppColors.white,
                    child: VisitorsListPage(
                      userCubit: userCubit,
                      roomCubit: roomCubit,
                      isChat: true,
                    ),
                  ),
                ),
                TabData(
                  index: 1,
                  title: Tab(
                    child: AutoSizeText(S.of(context).friends),
                  ),
                  content: Container(
                    color: AppColors.white,
                    child: FriendListPage(
                      userCubit: userCubit,
                      roomCubit: roomCubit,
                      isChat: true,
                    ),
                  ),
                ),
                TabData(
                  index: 0,
                  title: Tab(
                    child: AutoSizeText(S.of(context).chat),
                  ),
                  content: Container(
                    color: AppColors.white,
                    child: ChatPageListMessagesChatPage(
                      userCubit: userCubit,
                      roomCubit: roomCubit,
                    ),
                  ),
                ),
              ],
              automaticIndicatorColorAdjustment: false,
              unselectedLabelColor: AppColors.white,
              labelColor: AppColors.black,
              indicator: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.black,
                    width: 2,
                  ),
                ),
              ),
              isScrollable: false,
              showNextIcon: true,
              showBackIcon: true,
              onTabChanged: (index) {},
            )
            // ChatPageListMessagesChatPage(
            //   userCubit: userCubit,
            // ),
            ),
      ),
    );
  }
}

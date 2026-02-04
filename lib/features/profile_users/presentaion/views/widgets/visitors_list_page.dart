import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/assets.dart';

import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/chat/presentation/views/chat_private_page.dart';
import 'package:lklk/features/chat/presentation/views/message_counter_alert.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/friend_cubit/freind_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/empty_screen.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/user_profile_view_body_success_bloc.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/s_v_i_p_page.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:lklk/core/utils/list_performance_optimizer.dart';

class VisitorsListPage extends StatelessWidget {
  const VisitorsListPage(
      {super.key,
      required this.userCubit,
      required this.roomCubit,
      this.isChat = false});
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  final bool isChat;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return BlocProvider<FreindCubit>(
      create: (context) => FreindCubit()..getListOfVisitorProfiles(),
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: SafeArea(
            child: BlocConsumer<FreindCubit, FreindState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is FreindRequiresVip) {
                  return _buildVipRequiredWidget(context, state);
                } else if (state is FreindError) {
                  return Center(child: AutoSizeText(state.message));
                } else if (state is FreindLoadingList) {
                  return ListPerformanceOptimizer.optimizedListView(
                    padding: EdgeInsets.all(w / 30),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    cacheExtent: 300.0,
                    itemCount: 7, // عدد العناصر الافتراضية
                    itemBuilder: (context, index) {
                      return Skeletonizer(
                        child: VisitorItemDesign(
                          userCubit: userCubit,
                          width: w,
                          user: UserEntity(
                            iduser: "",
                            name: "Loading...", // اسم افتراضي أثناء التحميل
                            img: AssetsData.userTestNetwork, // صورة افتراضية
                          ),
                          onTap: () {}, // لا حاجة لوظيفة الضغط أثناء التحميل
                        ),
                      );
                    },
                  );
                } else if (state is FreindVisitorProfilesLoaded) {
                  if (state.users.isEmpty) {
                    return const EmptyScreen();
                  } else {
                    return visitorsListView(w, state, isChat);
                  }
                } else {
                  return const Center(child: SizedBox());
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget visitorsListView(
      double w, FreindVisitorProfilesLoaded state, bool isChat) {
    return ListPerformanceOptimizer.optimizedListView(
      padding: EdgeInsets.all(w / 30),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      cacheExtent: 300.0,
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        return VisitorItemLogic(
          width: w,
          context: context,
          state: state,
          index: index,
          isChat: isChat,
          roomCubit: roomCubit,
          userCubit: userCubit,
        );
      },
    );
  }

  Widget _buildVipRequiredWidget(
      BuildContext context, FreindRequiresVip state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة VIP
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade400,
                    Colors.orange.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // العنوان
            Text(
              'ميزة VIP ${state.requiredVipLevel}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // الوصف
            Text(
              'للاستمتاع بميزة ${state.feature}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'يجب أن تكون VIP ${state.requiredVipLevel} أو أعلى',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // زر الترقية
            ElevatedButton.icon(
              onPressed: () {
                final me = userCubit.user;
                if (me == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الرجاء تسجيل الدخول أولاً'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SVIPPage(user: me),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_upward, color: Colors.white),
              label: const Text(
                'ترقية الحساب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VisitorItemDesign extends StatelessWidget {
  final double width;
  final UserEntity user; // بيانات المستخدم
  final VoidCallback onTap;
  final UserCubit userCubit;
  const VisitorItemDesign({
    super.key,
    required this.width,
    required this.user,
    required this.onTap,
    required this.userCubit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: UserWidgetTitle(
        user: user,
        userCubit: userCubit,
        isRoomTypeUser: false,
        isWakel: true,
        isID: true,
        onTap: onTap,
        trailing: user.howManyTime != null
            ? MessageCounterAlert(
                howManyTime: user.howManyTime!,
                fontSize: 11,
                size: 25,
              )
            : null,
      ),
    );
  }
}

class VisitorItemLogic extends StatelessWidget {
  final double width;
  final BuildContext context;
  final FreindVisitorProfilesLoaded state;
  final int index;
  final bool isChat;
  final RoomCubit roomCubit;
  final UserCubit userCubit;

  const VisitorItemLogic({
    super.key,
    required this.width,
    required this.context,
    required this.state,
    required this.index,
    required this.isChat,
    required this.roomCubit,
    required this.userCubit,
  });

  @override
  Widget build(BuildContext context) {
    return VisitorItemDesign(
      userCubit: userCubit,
      width: width,
      user: state.users[index],
      onTap: () {
        if (isChat) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPrivatePageBloc(
                roomCubit: roomCubit,
                userCubit: userCubit,
                userId: state.users[index].iduser,
                userImg: state.users[index].img,
                userName: state.users[index].name!,
                userImgcurrent:
                    userCubit.user?.img ?? AssetsData.userTestNetwork,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileViewBodySuccessBloc(
                iduser: state.users[index].iduser,
                userCubit: userCubit,
                roomCubit: roomCubit,
              ),
            ),
          );
        }
      },
    );
  }
}

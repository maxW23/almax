// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:lklk/core/utils/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/chat/presentation/views/chat_private_page.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/freind_progress/freind_progress_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/friend_cubit/freind_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/user_profile_view_body_success_bloc.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:lklk/core/utils/list_performance_optimizer.dart';

import 'empty_screen.dart';

class FriendListPage extends StatelessWidget {
  const FriendListPage(
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

    return MultiBlocProvider(
      providers: [
        BlocProvider<FreindCubit>(
          create: (context) => FreindCubit()..getFriendsList(),
        ),
        BlocProvider<FreindProgressCubit>(
            lazy: true, create: (context) => FreindProgressCubit()),
      ],
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: SafeArea(
            child: BlocConsumer<FreindCubit, FreindState>(
              listener: (context, state) {
                if (state is FreindProgressSuccessDelete ||
                    state is FreindProgressError) {
                  BlocProvider.of<FreindCubit>(context).getFriendsList();
                }
              },
              builder: (context, state) {
                //log('state is : //');
                if (state is FreindError) {
                  log("state is FreindError : ${state.message}");

                  if (state.message.contains(
                      "you have to be vip 2 and up to see you visitor")) {
                    return Center(
                        child: AutoSizeText(
                            "you have to be vip 2 and up to see you visitor"));
                  } else {
                    return Center(child: AutoSizeText(state.message));
                  }
                } else if (state is FreindFriendsListLoaded) {
                  if (state.users.isEmpty) {
                    return const EmptyScreen();
                  } else {
                    return _FriendListPrefetcher(
                      w: w,
                      state: state,
                      isChat: isChat,
                      roomCubit: roomCubit,
                      userCubit: userCubit,
                    );
                  }
                } else if (state is FreindLoadingList) {
                  return ListPerformanceOptimizer.optimizedListView(
                    padding: EdgeInsets.all(w / 30),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    cacheExtent: 300.0,
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      return RepaintBoundary(
                        child: TickerMode(
                          enabled: false,
                          child: Skeletonizer(
                            child: FriendItemDesign(
                              width: w,
                              user: UserEntity(
                                iduser: "",
                                name: "Loading...", // اسم افتراضي أثناء التحميل
                                img: AssetsData.userTestNetwork, // صورة افتراضية
                              ),
                              icon: FontAwesomeIcons.userMinus,
                              iconSecond: FontAwesomeIcons.userCheck,
                              iconColor: AppColors.black,
                              onIconSecondPressed: () {},
                              onTap: () {},
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: SizedBox(),

                    //child: AutoSizeText('state ')
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendListPrefetcher extends StatefulWidget {
  final double w;
  final FreindFriendsListLoaded state;
  final bool isChat;
  final RoomCubit roomCubit;
  final UserCubit userCubit;

  const _FriendListPrefetcher({
    super.key,
    required this.w,
    required this.state,
    required this.isChat,
    required this.roomCubit,
    required this.userCubit,
  });

  @override
  State<_FriendListPrefetcher> createState() => _FriendListPrefetcherState();
}

class _FriendListPrefetcherState extends State<_FriendListPrefetcher> {
  bool _prefetched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefetchAvatars());
  }

  void _prefetchAvatars() async {
    if (_prefetched) return;
    _prefetched = true;
    final unique = <String>{};
    for (final u in widget.state.users) {
      final raw = u.friendUser.img?.trim();
      if (raw == null || raw.isEmpty || raw.toLowerCase() == 'null') continue;
      if (raw.contains('assets')) continue; // local asset, no network fetch
      final url = raw.contains('https://')
          ? raw
          : 'https://lklklive.com/imguser/$raw';
      unique.add(url);
      if (unique.length >= 6) break; // smaller cap to avoid decode storm
    }
    if (unique.isEmpty) return;
    // decode to target avatar size (~64dp)
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final int w = (64 * dpr).clamp(64, 256).round();
    final int h = (64 * dpr).clamp(64, 256).round();
    const int batchSize = 2;
    final urls = unique.toList(growable: false);
    for (int i = 0; i < urls.length; i += batchSize) {
      final slice = urls.sublist(i, i + batchSize > urls.length ? urls.length : i + batchSize);
      await Future.wait(slice.map((u) async {
        try {
          final provider = ResizeImage(CachedNetworkImageProvider(u), width: w, height: h);
          await precacheImage(provider, context);
        } catch (e) {
          // ignore individual failures
        }
      }));
      // yield to frame
      await Future.delayed(const Duration(milliseconds: 16));
    }
    AppLogger.debug('[FriendListPrefetcher] Prefetched avatars: ${urls.length}');
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.w;
    final state = widget.state;
    return ListPerformanceOptimizer.optimizedListView(
      padding: EdgeInsets.all(w / 30),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      cacheExtent: 300.0,
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: FriendItemLogic(
            width: w,
            context: context,
            state: state,
            index: index,
            isChat: widget.isChat,
            roomCubit: widget.roomCubit,
            userCubit: widget.userCubit,
          ),
        );
      },
    );
  }
}

class FriendItemDesign extends StatelessWidget {
  final double width;
  final UserEntity user; // بيانات المستخدم
  final IconData icon;
  final IconData iconSecond;
  final Color iconColor;
  final VoidCallback? onIconPressed;
  final VoidCallback? onIconSecondPressed;
  final VoidCallback onTap;

  const FriendItemDesign({
    super.key,
    required this.width,
    required this.user,
    required this.icon,
    required this.iconSecond,
    required this.iconColor,
    this.onIconPressed,
    this.onIconSecondPressed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: width / 10),
      child: UserWidgetTitle(
        isRoomTypeUser: false,
        isWakel: true,
        isAnimatedIcon: true,
        isID: true,
        isLevel: false,
        iconColor: iconColor,
        isPressIcon: onIconPressed,
        isPressIcon2: onIconSecondPressed,
        icon: icon,
        iconSecond: iconSecond,
        isIcon: true,
        user: user.copyWith(
          name: user.name ?? "User Name", // اسم افتراضي
          img: user.img ?? AssetsData.userTestNetwork, // صورة افتراضية
        ),
        userCubit: BlocProvider.of<UserCubit>(context),
        onTap: onTap,
      ),
    );
  }
}

class FriendItemLogic extends StatelessWidget {
  final double width;
  final BuildContext context;
  final FreindFriendsListLoaded state;
  final int index;
  final bool isChat;
  final RoomCubit roomCubit;
  final UserCubit userCubit;

  const FriendItemLogic({
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
    return FriendItemDesign(
      width: width,
      user: state.users[index].friendUser,
      icon: FontAwesomeIcons.userMinus,
      iconSecond: FontAwesomeIcons.userCheck,
      iconColor: AppColors.black,
      onIconPressed: () async {
        await BlocProvider.of<FreindProgressCubit>(context)
            .deleteFriendOrFriendRequest(state.users[index].stringId);
        BlocProvider.of<FreindCubit>(context).getFriendsList();
      },
      onIconSecondPressed: () async {
        await BlocProvider.of<FreindCubit>(context).getFriendsList();
      },
      onTap: () {
        if (isChat) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPrivatePageBloc(
                roomCubit: roomCubit,
                userCubit: userCubit,
                userId: state.users[index].friendUser.iduser,
                userImg: state.users[index].friendUser.img,
                userName: state.users[index].friendUser.name!,
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
                iduser: state.users[index].friendUser.iduser,
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

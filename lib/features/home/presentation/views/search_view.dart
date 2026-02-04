import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/widgets/search_rooms_view.dart';
import 'package:lklk/features/home/presentation/views/widgets/search_users_view.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';

class SearchView extends StatefulWidget {
  const SearchView(
      {super.key, required this.userCubit, required this.roomCubit});
  final RoomCubit roomCubit;
  final UserCubit userCubit;
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );

    // Navigate to the initial tab after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _tabController.animateTo(widget.initialTabIndex);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TabData> tabs = [
      TabData(
        index: 1,
        title: Tab(
          child: AutoSizeText(S.of(context).rooms),
        ),
        content: Column(
          children: [
            Expanded(
              child: SearchRoomsViewBloc(
                userCubit: widget.userCubit,
                roomCubit: widget.roomCubit,
              ),
            ),
          ],
        ),
      ),
      TabData(
        index: 0,
        title: Tab(
          child: AutoSizeText(S.of(context).users),
        ),
        content: Column(
          children: [
            Expanded(
              child: SearchUsersView(
                userCubit: widget.userCubit,
                roomCubit: widget.roomCubit,
              ),
            ),
          ],
        ),
      ),
    ];

    return SafeArea(
      top: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: DynamicTabBarWidget(
                  dynamicTabs: tabs,
                  isScrollable: false,
                  labelColor: AppColors.primary,
                  indicator: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onTabControllerUpdated: (controller) {
                    // _tabController = controller;
                  },
                  onTabChanged: (index) {},
                  onAddTabMoveTo: MoveToTab.last,
                  showBackIcon: true,
                  showNextIcon: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/fetch_elements_cubit/fetch_elements_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/fetch_elements_cubit/fetch_elements_cubit_state.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'elements_local_page.dart';
import 'store_appbar.dart';
import 'store_bottom_navigationbar.dart';
import 'cupboard_page_store.dart';
import 'vip_tab.dart';

class StoreProfileView extends StatefulWidget {
  final UserEntity user;
  // Visibility flags for tabs
  final bool showVip;
  final bool showYourEntry;
  final bool showYourFrame;
  final bool showEntry;
  final bool showFrame;
  final String? appBarTitle;

  const StoreProfileView({
    super.key,
    required this.user,
    this.showVip = true,
    this.showYourEntry = true,
    this.showYourFrame = true,
    this.showEntry = true,
    this.showFrame = true,
    this.appBarTitle,
  });

  @override
  State<StoreProfileView> createState() => _StoreProfileViewState();
}

class _StoreProfileViewState extends State<StoreProfileView>
    with SingleTickerProviderStateMixin {
  int? selectedIndex;
  int? selectedItemId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final fetchElementsCubit = context.read<FetchElementsCubit>();
    fetchElementsCubit.fetchStoreElements();
    fetchElementsCubit.fetchMyElements();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: 0,
    );
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _tabController.animateTo(0);
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: StoreAppbar(title: widget.appBarTitle),
        body: SafeArea(
          child: BlocBuilder<FetchElementsCubit, FetchElementsCubitState>(
            builder: (context, state) {
              final elements = state.elements;
              final myElements = state.myElements;
              if (state.status == Status.loading) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: AppColors.golden,
                ));
              } else if (state.status == Status.error) {
                final fetchElementsCubit = context.read<FetchElementsCubit>();
                fetchElementsCubit.fetchStoreElements();
                return Center(
                    child: AutoSizeText(state.error ?? "Unknown Error"));
              } else if (elements != null && elements.isNotEmpty) {
                final fetchElementsCubit = context.read<FetchElementsCubit>();
                final tabs =
                    _buildTabs(elements, myElements ?? [], fetchElementsCubit);

                return DynamicTabBarWidget(
                  onTabControllerUpdated: (controller) {
                    // _tabController = controller;
                  },
                  dynamicTabs: tabs,
                  labelColor: AppColors.golden,
                  indicator: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.golden,
                        width: 2,
                      ),
                    ),
                  ),
                  isScrollable: false,
                  showNextIcon: true,
                  showBackIcon: true,
                  onTabChanged: (index) {
                    setState(() {
                      selectedIndex = null;
                      selectedItemId = null;
                    });
                  },
                );
              } else {
                return const Center();
              }
            },
          ),
        ),
      ),
    );
  }

  List<TabData> _buildTabs(List<ElementEntity> elements,
      List<ElementEntity> myElements, FetchElementsCubit fetchElementsCubit) {
    final List<TabData> tabs = [];

    // bool isArabic() => Directionality.of(context) == TextDirection.rtl ||
    //     Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    // String _titleForStore(String key) {
    //   final ar = isArabic();
    //   switch (key) {
    //     case 'room_icon':
    //       return ar ? 'أيقونات الروم' : 'Room Icons';
    //     case 'room_background':
    //       return ar ? 'خلفيات الروم' : 'Room Backgrounds';
    //     case 'room_color':
    //       return ar ? 'ألوان الروم' : 'Room Colors';
    //     case 'room_frame':
    //       return ar ? 'إطارات الروم' : 'Room Frames';
    //     default:
    //       return key;
    //   }
    // }
    // String _titleForBag(String key) {
    //   final ar = isArabic();
    //   switch (key) {
    //     case 'room_icon':
    //       return ar ? 'أيقوناتي' : 'Your Icons';
    //     case 'room_background':
    //       return ar ? 'خلفياتي' : 'Your Backgrounds';
    //     case 'room_color':
    //       return ar ? 'ألواني' : 'Your Colors';
    //     case 'room_frame':
    //       return ar ? 'إطاراتي' : 'Your Frames';
    //     default:
    //       return key;
    //   }
    // }

    if (widget.showVip) {
      tabs.add(_createVipTab(index: 4, title: 'VIP'));
    }
    if (widget.showYourEntry) {
      tabs.add(_createCupboardTab(
        index: 3,
        title: S.of(context).yourEntry,
        elementType: 'entry',
        elements: myElements,
      ));
    }
    if (widget.showYourFrame) {
      tabs.add(_createCupboardTab(
        index: 2,
        title: S.of(context).yourFram,
        elementType: 'frame',
        elements: myElements,
      ));
    }
    // Bag: add room_* (owned) tabs only when bag view is intended
    // if (widget.showYourEntry || widget.showYourFrame) {
    //   tabs.addAll([
    //     _createCupboardTab(
    //       index: 21,
    //       title: _titleForBag('room_icon'),
    //       elementType: 'room_icon',
    //       elements: myElements,
    //     ),
    //     _createCupboardTab(
    //       index: 22,
    //       title: _titleForBag('room_background'),
    //       elementType: 'room_background',
    //       elements: myElements,
    //     ),
    //     _createCupboardTab(
    //       index: 23,
    //       title: _titleForBag('room_color'),
    //       elementType: 'room_color',
    //       elements: myElements,
    //     ),
    //     _createCupboardTab(
    //       index: 24,
    //       title: _titleForBag('room_frame'),
    //       elementType: 'room_frame',
    //       elements: myElements,
    //     ),
    //   ]);
    // }
    if (widget.showEntry) {
      tabs.add(_createTab(
          index: 1,
          title: S.of(context).entry,
          elements: elements.where((e) => e.type == 'entry').toList(),
          fetchElementsCubit: fetchElementsCubit));
    }
    if (widget.showFrame) {
      tabs.add(_createTab(
          index: 0,
          title: S.of(context).frame,
          elements: elements.where((e) => e.type == 'frame').toList(),
          fetchElementsCubit: fetchElementsCubit));
    }
    // Store: add room_* tabs only when store view is intended
    // if (widget.showEntry || widget.showFrame) {
    //   tabs.addAll([
    //     _createTab(
    //       index: 11,
    //       title: _titleForStore('room_icon'),
    //       elements: elements.where((e) => e.type == 'room_icon').toList(),
    //       fetchElementsCubit: fetchElementsCubit,
    //     ),
    //     _createTab(
    //       index: 12,
    //       title: _titleForStore('room_background'),
    //       elements: elements.where((e) => e.type == 'room_background').toList(),
    //       fetchElementsCubit: fetchElementsCubit,
    //     ),
    //     _createTab(
    //       index: 13,
    //       title: _titleForStore('room_color'),
    //       elements: elements.where((e) => e.type == 'room_color').toList(),
    //       fetchElementsCubit: fetchElementsCubit,
    //     ),
    //     _createTab(
    //       index: 14,
    //       title: _titleForStore('room_frame'),
    //       elements: elements.where((e) => e.type == 'room_frame').toList(),
    //       fetchElementsCubit: fetchElementsCubit,
    //     ),
    //   ]);
    // }
    return tabs;
  }

  // Build tab title with smart layout:
  // - If the title has exactly two words, show them on two lines.
  // - If it's a single word, keep it on one line and shrink font to fit.
  // - Prevent breaking words into letters (especially for Arabic) by disabling word wrapping.
  Widget _buildTabTitle(String title) {
    final words = title.trim().split(RegExp(r'\s+'));
    final isTwoWords = words.length == 2;
    final display = isTwoWords ? '${words[0]}\n${words[1]}' : title;

    return AutoSizeText(
      display,
      textAlign: TextAlign.center,
      maxLines: isTwoWords ? 2 : 1,
      minFontSize: 9,
      maxFontSize: 13,
      stepGranularity: 0.5,
      wrapWords: false,
      style: const TextStyle(height: 1.1),
    );
  }

  TabData _createTab(
      {required int index,
      required String title,
      required List<ElementEntity> elements,
      required FetchElementsCubit fetchElementsCubit}) {
    return TabData(
      index: index,
      title: Tab(
        child: _buildTabTitle(title),
      ),
      content: Column(
        children: [
          Expanded(
            child: ElementsLocalPage(
              updateSelectedItemId: updateSelectedItemId,
              elements: elements,
              selectedIndex: selectedIndex,
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              user: widget.user,
            ),
          ),
          StoreBottomNavigationbar(
            widget: widget,
            selectedItemId: selectedItemId,
            fetchElementsCubit: fetchElementsCubit,
          ),
        ],
      ),
    );
  }

  TabData _createCupboardTab({
    required int index,
    required String title,
    required String elementType,
    required List<ElementEntity> elements,
  }) {
    return TabData(
      index: index,
      title: Tab(
        child: _buildTabTitle(title),
      ),
      content: CupboardPageStore(
        myElements: elements,
        elementType: elementType,
        user: widget.user,
        widget: widget,
        selectedItemId: selectedItemId,
        selectedIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        updateSelectedItemId: updateSelectedItemId,
      ),
    );
  }

  void updateSelectedItemId(int itemId) {
    setState(() {
      selectedItemId = itemId;
    });
  }

  TabData _createVipTab({required int index, required String title}) {
    return TabData(
      index: index,
      title: Tab(
        child: _buildTabTitle(title),
      ),
      content: VipTab(user: widget.user),
    );
  }
}

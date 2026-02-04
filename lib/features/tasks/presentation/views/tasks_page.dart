import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/pages/other_user_profile.dart';
import 'package:lklk/features/tasks/data/datasources/tasks_api_service.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import '../utils/tasks_localization.dart';
import '../cubit/tasks_cubit.dart';
import '../cubit/tasks_state.dart';
import 'widgets/my_level_tab.dart';
import 'widgets/upgrades_tab.dart';
import 'widgets/ranking_tab_inline.dart';
import 'widgets/skeletons/my_level_tab_skeleton.dart';
import 'widgets/skeletons/ranking_tab_skeleton.dart';
import '../../domain/entities/user_level_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';

/// Normalize user image path to a valid absolute URL, matching
/// the logic used by `CircularUserImage.updateImagePath()`.
String? _resolveImageUrl(String? path) {
  final normalized = path?.trim();
  if (normalized == null ||
      normalized.isEmpty ||
      normalized.toLowerCase() == 'null') {
    return null;
  } else if (normalized.contains('https://lh3.googleusercontent.com')) {
    return normalized;
  } else if (normalized.contains('https://lklklive.com')) {
    return normalized;
  } else if (normalized.contains('https://')) {
    return normalized;
  } else if (normalized.contains('assets')) {
    return normalized;
  } else {
    return 'https://lklklive.com/imguser/$normalized';
  }
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TopUsersSearchDelegate extends SearchDelegate<String?> {
  final List<UserEntity> users;
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  _TopUsersSearchDelegate({
    String initialQuery = '',
    required this.users,
    required this.userCubit,
    required this.roomCubit,
  }) {
    query = initialQuery;
  }

  @override
  String? get searchFieldLabel => 'Search users by name or ID';

  List<UserEntity> _filter(List<UserEntity> users, String q) {
    final qq = q.trim().toLowerCase();
    if (qq.isEmpty) return users;
    return users.where((u) {
      final name = (u.name ?? '').toLowerCase();
      final id = u.iduser;
      return name.contains(qq) || id.contains(qq);
    }).toList();
  }

  int _rankOf(UserEntity u) {
    final idx = users.indexWhere((e) => e.iduser == u.iduser);
    return idx >= 0 ? idx + 1 : -1;
  }

  Widget _buildList(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Text('No users to search',
            style: const TextStyle(color: Colors.white70)),
      );
    }
    final filtered = _filter(users, query);
    final ranked = [...filtered]
      ..sort((a, b) => _rankOf(a).compareTo(_rankOf(b)));
    if (filtered.isEmpty) {
      return Center(
        child: Text("No results for '$query'",
            style: const TextStyle(color: Colors.white70)),
      );
    }
    return ListView.builder(
      itemCount: ranked.length,
      itemBuilder: (context, index) {
        final u = ranked[index];
        final rank = _rankOf(u);
        return ListTile(
          leading: CircularUserImage(
            imagePath: u.img,
            radius: 18,
          ),
          title: Text(u.name ?? 'User'),
          subtitle: Text('ID: ${u.iduser}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Text('#$rank',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          onTap: () {
            // Open profile directly
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OtherUserProfile(
                  user: u,
                  userCubit: userCubit,
                  roomCubit: roomCubit,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      IconButton(
        icon: const Icon(Icons.check),
        onPressed: () => close(context, query),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        hintStyle: const TextStyle(color: Colors.white70),
      ),
      textTheme: theme.textTheme.apply(bodyColor: Colors.white),
      appBarTheme:
          theme.appBarTheme.copyWith(backgroundColor: const Color(0xFF4A90E2)),
    );
  }
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _showInlineSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Debug: verify JPG background asset can be loaded
    rootBundle
        .load('assets/tasks/images/backgruond.jpg')
        .then((_) => debugPrint('[TasksPage] ✅ JPG background loaded'))
        .catchError(
            (e) => debugPrint('[TasksPage] ❌ JPG background load failed: $e'));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  UserLevelEntity? _buildUserLevelFrom(UserCubitState userState) {
    final u = (context.read<UserCubit>().state.user) ?? userState.user;
    if (u == null) return null;
    final currentLevel = int.tryParse(u.newlevel3 ?? '') ?? 0;
    final nextLevel = currentLevel + 1; // always next level = current + 1
    // Server semantics: level3 = current points
    final currentPoints = int.tryParse(u.level3 ?? '') ?? 0;
    // Each level requires 126000 points. Calculate how many points remain to reach next level.
    const int levelSize = 126000;
    final int remainder = currentPoints % levelSize;
    final int pointsToUpgrade = remainder == 0 ? 0 : (levelSize - remainder);
    final userImage = _resolveImageUrl(u.img?.toString()) ?? '';
    final userName = u.name?.toString() ?? 'User';
    return UserLevelEntity(
      currentLevel: currentLevel,
      nextLevel: nextLevel,
      currentPoints: currentPoints,
      pointsToUpgrade: pointsToUpgrade,
      userImage: userImage,
      userName: userName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TasksCubit(
            TasksApiService(ApiService()),
            context.read<LanguageCubit>(),
          )..loadTasks(),
        ),
        BlocProvider(
          create: (context) => TopUsersCubit()..fetchTopUsersCached(13),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // SVG background only (no gradient, no blur)
            Positioned.fill(
              child: Image.asset(
                'assets/tasks/images/backgruond.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            SafeArea(
              child: Builder(
                builder: (innerCtx) => Column(
                  children: [
                    _buildHeader(innerCtx),
                    _buildTabBar(),
                    Expanded(
                      child: BlocBuilder<TasksCubit, TasksState>(
                        builder: (context, state) {
                          if (state is TasksLoading) {
                            // Show full skeletons for all tabs for instant perceived loading
                            return TabBarView(
                              controller: _tabController,
                              children: const [
                                MyLevelTabSkeleton(),
                                UpgradesTabSkeleton(),
                                RankingTabSkeleton(),
                              ],
                            );
                          }

                          if (state is TasksError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    TasksLocalization.errorLoadingTasks(
                                        context),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.message,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state is TasksLoaded) {
                            return BlocBuilder<UserCubit, UserCubitState>(
                              builder: (context, userState) {
                                final userLevel =
                                    _buildUserLevelFrom(userState);
                                return TabBarView(
                                  controller: _tabController,
                                  children: [
                                    MyLevelTab(
                                      tasks: state.myLevelTasks,
                                      userLevel: userLevel,
                                    ),
                                    UpgradesTab(
                                      tasks: state.upgradeTasks,
                                      userLevel: userLevel,
                                    ),
                                    RankingTabInline(
                                      rankings: _getRankingsForPeriod(state),
                                      topAgencies: state.topAgencies,
                                      selectedPeriod:
                                          state.selectedRankingPeriod,
                                      onPeriodChanged: (period) {
                                        // Update selected period in TasksCubit state
                                        context
                                            .read<TasksCubit>()
                                            .changeRankingPeriod(period);
                                        // Map period -> API code: Daily=13, Weekly=14, Monthly=15
                                        final p = period.toLowerCase();
                                        final code = p == 'daily'
                                            ? 13
                                            : p == 'weekly'
                                                ? 14
                                                : 15;
                                        // Use cached fetch to display instantly; refresh in background if stale
                                        context
                                            .read<TopUsersCubit>()
                                            .fetchTopUsersCached(code);
                                      },
                                      searchQuery: _searchQuery,
                                      showInlineSearch: _showInlineSearch,
                                      onSearchChanged: (q) {
                                        setState(() {
                                          _searchQuery = q;
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }

                          return const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<dynamic> _getRankingsForPeriod(TasksLoaded state) {
    switch (state.selectedRankingPeriod.toLowerCase()) {
      case 'daily':
        return state.dailyRankings;
      case 'weekly':
        return state.weeklyRankings;
      case 'monthly':
        return state.monthlyRankings;
      default:
        return state.dailyRankings;
    }
  }

  Widget _buildHeader(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back arrow (SVG) -> pop
          IconButton(
            onPressed: () => Navigator.of(ctx).maybePop(),
            icon: SvgPicture.asset(
              'assets/tasks/svg/leftArrow.svg',
              width: 20,
              height: 20,
            ),
          ),
          const SizedBox(width: 8),
          // User avatar from current user
          BlocBuilder<UserCubit, UserCubitState>(
            builder: (context, state) {
              final u = (context.read<UserCubit>().state.user) ?? state.user;
              return CircularUserImage(
                imagePath: u?.img?.toString(),
                radius: 16,
              );
            },
          ),
          const SizedBox(width: 8),
          // Levels icon (SVG)
          SvgPicture.asset(
            'assets/tasks/svg/carbon_skill-level-advanced.svg',
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 6),
          Text(
            TasksLocalization.levels(context),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          // Search action with SVG
          IconButton(
            icon: SvgPicture.asset(
              'assets/tasks/svg/searchIcon.svg',
              width: 20,
              height: 20,
            ),
            onPressed: () {
              setState(() {
                _showInlineSearch = !_showInlineSearch;
                if (!_showInlineSearch) _searchQuery = '';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Colors.white, width: 2.5),
        ),
        indicatorWeight: 2.5,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: TasksLocalization.myLevel(context)),
          Tab(text: TasksLocalization.upgrades(context)),
          Tab(text: TasksLocalization.ranking(context)),
        ],
      ),
    );
  }
}

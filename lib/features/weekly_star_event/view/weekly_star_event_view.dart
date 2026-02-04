import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/top_user_cubit/top_users_cubit.dart';
import 'package:lklk/features/weekly_star_event/cubit/weekly_tab_cubit.dart';
import 'package:lklk/features/weekly_star_event/cubit/countdown_cubit.dart';
import 'package:lklk/features/weekly_star_event/view/weekly_star_event_view_body.dart';

class WeeklyStarEventView extends StatelessWidget {
  const WeeklyStarEventView({super.key});

  @override
  Widget build(BuildContext context) {
    // Try to reuse an existing TopUsersCubit if available in the context
    TopUsersCubit? existing;
    try {
      existing = context.read<TopUsersCubit>();
    } catch (_) {
      existing = null;
    }

    final child = const _WeeklyStarEventScaffold(initFetch: true);

    // Provide tab + countdown cubits always for this screen
    Widget provideEventCubits(Widget c) => MultiBlocProvider(
          providers: [
            BlocProvider<WeeklyTabCubit>(create: (_) => WeeklyTabCubit()),
            BlocProvider<CountdownCubit>(create: (_) => CountdownCubit()),
          ],
          child: c,
        );

    if (existing != null) {
      // Reuse provided TopUsersCubit
      return provideEventCubits(child);
    }

    // Fallback: create a local TopUsersCubit for this view only
    return provideEventCubits(
      BlocProvider(
        create: (_) => TopUsersCubit()..fetchTopUsers(18),
        child: child,
      ),
    );
  }
}

class _WeeklyStarEventScaffold extends StatefulWidget {
  const _WeeklyStarEventScaffold({required this.initFetch});
  final bool initFetch;

  @override
  State<_WeeklyStarEventScaffold> createState() => _WeeklyStarEventScaffoldState();
}

class _WeeklyStarEventScaffoldState extends State<_WeeklyStarEventScaffold> {
  @override
  void initState() {
    super.initState();
    // Defer to next frame to ensure providers are in the tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.initFetch) {
        context.read<TopUsersCubit>().fetchTopUsers(18);
      }
      // Start countdown ticking
      context.read<CountdownCubit>().start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20090A),
      body: const WeeklyStarEventViewBody(),
    );
  }
}

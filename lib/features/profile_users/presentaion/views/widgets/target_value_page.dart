import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/service_locator.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/post_chargers_page.dart';
import 'package:lklk/generated/l10n.dart';


class TargetValuePage extends StatefulWidget {
  const TargetValuePage({super.key});

  @override
  State<TargetValuePage> createState() => _TargetValuePageState();
}

class _TargetValuePageState extends State<TargetValuePage> {
  @override
  void initState() {
    super.initState();
    // Ensure latest profile values (e.g., target2) with a quick refresh
    sl<UserCubit>().getProfileUser("target_value_page", fast: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        // backgroundColor: AppColors.goldenRoyal,
        appBar: AppBar(
          title: AutoSizeText(S.of(context).target),
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (mounted) Navigator.of(context).pop();
            },
          ),
        ),
        body: BlocBuilder<UserCubit, UserCubitState>(
          bloc: sl<UserCubit>(),
          builder: (context, state) {
            final target2 = state.user?.target2 ?? sl<UserCubit>().state.user?.target2;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: AutoSizeText(
                    "target2",
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flag_outlined),
                        const SizedBox(width: 8),
                        AutoSizeText(
                          (target2 != null && target2.isNotEmpty) ? target2 : "-",
                          style: Theme.of(context).textTheme.headlineSmall,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: const Size(240, 52),
                    ),
                    icon: const Icon(
                      Icons.bolt_outlined,
                      color: AppColors.black,
                    ),
                    label: const AutoSizeText("Post Chargers"),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PostChargersPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/weekly_star_event/cubit/weekly_tab_cubit.dart';
import 'package:lklk/features/weekly_star_event/l10n/weekly_l10n_ext.dart';
import 'package:lklk/features/weekly_star_event/view/btn_event_week.dart';
import 'package:lklk/generated/l10n.dart';

class BtnsRowSection extends StatelessWidget {
  const BtnsRowSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return BlocBuilder<WeeklyTabCubit, WeeklyTab>(
      builder: (context, tab) {
        final isThisActive = tab == WeeklyTab.thisWeek;
        final isBounsActive = tab == WeeklyTab.bouns;
        String bg(bool active) => active
            ? 'assets/event/this week button.png'
            : 'assets/event/Bouns button.png';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => context.read<WeeklyTabCubit>().select(WeeklyTab.thisWeek),
              child: BtnEventWeek(
                imageBtn: bg(isThisActive),
                text: t.thisWeekLabel,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.read<WeeklyTabCubit>().select(WeeklyTab.bouns),
              child: BtnEventWeek(
                imageBtn: bg(isBounsActive),
                text: t.bounsLabel,
              ),
            ),
          ],
        );
      },
    );
  }
}

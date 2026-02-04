// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/tasks/presentation/views/tasks_page.dart';

class TasksInfoUpgrade extends StatelessWidget {
  const TasksInfoUpgrade({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // فتح صفحة المهام عند الضغط
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TasksPage(),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding:
            const EdgeInsets.only(top: 25, bottom: 15, right: 15, left: 15),
        margin: const EdgeInsets.only(right: 20, left: 20, top: 40, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: AppColors.white,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white,
              AppColors.white,
              // const Color(0xFF4A90E2).withValues(alpha: 0.03),
            ],
          ),
          boxShadow: [
            // BoxShadow(
            //   color: const Color(0xFF4A90E2).withValues(alpha: 0.15),
            //   blurRadius: 15,
            //   offset: const Offset(0, 5),
            //   spreadRadius: 2,
            // ),
            // BoxShadow(
            //   color: Colors.white.withValues(alpha: 0.7),
            //   blurRadius: 10,
            //   offset: const Offset(-3, -3),
            // ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AutoSizeText(
              S.of(context)!.howToUpgrade,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
            const Divider(
              thickness: 1.5,
              color: Color(0xFF4A90E2),
              indent: 40,
              endIndent: 40,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF4A90E2),
                          const Color(0xFF4A90E2).withValues(alpha: .6),
                        ]),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                      child: Icon(
                    FontAwesomeIcons.tasks,
                    color: Colors.white,
                    size: 26,
                  )),
                ),
                const SizedBox(
                  width: 18,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        S.of(context)!.completeVariousTasks,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AutoSizeText(
                        S.of(context)!.toReachLevelsAndRewards,
                        style: const TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4A90E2).withValues(alpha: .12),
                    const Color(0xFF4A90E2).withValues(alpha: .08),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF4A90E2).withValues(alpha: .4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.handPointer,
                    color: Color(0xFF4A90E2),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  AutoSizeText(
                    S.of(context)!.clickHereToOpenTasksPage,
                    style: const TextStyle(
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

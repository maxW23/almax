// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/styles.dart';

class CountProfileWidget extends StatelessWidget {
  final String number;
  final String title;
  final Function()? onTap;
  final bool isAlert;
  final int? badgeCount; // optional numeric badge

  const CountProfileWidget({
    super.key,
    required this.number,
    required this.title,
    this.onTap,
    this.isAlert = false,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final int bCount = badgeCount ?? 0;
    final bool showNumericBadge = bCount > 0;
    String badgeLabel;
    if (bCount > 99) {
      badgeLabel = '99+';
    } else if (bCount > 0) {
      badgeLabel = '$bCount';
    } else {
      badgeLabel = '';
    }
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AutoSizeText(
                  number,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                  ),
                ),
                // Prefer numeric badge when provided, otherwise fallback to dot alert
                if (showNumericBadge)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badgeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                    ),
                  )
                else if (isAlert)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: AppColors.danger,
                      radius: 3,
                    ),
                  ),
              ],
            ),
            AutoSizeText(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Styles.textStyle14.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class CountProfileWidget extends StatelessWidget {
//   const CountProfileWidget({
//     super.key,
//     required this.number,
//     required this.title,
//     this.onTap,
//     this.isAlert = false,
//   });
//   final String number;
//   final String title;
//   final Function()? onTap;
//   final bool isAlert;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               AutoSizeText(
//                 number,
//                 style: Styles.textStyle28,
//               ),
//               isAlert
//                   ? const CircleAvatar(
//                       backgroundColor: AppColors.danger,
//                       radius: 3,
//                     )
//                   : const SizedBox()
//             ],
//           ),
//           AutoSizeText(
//             title,
//             textAlign: TextAlign.center,
//             style: Styles.textStyle14.copyWith(
//               color: AppColors.gray,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

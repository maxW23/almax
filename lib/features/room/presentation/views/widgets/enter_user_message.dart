// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:lklk/core/constants/app_colors.dart';
// import 'package:lklk/core/constants/styles.dart';
// import 'package:lklk/core/utils/gradient_text.dart';

// class EnterUserMessage extends StatelessWidget {
//   const EnterUserMessage({
//     super.key,
//     required this.text,
//   });
//   // final Message message;
//   final String text;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: IntrinsicWidth(
//         child: Container(
//           margin: const EdgeInsets.only(right: 18),
//           decoration: BoxDecoration(
//             color: AppColors.black.withValues(alpha: 0.8),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           child: Row(
//             children: [
//               GradientText(
//                 text,
//                 gradient: const LinearGradient(colors: [
//                   AppColors.orangePinkTwoColor,
//                   AppColors.pinkwhiteColor,
//                 ]),
//                 style: Styles.textStyle16.copyWith(color: AppColors.white),
//               ),
//               const SizedBox(
//                 width: 10,
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.whiteWithOpacity25,
//                   borderRadius: BorderRadius.circular(100),
//                 ),
//                 padding: const EdgeInsets.all(10),
//                 child: const Center(
//                   child: Icon(
//                     FontAwesomeIcons.volumeHigh,
//                     color: AppColors.pinkwhiteColor,
//                     size: 14,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

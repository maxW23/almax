// import 'package:flutter/material.dart';
// import 'package:lklk/core/constants/app_colors.dart';

// class TopRoomUsers extends StatelessWidget {
//   const TopRoomUsers({super.key, required this.pathImage, required this.value, this.onTap});
//  final  String pathImage;
//   final  String value;
//    final void Function()? onTap;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.whiteWithOpacity25,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//         child: Row(
//           children: [
//             Image.asset(
//               pathImage,
//               height: 26,
//               width: 28,
//               fit: BoxFit.contain,
//             ),
//             const SizedBox(width: 10),
//             AutoSizeText(value,
//                 style: const TextStyle(
//                   color: AppColors.whiteIcon,
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }

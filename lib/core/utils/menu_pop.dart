// // import 'package:flutter/material.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:lklk/core/constants/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:lklk/core/constants/app_colors.dart';

// class CustomPopupMenuButton extends StatelessWidget {
//   const CustomPopupMenuButton({
//     super.key,
//     this.child,
//     this.onSelected,
//   });

//   final Widget? child;
//   final Function(String)? onSelected;

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<String>(
//       onSelected: onSelected,
//       itemBuilder: (BuildContext context) => [
//         _buildPopupMenuItem('Language', FontAwesomeIcons.language, 'Language'),
//         _buildPopupMenuItem(
//             'Report a problem', FontAwesomeIcons.info, 'Report a Problem'),
//         _buildPopupMenuItem('Theme', FontAwesomeIcons.paintbrush, 'Theme'),
//         _buildPopupMenuItem('Country', FontAwesomeIcons.globe, 'Country'),
//         _buildPopupMenuItem('About the developers', FontAwesomeIcons.user,
//             'About the Developers'),
//       ],
//       splashRadius: 1,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//       ),
//       // offset: const Offset(200, 600),
//       elevation: 0,
//       color: AppColors.gray,
//       child: Padding(
//         padding: const EdgeInsets.all(10),
//         child: child,
//       ),
//     );
//   }

//   PopupMenuItem<String> _buildPopupMenuItem(
//       String value, IconData icon, String text) {
//     return PopupMenuItem<String>(
//       value: value,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 20,
//             child: Center(
//               child: FaIcon(
//                 icon,
//                 color: AppColors.black,
//               ),
//             ),
//           ),
//           const SizedBox(width: 25),
//           AutoSizeText(text),
//         ],
//       ),
//     );
//   }
// }

// // class CustomPopupMenuButton extends StatelessWidget {
// //   const CustomPopupMenuButton({
// //     super.key,
// //     this.child,
// //   });
// //   final Widget? child;
// //   @override
// //   Widget build(BuildContext context) {
// //     return PopupMenuButton<String>(
// //       onSelected: (value) {},
// //       itemBuilder: (BuildContext context) => [
// //         _buildPopupMenuItem('Language', FontAwesomeIcons.language, 'Language'),
// //         _buildPopupMenuItem(
// //             'Report a problem', FontAwesomeIcons.info, 'Report a Problem'),
// //         _buildPopupMenuItem('Theme', FontAwesomeIcons.paintbrush, 'Theme'),
// //         _buildPopupMenuItem('Country', FontAwesomeIcons.globe, 'Country'),
// //         _buildPopupMenuItem('About the developers', FontAwesomeIcons.user,
// //             'About the Developers'),
// //       ],
// //       splashRadius: 1,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(18),
// //       ),
// //       offset: const Offset(40, 40),
// //       elevation: 0,
// //       color: AppColors.gray,
// //       child: Padding(
// //         padding: const EdgeInsets.all(10),
// //         child: child,
// //       ),
// //     );
// //   }

// //   _buildPopupMenuItem(String value, IconData icon, String text) {
// //     return PopupMenuItem<String>(
// //       value: value,
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //             width: 20,
// //             child: Center(
// //               child: FaIcon(
// //                 icon,
// //                 color: AppColors.white,
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 25),
// //           AutoSizeText(text),
// //         ],
// //       ),
// //     );
// //   }
// // }

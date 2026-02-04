// import 'package:flutter/material.dart';
// import 'package:lklk/core/widgets/best50_icon.dart';
// import 'package:lklk/core/widgets/create_room_icon.dart';
// import 'package:lklk/generated/l10n.dart';
// import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
// import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
// import 'custom_text_button.dart';
// import 'search_icon_button.dart';

// class HomeRoomAppbar extends StatefulWidget implements PreferredSizeWidget {
//   const HomeRoomAppbar(
//       {super.key, required this.userCubit, required this.roomCubit});
//   final RoomCubit roomCubit;
//   final UserCubit userCubit;

//   @override
//   State<HomeRoomAppbar> createState() => _HomeRoomAppbarState();

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

// class _HomeRoomAppbarState extends State<HomeRoomAppbar> {
//   int selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFFB500D9), // بنفسجي فاتح
//             Color(0xFF7A0099), // بنفسجي غامق
//           ],
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.transparent,
//           elevation: 0.0,
//           actions: [
//             Row(
//               children: [
//                 SearchIconButton(
//                   userCubit: widget.userCubit,
//                   roomCubit: widget.roomCubit,
//                 ),
//                 CreateRoomIcon(
//                   roomCubit: widget.roomCubit,
//                   userCubit: widget.userCubit,
//                 ),
//                 Best50Icon(userCubit: widget.userCubit)
//               ],
//             ),
//             const Spacer(),
//             CustomTextButton(S.of(context).popular, 0, selectedIndex,
//                 () => _handleButtonClick(0)),
//             CustomTextButton(S.of(context).me, 1, selectedIndex,
//                 () => _handleButtonClick(1)),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handleButtonClick(int index) {
//     setState(() {
//       selectedIndex = index;
//     });
//   }
// }

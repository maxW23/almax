// import 'package:lklk/core/utils/logger.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
// import 'package:lklk/features/room/presentation/views/widgets/room_view_bloc.dart';
// import '../../../../../core/constants/app_colors.dart';
// import '../../manger/room_cubit/room_cubit_cubit.dart';
// import '../../../../room/domain/entities/room_entity.dart';

// class ResponsiveButtonWidget extends StatefulWidget {
//   const   ResponsiveButtonWidget(
//       {super.key, required this.userCubit, required this.roomCubit});
//   final UserCubit userCubit;
//   final RoomCubit roomCubit;

//   @override
//   State<ResponsiveButtonWidget> createState() => _ResponsiveButtonWidgetState();
// }

// class _ResponsiveButtonWidgetState extends State<ResponsiveButtonWidget>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   bool isTapped = false;
//   RoomEntity? room;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 10000),
//     );
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double w = MediaQuery.of(context).size.width;

//     return Align(
//       alignment: Alignment.center,
//       child: InkWell(
//         onTapDown: (_) {
//           setState(() {
//             isTapped = true;
//             _controller.forward();
//           });
//         },
//         onTapCancel: () {
//           setState(() {
//             isTapped = false;
//             _controller.reverse();
//           });
//         },
//         onTap: () async {
//           try {
//             // final User? user = roomCubit.user;

//             final createdRoom = await widget.roomCubit.createRoom();

//             if (createdRoom != null) {
//               setState(() {
//                 room = createdRoom;
//               });

//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => RoomViewBloc(
//                     roomId: room!.id,
//                     roomCubit: widget.roomCubit,
//                     userCubit: widget.userCubit,
//                   ),
//                 ),
//               );

//               //log('send room $createdRoom');
//             } else {
//               SnackbarHelper.showMessage(
//                 const SnackBar(
//                   content: AutoSizeText('Failed to create room. Please try again.'),
//                 ),
//               );
//             }
//           } catch (e) {
//             AppLogger.debug('Error creating room: $e');
//             SnackbarHelper.showMessage(
//               const SnackBar(
//                 content: AutoSizeText('An error occurred. Please try again later.'),
//               ),
//             );
//           } finally {
//             setState(() {
//               isTapped = false; // Reset state after operation completes
//               _controller.reverse();
//             });
//           }
//         },
//         child: Center(
//           child: AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: 1.0 + (_animation.value * 0.1), // Scale effect
//                 child: Container(
//                   padding: EdgeInsets.all(w / 30),
//                   margin: EdgeInsets.only(
//                     top: w / 30,
//                     left: w / 30,
//                     right: w / 30,
//                   ),
//                   width: isTapped ? w - 120 : w,
//                   height: isTapped ? 55 : 70,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(colors: [
//                       AppColors.primary,
//                       AppColors.white,
//                     ]),
//                     borderRadius: const BorderRadius.all(
//                       Radius.circular(30),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.3 * _animation.value),
//                         blurRadius: 30 * _animation.value,
//                         offset: const Offset(3, 7),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: isTapped
//                         ? const SpinKitRipple(
//                             color: AppColors.white,
//                           )
//                         // const CircularProgressIndicator(
//                         //     valueColor:
//                         //         AlwaysStoppedAnimation<Color>(AppColors.white),
//                         //   )
//                         : AutoSizeText(
//                             'Create a Room',
//                             style: TextStyle(
//                               color: Colors.white.withValues(alpha: 0.7),
//                               fontWeight: FontWeight.w500,
//                               fontSize: 19,
//                             ),
//                           ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

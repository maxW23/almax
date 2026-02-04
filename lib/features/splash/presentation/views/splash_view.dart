import 'package:flutter/material.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import '../../../../core/widgets/linear_gradient_widget.dart';
import 'widgets/splash_view_body.dart';

class SplashView extends StatelessWidget {
  const SplashView(
      {super.key, required this.userCubit, required this.roomCubit});
  final UserCubit userCubit;
  final RoomCubit roomCubit;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // const LinearGradientWidget(),
LklkBackgroundSplash(),
          SplashViewbody(userCubit: userCubit, roomCubit: roomCubit),
        ],
      ),
    );
  }
}
class LklkBackgroundSplash extends StatelessWidget {
  const LklkBackgroundSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset("assets/images/splash/lklk_background.jpg",
    width: MediaQuery.sizeOf(context).width,
    height: MediaQuery.sizeOf(context).height,
    fit: BoxFit.cover,

    );
  }
}
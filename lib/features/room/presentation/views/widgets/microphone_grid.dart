import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/microphone_item.dart';

class MicrophoneGrid extends StatelessWidget {
  final RoomEntity room;
  const MicrophoneGrid({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return SizedBox(
      height: h / 2.9,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 4,
          mainAxisSpacing: 8,
        ),
        itemCount: int.parse(room.microphoneNumber),
        itemBuilder: (context, index) {
          final UserEntity user = context.read<UserCubit>().user!;
// ToDo
          //log('user ::::::::::::::::::::::::::::::::: $user');
          if (index == 1 || index == 12) {
            return user.img == '' || user.img == null
                ? MicrophoneItem(
                    userName: 'User ${index + 1}',
                    imagePath: AssetsData.userTestNetwork, isEmpty: true,
                    //  'path/to/user$imageIndex.png',
                  )
                : MicrophoneItem(
                    userName: user.name!,
                    imagePath: user.img ?? '',
                    isEmpty: false,
                  );
          } else {
            return MicrophoneItem(
              userName: 'User ${index + 1}',
              imagePath: AssetsData.userTestNetwork,
              isEmpty: true,
            );
          }
        },
      ),
    );
  }
}

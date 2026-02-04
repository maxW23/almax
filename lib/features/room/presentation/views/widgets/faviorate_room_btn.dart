import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/room/domain/entities/room_entity.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FavoriteRoomBtn extends StatelessWidget {
  const FavoriteRoomBtn({super.key, required this.room});
  final RoomEntity room;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomCubit, RoomCubitState>(
      listener: (context, state) {},
      builder: (context, state) {
        return GestureDetector(
          onTap: () async {
            try {
              final roomCubit = context.read<RoomCubit>();
              await roomCubit.addFavoraiteRoom(room.id);
            } catch (e, stackTrace) {
              log('Error in addFavoriteRoom', error: e, stackTrace: stackTrace);
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(
                SnackBar(
                    content: Text(
                        'Failed to update favorite status: ${e.toString()}')),
              );
            }
          },
          child: state.status.isAFavoriteLoading
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.10,
                  height: MediaQuery.of(context).size.width * 0.10,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 1.5,
                    ),
                  ),
                )
              : SvgPicture.asset(
                  AssetsData.favoriteRoomBtnSvg,
                  width: MediaQuery.of(context).size.width * 0.10,
                  height: MediaQuery.of(context).size.width * 0.10,
                ),
        );
      },
    );
  }
}

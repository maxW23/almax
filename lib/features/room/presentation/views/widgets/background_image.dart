import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';

class BackgroundImageWidget extends StatelessWidget {
  const BackgroundImageWidget({
    super.key,
    required this.backgroundImage,
    required this.roomCubit,
  });
  final String? backgroundImage;
  final RoomCubit roomCubit;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomCubit, RoomCubitState>(
      builder: (context, state) {
        String? background = backgroundImage;

        if (state.status.isRoomLoaded) {
          background = state.room?.background;
        }
        // else if (state.status.isInitial) {
        //   background = backgroundImage;

        final size = MediaQuery.of(context).size;
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final targetW = (size.width * dpr).toInt();
        final targetH = (size.height * dpr).toInt();
        final String? effectiveBg = background ?? backgroundImage;
        return RepaintBoundary(
          child: effectiveBg != null
              ? Container(
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        effectiveBg,
                        maxWidth: targetW,
                        maxHeight: targetH,
                      ),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                )
              : const SizedBox(),
        );
      },
    );
  }
}

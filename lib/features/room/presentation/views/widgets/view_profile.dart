import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/generated/l10n.dart';

class ViewProfileRoom extends StatelessWidget {
  const ViewProfileRoom({super.key, this.onTap, required this.urlRoomImage});

  final Function()? onTap;
  final String urlRoomImage;

  @override
  Widget build(BuildContext context) {
    String imageUrl = urlRoomImage.contains('https://lklklive.com/')
        ? urlRoomImage
        : 'https://lklklive.com/img/$urlRoomImage';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            '🎨 ${S.of(context).roomAvatar}',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: BlocBuilder<RoomCubit, RoomCubitState>(
              builder: (context, state) {
                if (state.status.isRoomUpdated && state.room != null) {
                  imageUrl = state.room!.img.contains('https://lklklive.com/')
                      ? state.room!.img
                      : 'https://lklklive.com/img/${state.room!.img}';
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: AppColors.white, width: 2.0),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(
                        imageUrl,
                        // حجم كاش محسن لصور الملف الشخصي 60×60
                        maxWidth: 120,
                        maxHeight: 120,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

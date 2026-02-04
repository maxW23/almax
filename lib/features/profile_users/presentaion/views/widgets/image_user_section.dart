import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/image_helper.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/circular_user_image.dart';
import 'package:lklk/generated/l10n.dart';

class ImageUserSectionWithEdit extends StatefulWidget {
  const ImageUserSectionWithEdit({
    super.key,
    required this.userCubit,
    required this.user,
  });

  final UserCubit userCubit;
  final UserEntity user;

  @override
  State<ImageUserSectionWithEdit> createState() =>
      _ImageUserSectionWithEditState();
}

class _ImageUserSectionWithEditState extends State<ImageUserSectionWithEdit> {
  late UserEntity currentUser;

  @override
  void initState() {
    currentUser = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserCubitState>(
      listener: (context, state) {
        if (state.status.isLoaded) {
          setState(() {
            currentUser = state.user!;
          });
        }
        if (state.status.isLoadedById) {
          setState(() {
            currentUser = state.userOther!;
          });
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () async {
            File? file = await ImageHelper.pickImage(
              cropToSquare: true,
              targetHeight: 400,
              targetWidth: 400,
              isCrop: true,
              context: context,
              useCustomCropper: true,
            );
            if (file == null) {
              // Check if the selected file was a GIF (track this in your state)
              // Show snackbar
              SnackbarHelper.showMessage(
                context,
                'الصورة كبيرة جدًا ولا يمكن تحميلها',
              );
            }
            if (file != null) {
              await widget.userCubit.editUserProfile(image: file);
            }
            await widget.userCubit.getProfileUser("ImageUserSectionWithEdit");
            SnackbarHelper.showMessage(
              context,
              '${S.of(context).waitforcheckyouimage} ',
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // subtle circular shadow behind avatar
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              CircularUserImage(
                imagePath: currentUser.img,
                isEmpty: false,
                radius: 50,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    FontAwesomeIcons.solidEdit,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

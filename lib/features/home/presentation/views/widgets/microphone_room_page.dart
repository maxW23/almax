import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/utils/gradient_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../manger/room_cubit/room_cubit_cubit.dart';
import '../../../../room/domain/entities/room_entity.dart';
import '../../../../../core/constants/app_colors.dart';

class MicophoneRoomPage extends StatelessWidget {
  const MicophoneRoomPage(
      {super.key, required this.room, required this.roomCubit});

  final RoomCubit roomCubit;
  final RoomEntity room;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: MicrophoneRoomBody(room: room, roomCubit: roomCubit),
      ),
    );
  }
}

class MicrophoneRoomBody extends StatefulWidget {
  const MicrophoneRoomBody(
      {super.key, required this.room, required this.roomCubit});

  final RoomEntity room;
  final RoomCubit roomCubit;

  @override
  State<MicrophoneRoomBody> createState() => _MicrophoneRoomBodyState();
}

class _MicrophoneRoomBodyState extends State<MicrophoneRoomBody> {
  int selectedIndex = 15;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            GradientText(
              '${S.of(context).chooseNumber} 🎤:',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [10, 15, 20].map((number) {
                return CustomTextButton(
                  text: number.toString(),
                  isSelected: selectedIndex == number,
                  onPressed: () => setState(() => selectedIndex = number),
                );
              }).toList(),
            ),
            const Spacer(),
            AcceptButtonWidget(
                selectedIndex: selectedIndex,
                roomCubit: widget.roomCubit,
                room: widget.room),
          ],
        ),
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  const CustomTextButton(
      {super.key,
      required this.text,
      required this.isSelected,
      required this.onPressed});

  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // color: isSelected
        //     ? AppColors.secondColorDark
        //     : AppColors.blackWithOpacity5,
        gradient: isSelected
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.secondColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [AppColors.whiteGrey, AppColors.whiteGrey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                    color: AppColors.secondColorDark.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2)
              ]
            : [],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
        child: AutoSizeText(
          text,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}

class AcceptButtonWidget extends StatelessWidget {
  const AcceptButtonWidget(
      {super.key,
      required this.selectedIndex,
      required this.roomCubit,
      required this.room});

  final int selectedIndex;
  final RoomEntity room;
  final RoomCubit roomCubit;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomCubit, RoomCubitState>(
      listener: (context, state) {},
      builder: (context, state) {
        return GestureDetector(
          onTap: () async {
            await roomCubit.editMicrophoneNumber(
                room.id, selectedIndex.toString());
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            child: AutoSizeText(
              S.of(context).accept,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GradientText(
        S.of(context).numberOfMicrophone,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.black12,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CreateRoomAppbar extends StatefulWidget implements PreferredSizeWidget {
  // final int selectedNumber;

  const CreateRoomAppbar({super.key});

  @override
  State<CreateRoomAppbar> createState() => _CreateRoomAppbarState();

  static State<CreateRoomAppbar>? of(BuildContext context) =>
      context.findAncestorStateOfType<_CreateRoomAppbarState>();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CreateRoomAppbarState extends State<CreateRoomAppbar> {
  // late int selectedNumber;

  @override
  void initState() {
    super.initState();
    // selectedNumber = widget.selectedNumber;
  }

  void updateSelectedNumber(int number) {
    setState(() {
      // selectedNumber = number;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return AppBar(
      // leading: const AcceptWidget(),
      leadingWidth: width / 4.5,
      backgroundColor: AppColors.whiteIcon,
      elevation: 0.0,
      title: AutoSizeText(
        S.of(context).numberOfMicrophone,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }
}

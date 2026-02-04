import 'package:lklk/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/room/presentation/views/widgets/custom_duration_dialog.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';

class IsAddIconRed extends StatelessWidget {
  const IsAddIconRed({
    super.key,
    required this.widget,
    this.type,
  });

  final UserWidgetTitle widget;
  final String? type;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        widget.icon ?? FontAwesomeIcons.circlePlus,
        color: AppColors.danger,
      ),
      onPressed: () async {
        if (widget.onUserAction != null) {
          String? how;

          if (widget.typeOfIconRoomSettings == "Block User") {
            // هون صار يكتب بنفس المتحول الخارجي
            how = await showDialog<String>(
              context: context,
              builder: (ctx) => const CustomDurationDialog(),
            );
          }

          log("/ban/user/room.  $how");

          await widget.onUserAction!(
            widget.roomId!,
            widget.user.iduser,
            how ?? "",
          );
        }
      },
    );
  }
}

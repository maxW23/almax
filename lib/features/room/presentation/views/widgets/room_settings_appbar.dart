import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoomSettingsAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const RoomSettingsAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.times),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        elevation: 0.0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/Settings_icon.svg',
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 8),
            AutoSizeText(
              S.of(context).roomSettings,
              style: Styles.textStyle26,
            ),
          ],
        ),
        centerTitle: true,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

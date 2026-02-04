import 'package:flutter/material.dart';
import 'package:lklk/features/room/domain/entities/game_bean.dart';
import 'package:lklk/features/room/domain/entities/game_config.dart';
import 'package:lklk/features/room/presentation/views/widgets/game_web_view_page.dart';

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

// lklk_game_add
void showGameUrl(
  BuildContext context,
  GameBean game,
  GameConfig config,
) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: context,
    isScrollControlled: false,
    enableDrag: false,
    isDismissible: false,
    builder: (BuildContext context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GameWebViewPage(
          url: game.url!,
          config: config,
        ),
      );
    },
  );
}

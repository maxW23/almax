import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/image_loader.dart';
import 'package:lklk/features/room/domain/entities/game_bean.dart';
import 'package:lklk/features/room/domain/entities/game_config.dart';
import 'package:lklk/features/room/presentation/views/widgets/show_game_url.dart';

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

// lklk_game_add
void showGameList(
  BuildContext context,
  List<GameBean> games,
  GameConfig config,
) {
  showModalBottomSheet(
     backgroundColor: AppColors.darkColor,
      barrierColor: Colors.transparent,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const AutoSizeText(
                "Game Center",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            Expanded(
                child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisExtent: 70,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 6),
                    itemCount: games.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          showGameUrl(context, games[index], config);
                        },
                        child: Center(
                          child: Column(
                            children: [
                              ImageLoader(
                                imageUrl: games[index].icon!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholderColor: Colors.grey.shade300,
                                fallbackWidget: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                  ),
                                  child: const Icon(
                                    Icons.error,
                                    color: const Color(0xFFFF0000),
                                    size: 30,
                                  ),
                                ),
                              ),
                              AutoSizeText(
                                games[index].name ?? '',
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    }))
          ],
        ),
      );
    },
  );
}

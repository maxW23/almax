import 'package:flutter/material.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';

class SvgaGiftsTest extends StatelessWidget {
  const SvgaGiftsTest({super.key});
  @override
  Widget build(BuildContext context) {
    List<ElementEntity> levels = [
      // ElementEntity(
      //   fileDuration: const Duration(seconds: 5),
      //   id: 1104,
      //   img: '',
      //   price: 277,
      //   elementName: '',
      //   linkPath: 'assets/vip_levels/1.svga',
      //   type: 'popular',
      // ),
      // ElementEntity(
      //   fileDuration: const Duration(seconds: 5),
      //   id: 1104,
      //   img: '',
      //   price: 277,
      //   elementName: '',
      //   linkPath: 'assets/vip_levels/2.svga',
      //   type: 'popular',
      // ),
      // ElementEntity(
      //   fileDuration: const Duration(seconds: 5),
      //   id: 1104,
      //   img: '',
      //   price: 277,
      //   elementName: '',
      //   linkPath: 'assets/vip_levels/3.svga',
      //   type: 'popular',
      // ),
      // ElementEntity(
      //   fileDuration: const Duration(seconds: 5),
      //   id: 1104,
      //   img: '',
      //   price: 277,
      //   elementName: '',
      //   linkPath: 'assets/vip_levels/4.svga',
      //   type: 'popular',
      // ),
      // ElementEntity(
      //   fileDuration: const Duration(seconds: 5),
      //   id: 1104,
      //   img: '',
      //   price: 277,
      //   elementName: '',
      //   linkPath: 'assets/vip_levels/5.svga',
      //   type: 'popular',
      // ),
      // ElementEntity(
      //   fileDuration: const Duration(seconds: 5),
      //   id: 1104,
      //   img: '',
      //   price: 277,
      //   elementName: '',
      //   linkPath: 'assets/vip_levels/6.svga',
      //   type: 'popular',
      // ),
    ];
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: levels.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 120,
                    ),
                    CustomSVGAWidget(
                      height: 100,
                      width: double.infinity,
                      isRepeat: true,
                      pathOfSvgaFile: SvgaUtils.getValidFilePath(
                              levels[index].elamentId.toString()) ??
                          levels[index].linkPathLocal ??
                          levels[index].linkPath!,
                    ),
                    const SizedBox(
                      height: 120,
                    ),
                    // AutoSizeText(
                    //   '$index ${levels[index].linkPath} ',
                    //   style: const TextStyle(color: Colors.black, fontSize: 22),
                    // ),
                    // AutoSizeText(
                    //   '${levels[index].price}',
                    //   style: const TextStyle(color: Colors.black, fontSize: 22),
                    // ),
                    // AutoSizeText(
                    //   '${levels[index].type}',
                    //   style: const TextStyle(color: Colors.black, fontSize: 22),
                    // ),
                    // const SizedBox(
                    //   height: 40,
                    // ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

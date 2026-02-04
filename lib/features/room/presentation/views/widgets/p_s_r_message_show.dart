import 'package:flutter/material.dart';
import 'package:lklk/core/animations/images_slides_animation_animated_game_asset_display.dart';
import 'package:lklk/core/constants/assets.dart';

class PSRMessageShow extends StatelessWidget {
  const PSRMessageShow({
    super.key,
    required this.text,
  });
  final String text;
  int _parsePSRValue() {
    final value = int.tryParse(text) ?? 1;
    return value.clamp(1, 3); // تأكيد النطاق 1-3
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGameAssetDisplay(
      // message: message,
      assets: const [
        AssetsData.paperGame, // index 0 -> قيمة 1
        AssetsData.rockGame, // index 1 -> قيمة 2
        AssetsData.scissorsGame, // index 2 -> قيمة 3
      ],
      fit: BoxFit.fill,
      targetValue: _parsePSRValue(),
    );
  }
}

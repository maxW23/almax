import 'package:flutter/material.dart';
import 'package:lklk/core/animations/images_slides_animation_animated_game_asset_display.dart';
import 'package:lklk/core/constants/assets.dart';

class DiceMessageShow extends StatelessWidget {
  // final Message message;
  final String text, id;
  const DiceMessageShow({
    super.key,
    required this.text,
    required this.id,
  });

  int _parseDiceValue() {
    final value = int.tryParse(text) ?? 1;
    return value.clamp(1, 6); // تأكيد النطاق 1-6
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGameAssetDisplay(
      // message: message,
      id: id,
      assets: [
        AssetsData.dice1,
        AssetsData.dice2,
        AssetsData.dice3,
        AssetsData.dice4,
        AssetsData.dice5,
        AssetsData.dice6,
      ],
      targetValue: _parseDiceValue(),
    );
  }
}

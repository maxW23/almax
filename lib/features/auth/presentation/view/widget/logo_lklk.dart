import 'package:flutter/material.dart';
import 'package:lklk/core/constants/assets.dart';

class LogoLKLK extends StatelessWidget {
  const LogoLKLK({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        AssetsData.logo,
        height: 100,
        width: 100,
      ),
    );
  }
}

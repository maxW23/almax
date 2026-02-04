import 'package:flutter/material.dart';
import 'package:lklk/core/constants/styles.dart';
import 'package:lklk/core/utils/gradient_text.dart';

class EnterMessageRoomVIPBody extends StatelessWidget {
  const EnterMessageRoomVIPBody({
    super.key,
    required this.vipAssets,
    required this.colorFontOne,
    required this.colorFontTwo,
    required this.padding,
    this.alignment = Alignment.centerRight,
    required this.text,
  });
  final String vipAssets;
  final Color colorFontOne;
  final Color colorFontTwo;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final String text;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // color: Colors.amber,
      height: 72,
      width: 250,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: GradientText(
            text,
            gradient: LinearGradient(colors: [
              colorFontOne,
              colorFontTwo,
            ]),
            style: Styles.textStyle12bold,
          ),
        ),
      ),
    );
  }
}

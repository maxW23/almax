import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomIconTextButtonBody extends StatelessWidget {
  const CustomIconTextButtonBody({
    super.key,
    required this.icon,
    required this.title,
    required this.title2,
    required this.isPressed,
    required this.activeIconColor,
    required this.inactiveIconColor,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String title2;
  final bool isPressed;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return
        // Container(
        //   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(20),
        //     border: Border.all(color: Colors.grey),
        //     boxShadow: const [
        //       BoxShadow(
        //         color: Colors.grey,
        //         blurRadius: 1,
        //         spreadRadius: .4,
        //         blurStyle: BlurStyle.inner,
        //       ),
        //     ],
        //   ),
        // child:
        Column(
      children: [
        TextButton(
          onPressed: onPressed,
          child: Icon(
            icon,
            color: isPressed ? activeIconColor : inactiveIconColor,
          ),
          // ),
        ),
        AutoSizeText(
          (isPressed ? title : title2),
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}

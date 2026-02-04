// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomButtonIconAndtext extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final void Function()? onPressed;
  const CustomButtonIconAndtext({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 1,
            spreadRadius: .4,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: TextButton.icon(
          icon: Icon(
            icon,
            color: color,
          ),
          label: AutoSizeText(
            text,
            style: const TextStyle(color: Colors.black),
          ),
          onPressed: onPressed),
    );
  }
}

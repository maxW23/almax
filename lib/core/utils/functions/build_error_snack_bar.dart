import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

SnackBar buildErrorWidget(String errMessage) {
  return SnackBar(
    content: AutoSizeText(
      errMessage,
      style: const TextStyle(),
      textAlign: TextAlign.center,
    ),
    duration: const Duration(seconds: 3),
  );
}

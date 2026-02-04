// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStateWidget extends StatefulWidget {
  const ProfileStateWidget({
    super.key,
    required this.profileState,
  });
  final String profileState;

  @override
  State<ProfileStateWidget> createState() => _ProfileStateWidgetState();
}

class _ProfileStateWidgetState extends State<ProfileStateWidget> {
  bool _isArabicText(String text) {
    if (text.isEmpty) return false;

    // تحسين الدالة للتحقق من وجود أي حرف عربي في النص
    final arabicRegex = RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');

    // حساب نسبة الأحرف العربية في النص
    final arabicChars =
        text.split('').where((char) => arabicRegex.hasMatch(char)).length;
    final totalChars = text.length;

    // إذا كانت نسبة الأحرف العربية أكثر من 30% نعتبرها نص عربي
    return (arabicChars / totalChars) > 0.3;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 30.h,
      child: AutoSizeText(
        widget.profileState != "null" ? widget.profileState : "",
        textAlign: _isArabicText(widget.profileState)
            ? TextAlign.right
            : TextAlign.left,
        textDirection: _isArabicText(widget.profileState)
            ? TextDirection.rtl
            : TextDirection.ltr,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/gradient_text.dart';

class LuckyMessageItemWidget extends StatelessWidget {
  // final Message message;
  final String text;
  const LuckyMessageItemWidget({
    super.key,
    required this.text,
    // required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
          width: MediaQuery.of(context).size.width / 1.4,
          alignment: Alignment.topRight,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 1.4,
          ),
          margin: const EdgeInsets.only(right: 8, left: 8, top: 20, bottom: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: .125),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            // textDirection: text.contains(
            //   RegExp(
            //     r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\uFB50-\uFDFF\uFE70-\uFEFF]',
            //   ),
            // )
            //     ? TextDirection.rtl
            //     : TextDirection.ltr,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: GradientText(
                    text,
                    maxLines: 4,
                    gradient: const LinearGradient(colors: [
                      AppColors.white,
                      AppColors.white,
                      // AppColors.goldenhad2,
                    ]),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

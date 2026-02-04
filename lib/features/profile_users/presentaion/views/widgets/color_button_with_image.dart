// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/animations/shimmer_widget.dart';
import 'package:lklk/core/utils/functions/is_arabic.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class ColorButtonWithImage extends StatelessWidget {
  final Color color;
  final Color titleColor;
  final String title;
  final String text;
  final String image;
  final double width;
  final void Function()? onTap;
  const ColorButtonWithImage({
    super.key,
    required this.color,
    required this.titleColor,
    required this.title,
    required this.text,
    required this.image,
    this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    String selectedLanguage = 'en';
    final languageCubit = context.read<LanguageCubit>();
    selectedLanguage = languageCubit.state.languageCode;
    return GestureDetector(
      onTap: onTap,
      child: Directionality(
        textDirection: getTextDirection(selectedLanguage),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          width: size.width / 2.2,
          height: 100,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .68),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Stack(
                      children: [
                        AutoSizeText(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            color: titleColor,
                            shadows: const [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        Shimmer(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: .3),
                              Colors.transparent,
                            ],
                          ),
                          child: AutoSizeText(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AutoSizeText(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          // Shadow(
                          //   color: Colors.black,
                          //   blurRadius: 0.2,
                          //   offset: Offset(0, 0),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ShimmerWidget(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: width,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

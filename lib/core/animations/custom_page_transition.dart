import 'package:flutter/material.dart';

class CustomPageTransition {
  static PageRouteBuilder gentleTransition(Widget page,
      {Duration duration = const Duration(milliseconds: 600)}) {
    return PageRouteBuilder(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // منحنى الحركة (curve) للنعومة
        final curvedAnimation =
            CurvedAnimation(parent: animation, curve: Curves.easeInOut);

        // حركة التلاشي
        final fadeAnimation =
            Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);

        // حركة التكبير والتصغير (يبدأ صغير ويرتفع لحجمه الطبيعي)
        final scaleAnimation =
            Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation);

        // حركة الانزلاق الخفيفة من اليمين (مسافة صغيرة، 20% من العرض)
        final slideAnimation =
            Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
                .animate(curvedAnimation);

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

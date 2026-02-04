import 'package:flutter/material.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';

class AnimatedIconWidget extends StatefulWidget {
  final UserWidgetTitle widget;

  const AnimatedIconWidget({super.key, required this.widget});

  @override
  State<AnimatedIconWidget> createState() => _AnimatedIconWidgetState();
}

class _AnimatedIconWidgetState extends State<AnimatedIconWidget>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late IconData currentIcon;
  late Animation<double> rotationAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(controller);

    currentIcon = widget.widget.icon!;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleIcon() {
    setState(() {
      if (currentIcon == widget.widget.icon) {
        currentIcon = widget.widget.iconSecond!;
      } else {
        currentIcon = widget.widget.icon!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedBuilder(
        animation: rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: rotationAnimation.value * 2 * 3.14,
            child: Icon(
              currentIcon,
              color: widget.widget.iconColor,
            ),
          );
        },
      ),
      onPressed: () {
        _toggleIcon();
        if (controller.isCompleted) {
          //log('reverse');
          controller.reverse();
          widget.widget.isPressIcon2!();
        } else {
          //log('forward');
          controller.forward();
          widget.widget.isPressIcon!();
        }
      },
    );
  }
}

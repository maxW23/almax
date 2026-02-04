import 'package:flutter/material.dart';
import 'package:lklk/features/room/presentation/views/widgets/user_widget_title.dart';

class DefaultIcon extends StatelessWidget {
  const DefaultIcon({
    super.key,
    required this.widget,
  });

  final UserWidgetTitle widget;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        widget.icon,
        color: widget.iconColor,
      ),
      onPressed: widget.isPressIcon,
    );
  }
}

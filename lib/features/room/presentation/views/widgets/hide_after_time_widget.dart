import 'package:flutter/material.dart';

class HideAfterTimeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool shouldHide;

  const HideAfterTimeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 4100),
    this.shouldHide = true,
  });

  @override
  State<HideAfterTimeWidget> createState() => _HideAfterTimeWidgetState();
}

class _HideAfterTimeWidgetState extends State<HideAfterTimeWidget> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    if (widget.shouldHide) {
      Future.delayed(widget.duration, () {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible ? widget.child : const SizedBox.shrink();
  }
}

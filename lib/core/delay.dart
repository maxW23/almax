import 'package:flutter/material.dart';

class DelayedDisplay extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const DelayedDisplay({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 800),
  });

  @override
  State<DelayedDisplay> createState() => _DelayedDisplayState();
}

class _DelayedDisplayState extends State<DelayedDisplay> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _show = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _show ? widget.child : const SizedBox.shrink();
  }
}

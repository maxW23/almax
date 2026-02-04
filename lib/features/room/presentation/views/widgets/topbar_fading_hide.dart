import 'dart:async';
import 'package:flutter/material.dart';

class TopbarFadingHide extends StatefulWidget {
  final Widget child;
  final Duration visibleDuration;
  final Duration hideDuration;

  const TopbarFadingHide({
    super.key,
    required this.child,
    this.visibleDuration = const Duration(milliseconds: 2800),
    this.hideDuration = const Duration(milliseconds: 600),
  });

  @override
  State<TopbarFadingHide> createState() => _TopbarFadingHideState();
}

class _TopbarFadingHideState extends State<TopbarFadingHide> {
  Timer? _hideTimer;
  Timer? _showTimer;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel(); // إلغاء أي مؤقت قديم
    _hideTimer = Timer(widget.visibleDuration, () {
      if (mounted) {
        setState(() => _isVisible = false);
        _startShowTimer();
      }
    });
  }

  void _startShowTimer() {
    _showTimer?.cancel(); // إلغاء أي مؤقت قديم
    _showTimer = Timer(widget.hideDuration, () {
      if (mounted) {
        setState(() => _isVisible = true);
        _startHideTimer();
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _showTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: widget.hideDuration,
        child: widget.child,
      ),
    );
  }
}

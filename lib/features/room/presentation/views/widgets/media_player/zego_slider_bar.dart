import 'package:flutter/material.dart';
import 'dart:async';

class ZegoSliderBar extends StatefulWidget {
  const ZegoSliderBar({
    super.key,
    // this.progressStream,
    required this.onProgressChanged,
    this.value = 0,
    this.min = 0.0,
    this.max = 1.0,
    this.realTimeRefresh = false,
    this.fromOverlay,
  });

  // final Stream<double>? progressStream;
  final Function(double) onProgressChanged;
  final double value;
  final double min;
  final double max;
  final bool realTimeRefresh;
  final bool? fromOverlay;

  @override
  State<ZegoSliderBar> createState() => _ZegoSliderBarState();
}

class _ZegoSliderBarState extends State<ZegoSliderBar> {
  late double _playProgress;
  late StreamController<double> _playProgressStreamController;
  late Stream<double>? progressStream;
  StreamSubscription<double>? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _playProgress = widget.value;
    _playProgressStreamController = StreamController();
    progressStream = _playProgressStreamController.stream;
    if (progressStream != null) {
      // Convert to broadcast stream to allow multiple listeners
      final stream = progressStream!.asBroadcastStream();
      _progressSubscription = stream.listen((progress) {
        if (mounted) {
          setState(
              () => _playProgress = progress.clamp(widget.min, widget.max));
        }
      });
    }
  }

  @override
  void didUpdateWidget(ZegoSliderBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحديث القيمة إذا تغيرت
    if (oldWidget.value != widget.value) {
      setState(() {
        _playProgress = widget.value;
      });
    }
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: Color(0xff6EA75C),
        inactiveTrackColor: Color(0xffD9D9D9),
        thumbColor: Color(0xff6EA75C),
      ),
      child: Slider(
        min: widget.min,
        max: widget.max,
        value: _playProgress,
        onChanged: (double value) {
          if (mounted) {
            setState(() => _playProgress = value);
          }
          if (widget.realTimeRefresh) {
            widget.onProgressChanged(value);
          }
        },
        onChangeEnd: widget.onProgressChanged,
      ),
    );
  }
}

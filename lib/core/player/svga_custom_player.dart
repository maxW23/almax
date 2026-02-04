import 'dart:async';
import 'package:lklk/core/utils/logger.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svga/flutter_svga.dart';

class CustomSVGAWidget extends StatefulWidget {
  final double height;
  final double width;
  final bool isRepeat;
  final String pathOfSvgaFile;
  final Widget? child;
  final Widget? aboveChild;
  final bool isPadding;
  final bool isCircularChild;
  final bool clearsAfterStop;
  final bool allowDrawingOverflow;
  final BoxFit fit;
  final Size? preferredSize;
  final EdgeInsetsGeometry? paddingAboveChild;
  final bool isNotCenter;
  final AlignmentGeometry alignment;
  final int? durationSeconds;

  const CustomSVGAWidget({
    super.key,
    required this.height,
    required this.width,
    this.isRepeat = false,
    required this.pathOfSvgaFile,
    this.child,
    this.isPadding = true,
    this.clearsAfterStop = true,
    this.allowDrawingOverflow = true,
    this.fit = BoxFit.cover,
    this.preferredSize,
    this.aboveChild,
    this.paddingAboveChild = const EdgeInsets.all(0),
    this.isCircularChild = false,
    this.isNotCenter = false,
    this.alignment = Alignment.center,
    this.durationSeconds,
  });

  @override
  State<CustomSVGAWidget> createState() => _CustomSVGAWidgetState();
}

class _CustomSVGAWidgetState extends State<CustomSVGAWidget>
    with SingleTickerProviderStateMixin {
  late SVGAAnimationController _animationController;
  bool _isAnimationLoaded = false;
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    _animationController = SVGAAnimationController(vsync: this);
    _loadAnimation();
  }

  @override
  void didUpdateWidget(CustomSVGAWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pathOfSvgaFile != widget.pathOfSvgaFile ||
        oldWidget.durationSeconds != widget.durationSeconds) {
      _loadAnimation();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _durationTimer?.cancel();
    super.dispose();
  }

  void _loadAnimation() async {
    if (widget.pathOfSvgaFile.isEmpty || widget.pathOfSvgaFile == 'null') {
      log("Invalid SVGA file path: ${widget.pathOfSvgaFile}");
      setState(() {
        _isAnimationLoaded = false;
      });
      return;
    }

    try {
      final videoItem = await _loadVideoItem(widget.pathOfSvgaFile);

      if (mounted) {
        setState(() {
          _isAnimationLoaded = true;
          _animationController.videoItem = videoItem;

          // إلغاء أي timer سابق
          _durationTimer?.cancel();

          if (widget.durationSeconds != null && widget.durationSeconds! > 0) {
            // إذا كانت هناك مدة محددة، كرر الرسوم المتحركة حتى انتهاء المدة
            _animationController.repeat();

            // أوقف الرسوم المتحركة بعد المدة المحددة
            _durationTimer =
                Timer(Duration(seconds: widget.durationSeconds!), () {
              if (mounted) {
                _animationController.stop();
              }
            });
          } else if (widget.isRepeat) {
            _animationController.repeat();
          } else {
            _animationController.forward();
          }
        });
      }
    } catch (e, stackTrace) {
      log("Failed to load SVGA file: $e\n$stackTrace");
      setState(() {
        _isAnimationLoaded = false;
      });
    }
  }

  Future<MovieEntity> _loadVideoItem(String image) async {
    try {
      Future<MovieEntity> Function(String) decoder;
      if (image.startsWith('/data/user')) {
        final file = File(image);
        bool exists = await file.exists();
        if (!exists) {
          throw Exception("File not found: $image");
        }
        final fileBytes = await file.readAsBytes();
        return await SVGAParser.shared.decodeFromBuffer(fileBytes);
      } else if (image.startsWith(RegExp(r'https?://'))) {
        decoder = SVGAParser.shared.decodeFromURL;
      } else {
        decoder = SVGAParser.shared.decodeFromAssets;
      }

      return await decoder(image);
    } catch (e, stackTrace) {
      log("Error decoding SVGA file: $e\n$stackTrace");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget container = SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        alignment: widget.alignment,
        children: <Widget>[
          Positioned.fill(
            child: Container(
              padding: widget.isPadding
                  ? const EdgeInsets.all(15)
                  : const EdgeInsets.all(0),
              child: Center(
                child: widget.child,
              ),
            ),
          ),
          if (_isAnimationLoaded)
            Center(
              child: SVGAImage(
                _animationController,
                fit: widget.fit,
                clearsAfterStop: widget.clearsAfterStop,
                allowDrawingOverflow: widget.allowDrawingOverflow,
                preferredSize:
                    widget.preferredSize ?? Size(widget.width, widget.height),
                filterQuality: FilterQuality.medium,
              ),
            ),
          if (_isAnimationLoaded &&
              widget.aboveChild != null &&
              widget.isCircularChild == false)
            Positioned.fill(
              child: Container(
                padding: widget.paddingAboveChild,
                child: Center(
                  child: widget.aboveChild,
                ),
              ),
            ),
          if (_isAnimationLoaded &&
              widget.aboveChild != null &&
              widget.isCircularChild == true)
            Positioned.fill(
              child: ClipOval(
                child: Container(
                  padding: widget.paddingAboveChild,
                  width: widget.width,
                  height: widget.height,
                  child: Center(
                    child: widget.aboveChild,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return widget.isNotCenter ? container : Center(child: container);
  }
}

import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ImageCustomCropPage extends StatefulWidget {
  const ImageCustomCropPage({
    super.key,
    required this.imageBytes,
    this.cropToSquare = false,
    this.targetWidth,
    this.targetHeight,
    this.toolbarTitle = 'قص الصورة',
  });

  final Uint8List imageBytes;
  final bool cropToSquare;
  final int? targetWidth;
  final int? targetHeight;
  final String toolbarTitle;

  @override
  State<ImageCustomCropPage> createState() => _ImageCustomCropPageState();
}

class _ImageCustomCropPageState extends State<ImageCustomCropPage> {
  final _controller = CropController();
  bool _isCropping = false;
  Completer<Uint8List>? _cropCompleter;

  Future<void> _onConfirm() async {
    if (_isCropping) return;
    setState(() => _isCropping = true);

    try {
      // Trigger crop and await bytes via onCropped callback
      _cropCompleter = Completer<Uint8List>();
      _controller.crop();
      final croppedBytes = await _cropCompleter!.future;

      // Optionally resize to target if provided
      Uint8List finalBytes = croppedBytes;
      if (widget.targetWidth != null && widget.targetHeight != null) {
        try {
          final decoded = img.decodeImage(finalBytes);
          if (decoded != null) {
            final resized = img.copyResize(
              decoded,
              width: widget.targetWidth!,
              height: widget.targetHeight!,
              interpolation: img.Interpolation.cubic,
            );
            finalBytes = Uint8List.fromList(img.encodeJpg(resized, quality: 90));
          }
        } catch (_) {}
      }

      // Save to temp file and return its path
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(finalBytes, flush: true);

      if (!mounted) return;
      Navigator.of(context).pop<File>(file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إتمام القص: $e')),
      );
      setState(() => _isCropping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(widget.toolbarTitle, style: const TextStyle(color: Colors.white)),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Crop(
                  controller: _controller,
                  image: widget.imageBytes,
                  aspectRatio: widget.cropToSquare ? 1 : null,
                  withCircleUi: false,
                  baseColor: Colors.black,
                  maskColor: Colors.black.withOpacity(0.4),
                  cornerDotBuilder: (size, edgeAlignment) => Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onCropped: (bytes) {
                    // Complete the completer when crop is ready
                    if (_cropCompleter != null && !_cropCompleter!.isCompleted) {
                      _cropCompleter!.complete(bytes);
                    }
                  },
                ),
              ),
            ),
            // Big confirm button at the bottom
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 28),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('تأكيد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _isCropping ? null : _onConfirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

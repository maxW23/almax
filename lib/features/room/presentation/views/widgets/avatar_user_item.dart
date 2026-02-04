import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/constants/assets.dart';

class AvatarUserItem extends StatefulWidget {
  const AvatarUserItem(
      {super.key,
      this.urlImage,
      this.size = 50,
      this.margin = EdgeInsets.zero,
      this.elevation = 5});
  final String? urlImage;
  final double size;
  final EdgeInsetsGeometry margin;
  final double elevation;
  @override
  State<AvatarUserItem> createState() => _AvatarUserItemState();
}

class _AvatarUserItemState extends State<AvatarUserItem> {
  String validateImageUrl(String url) {
    //log('urlImage $url');
    if (url.contains('https://') || url.contains('assets')) {
      return url;
    } else {
      return 'https://lklklive.com/imguser/$url';
    }
  }

  late final String? validatedUrlImage;
  @override
  void initState() {
    if (widget.urlImage != null) {
      validatedUrlImage = validateImageUrl(widget.urlImage!);
    } else {
      validatedUrlImage = null;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: widget.size,
      width: widget.size,
      child: Material(
        borderRadius: BorderRadius.circular(100),
        elevation: widget.elevation,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: Colors.transparent,
            backgroundImage: CachedNetworkImageProvider(
              validatedUrlImage ?? AssetsData.userTestNetwork,
              // حجم كاش محسن بناءً على حجم الأفاتار
              maxWidth: (widget.size * 2).round().clamp(50, 200),
              maxHeight: (widget.size * 2).round().clamp(50, 200),
            ),
          ),
        ),
      ),
    );
  }
}

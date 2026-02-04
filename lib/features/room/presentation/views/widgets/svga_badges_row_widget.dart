import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/room/presentation/views/widgets/level_row_user_title_widget_section.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserSvgaBadgesRow extends StatelessWidget {
  const UserSvgaBadgesRow({
    super.key,
    required this.user,
    this.size = LevelRowSize.normal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.centerContent = false,
    this.maxRowHeight,
    this.minSquareSide,
    this.maxSquareSide,
    this.minRectHeight,
    this.maxRectHeight,
    this.minRectAspectRatio,
    this.maxRectAspectRatio,
  });

  final UserEntity user;
  final LevelRowSize size;
  final MainAxisAlignment mainAxisAlignment;
  final bool centerContent;
  // New: hard cap for each row height (applies to both rect and square rows)
  final double? maxRowHeight;

  // Optional sizing constraints
  final double? minSquareSide, maxSquareSide;
  final double? minRectHeight, maxRectHeight;
  final double? minRectAspectRatio, maxRectAspectRatio;

  bool _isSvgaUrl(String url) {
    final l = url.toLowerCase();
    return l.endsWith('.svga') || l.contains('.svga');
  }

  double _getSizeValue(double normalValue, double smallValue) {
    return size == LevelRowSize.small ? smallValue : normalValue;
  }

  WrapAlignment _mapWrapAlignment(MainAxisAlignment a, bool isRtl) {
    switch (a) {
      case MainAxisAlignment.start:
        return isRtl ? WrapAlignment.end : WrapAlignment.start;
      case MainAxisAlignment.end:
        return isRtl ? WrapAlignment.start : WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }

  List<String> _uniqList(List<String> list) {
    final seen = <String>{};
    final out = <String>[];
    for (final s in list) {
      if (seen.add(s)) out.add(s);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    // أيقونات مربعة (ws1..ws5)
    final squareCandidates = <String?>[
      user.ws1,
      user.ws2,
      user.ws3,
      user.ws4,
      user.ws5,
    ];
    var squareUrls = squareCandidates
        .whereType<String>()
        .map((s) => s.trim())
        .where((t) => t.isNotEmpty && t != 'null')
        .toList();

    // أيقونات مستطيلة (ic1..ic15)
    final rectCandidates = <String?>[
      user.ic1,
      user.ic2,
      user.ic3,
      user.ic4,
      user.ic5,
      user.ic6,
      user.ic7,
      user.ic8,
      user.ic9,
      user.ic10,
      user.ic11,
      user.ic12,
      user.ic13,
      user.ic14,
      user.ic15,
    ];
    var rectUrls = rectCandidates
        .whereType<String>()
        .map((s) => s.trim())
        .where((t) => t.isNotEmpty && t != 'null')
        .toList();

    squareUrls = _uniqList(squareUrls);
    rectUrls = _uniqList(rectUrls);

    if (squareUrls.isEmpty && rectUrls.isEmpty) return const SizedBox.shrink();

    // قاعدة وأقصى/أدنى للأحجام (احترافية ومرنة)
    final double baseRect = _getSizeValue(20.h, 17.h);

    // صفّ ال Badges يجب ألا يتجاوز ارتفاعاً أعظميّاً ثابتاً عبر الأجهزة
    // الافتراضي: 24dp للوضع العادي و 20dp للوضع الصغير
    final double rowMaxH = maxRowHeight ?? _getSizeValue(24.0, 20.0);

    final double minRhBase = minRectHeight ?? _getSizeValue(24.h, 16.h);
    final double maxRhBase = maxRectHeight ?? _getSizeValue(24.h, 22.h);
    // نضمن ألا تتجاوز القيود الارتفاع الأعظمي للصف
    final double minRh = math.min(minRhBase, rowMaxH);
    final double maxRh = math.min(maxRhBase, rowMaxH);
    final double rectHeight = baseRect.clamp(minRh, maxRh);

    // زيادة حجم الأيقونات المربعة بشكل طفيف مع دعم القيود الممرّرة
    // final double baseSquare = _getSizeValue(24.h, 21.h);
    // final double minSs = minSquareSide ?? _getSizeValue(20.h, 18.h);
    // final double maxSs = maxSquareSide ?? _getSizeValue(32.h, 26.h);
    // final double squareSide = baseSquare.clamp(minSs, maxSs);
    // توحيد ارتفاع الصفّين: الصف الثاني يستخدم نفس الارتفاع
    final double squareSide = rectHeight;

    // نسب العرض للمستطيل
    final double minRectAR = (minRectAspectRatio ?? 1.35).clamp(1.1, 10.0);
    final double maxRectAR = (maxRectAspectRatio ?? 3.0).clamp(minRectAR, 10.0);
    const double svgaRectAR = 2;

    final double spacing = _getSizeValue(3.w, 2.w);
    final double runSpacing = _getSizeValue(4.h, 3.h);

    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    final wrapAlignment = centerContent
        ? WrapAlignment.center
        : _mapWrapAlignment(mainAxisAlignment, isArabic);
    final textDir = isArabic ? TextDirection.rtl : TextDirection.ltr;

    // عنصر مستطيل صورة مع حدود نسبية دنيا/عظمى
    Widget _rectImage(String url) {
      return _BadgeImage(
        url: url,
        height: rectHeight,
        borderRadius: 6.0,
        fallbackAspectRatio: 2.1,
        minAspectRatio: minRectAR,
        maxAspectRatio: maxRectAR,
      );
    }

    // عنصر مستطيل SVGA بعرض محسوب ومقيد
    Widget _rectSvga(String url) {
      final clampedAR = math.min(maxRectAR, math.max(minRectAR, svgaRectAR));
      final double width = rectHeight * clampedAR;
      return SizedBox(
        width: width,
        height: rectHeight,
        child: CustomSVGAWidget(
          height: rectHeight,
          width: width,
          pathOfSvgaFile: url,
          isRepeat: true,
          isPadding: false,
          fit: BoxFit.fill,
          clearsAfterStop: false,
          allowDrawingOverflow: false,
          preferredSize: Size(width, rectHeight),
        ),
      );
    }

    // عنصر مربع صورة
    Widget _squareImage(String url) {
      // نستعمل نفس منطق الصورة المستطيلة ولكن بارتفاع ثابت (side) ونسبة افتراضية 1.0
      return _BadgeImage(
        url: url,
        height: squareSide,
        borderRadius: 6.0,
        fallbackAspectRatio: 1.0,
        minAspectRatio: minRectAR,
        maxAspectRatio: maxRectAR,
      );
    }

    // عنصر مربع SVGA
    Widget _squareSvga(String url) {
      // الارتفاع يطابق قياس الصف النهائي بدون زيادات لضمان عدم تجاوز الحد الأعظمي
      final double h = squareSide + 10; // مساوية لـ rectHeight بعد التوحيد
      final double w = squareSide + 10; // نُبقي عرضاً إضافياً بسيطاً فقط
      return SizedBox(
        height: h,
        width: w,
        child: CustomSVGAWidget(
          height: h,
          width: w,
          pathOfSvgaFile: url,
          isRepeat: true,
          isPadding: false,
          fit: BoxFit.fill,
          clearsAfterStop: false,
          allowDrawingOverflow: false,
          preferredSize: Size(w, h),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centerContent ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // صف المستطيلات
        if (rectUrls.isNotEmpty)
          Align(
            alignment: centerContent
                ? Alignment.center
                : (isArabic ? Alignment.centerRight : Alignment.centerLeft),
            child: Directionality(
              textDirection: textDir,
              child: Wrap(
                spacing: spacing,
                runSpacing: runSpacing,
                alignment: wrapAlignment,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final u in rectUrls)
                    _isSvgaUrl(u) ? _rectSvga(u) : _rectImage(u),
                ],
              ),
            ),
          ),
        if (squareUrls.isNotEmpty && rectUrls.isNotEmpty)
          SizedBox(height: _getSizeValue(6.h, 4.h)),
        // صف المربعات
        if (squareUrls.isNotEmpty)
          Align(
            alignment: centerContent
                ? Alignment.center
                : (isArabic ? Alignment.centerRight : Alignment.centerLeft),
            child: Directionality(
              textDirection: textDir,
              child: Wrap(
                spacing: spacing,
                runSpacing: runSpacing,
                alignment: wrapAlignment,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final u in squareUrls)
                    _isSvgaUrl(u) ? _squareSvga(u) : _squareImage(u),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BadgeImage extends StatefulWidget {
  final String url;
  final double height;
  final double borderRadius;
  final double fallbackAspectRatio;
  final double minAspectRatio;
  final double maxAspectRatio;
  const _BadgeImage({
    super.key,
    required this.url,
    required this.height,
    required this.borderRadius,
    required this.fallbackAspectRatio,
    required this.minAspectRatio,
    required this.maxAspectRatio,
  });

  @override
  State<_BadgeImage> createState() => _BadgeImageState();
}

class _BadgeImageState extends State<_BadgeImage> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  double? _aspect;

  void _subscribe() {
    final provider = CachedNetworkImageProvider(widget.url);
    final stream = provider.resolve(const ImageConfiguration());
    _listener = ImageStreamListener((info, sync) {
      final w = info.image.width.toDouble();
      final h = info.image.height.toDouble();
      if (h > 0) setState(() => _aspect = w / h);
    }, onError: (error, stackTrace) {
      // ignore
    });
    stream.addListener(_listener!);
    _stream = stream;
  }

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant _BadgeImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      if (_stream != null && _listener != null) {
        _stream!.removeListener(_listener!);
      }
      _subscribe();
    }
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspect = _aspect ?? widget.fallbackAspectRatio;
    final clampedAspect =
        aspect.clamp(widget.minAspectRatio, widget.maxAspectRatio);
    final width = widget.height * clampedAspect;
    return SizedBox(
      height: widget.height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: CachedNetworkImage(
          imageUrl: widget.url,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          imageBuilder: (context, provider) => Image(
            image: provider,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

class _SmartSquareImage extends StatefulWidget {
  final String url;
  final double side;
  final double borderRadius;
  final double minRectAR;
  final double maxRectAR;
  const _SmartSquareImage({
    super.key,
    required this.url,
    required this.side,
    required this.borderRadius,
    required this.minRectAR,
    required this.maxRectAR,
  });

  @override
  State<_SmartSquareImage> createState() => _SmartSquareImageState();
}

class _SmartSquareImageState extends State<_SmartSquareImage> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  double? _aspect;

  void _subscribe() {
    final provider = CachedNetworkImageProvider(widget.url);
    final stream = provider.resolve(const ImageConfiguration());
    _listener = ImageStreamListener((info, sync) {
      final w = info.image.width.toDouble();
      final h = info.image.height.toDouble();
      if (h > 0) setState(() => _aspect = w / h);
    }, onError: (error, stackTrace) {});
    stream.addListener(_listener!);
    _stream = stream;
  }

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant _SmartSquareImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      if (_stream != null && _listener != null) {
        _stream!.removeListener(_listener!);
      }
      _subscribe();
    }
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ar = _aspect ?? 1.0;
    final isSquareish = ar > 0.9 && ar < 1.1;
    final width = isSquareish
        ? widget.side
        : widget.side * ar.clamp(widget.minRectAR, widget.maxRectAR);
    return SizedBox(
      height: widget.side,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: CachedNetworkImage(
          imageUrl: widget.url,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          imageBuilder: (context, provider) => Image(
            image: provider,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}

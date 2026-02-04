import 'package:auto_size_text/auto_size_text.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/room/presentation/manger/player/playback_cubit.dart';
import 'package:lklk/features/room/presentation/manger/player/playlist_cubit.dart';
import 'package:lklk/features/room/presentation/views/widgets/media_player/player_assets.dart';
import 'package:lklk/features/room/presentation/views/widgets/media_player/zego_slider_bar.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:marquee/marquee.dart';
import 'package:permission_handler/permission_handler.dart';

/// واجهة المشغل داخل BottomSheet احترافي
class PlayerBottomSheet extends StatefulWidget {
  const PlayerBottomSheet({super.key});

  @override
  State<PlayerBottomSheet> createState() => _PlayerBottomSheetState();
}

class _PlayerBottomSheetState extends State<PlayerBottomSheet> {
  bool _showPlaylist = false;
  bool _showDeviceSongs = false;

  void _togglePlaylist() {
    setState(() {
      // إذا كنا في وضع أغاني الجهاز، الرجوع إلى قائمة التشغيل
      if (_showDeviceSongs) {
        _showDeviceSongs = false;
        _showPlaylist = true;
      } else {
        _showPlaylist = !_showPlaylist;
      }
    });
  }

  void _openDeviceSongs() {
    setState(() {
      _showDeviceSongs = true;
      _showPlaylist = false;
    });
  }

  void _backToPlaylist() {
    setState(() {
      _showDeviceSongs = false;
      _showPlaylist = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double minSize = 0.4;
    final double maxSize = 0.98; // يسمح بالامتلاء تقريباً لتجنب قص الزر السفلي
    double initialSize;
    // دعم كافة أوضاع شريط النظام: أزرار/إيماءات + لوحة المفاتيح
    final mq = MediaQuery.of(context);
    final double safeBottom = math.max(
      math.max(mq.padding.bottom, mq.viewPadding.bottom),
      mq.systemGestureInsets.bottom,
    );
    final double keyboardInset = mq.viewInsets.bottom; // عند فتح الكيبورد
    // احتياطي بسيط لضمان الظهور حتى لو عادت الحواف 0 على بعض الأجهزة
    final double reserveBottom = math.max(safeBottom, 40.0);
    int visibleForKey = 0; // لاستخدامه في key لضمان إعادة إنشاء صحيحة
    if (_showPlaylist || _showDeviceSongs) {
      // تقدير ديناميكي للحجم بناءً على عدد عناصر القائمة لتجنب مساحات فارغة
      final playlistState = context.watch<PlaylistCubit>().state;
      final listCount = _showPlaylist
          ? playlistState.paths.length
          : 8; // تقدير مبدئي لأغاني الجهاز
      const int maxVisibleItems = 8; // حد أقصى لعدد العناصر الظاهرة قبل التمرير
      final int visible =
          listCount > maxVisibleItems ? maxVisibleItems : listCount;
      visibleForKey = visible;
      final double headerH = 64.h; // هيدر قائمة التشغيل داخل الجسم
      final double tileH = 54.h; // تقدير ارتفاع العنصر
      final double sepH = 6.h; // المسافة بين العناصر
      final double ctaH = 64.h; // زر Add Music مع الهوامش
      final double listH =
          visible * tileH + (visible > 0 ? (visible - 1) * sepH : 0);
      final double bodyH = headerH + listH + ctaH;
      final double baseH =
          260.h; // محتوى المشغل الأعلى (التقدم + الكنترولز + الأكشنز)
      // أضف حواف النظام السفلية ولوحة المفاتيح إلى الارتفاع المطلوب
      final double extraBottom = 8.h + reserveBottom + keyboardInset;
      final double desiredPx = baseH + bodyH + extraBottom;
      final double screenH = MediaQuery.of(context).size.height;
      initialSize = (desiredPx / screenH).clamp(minSize, maxSize);
    } else {
      initialSize = 0.4;
    }
    final sheetKey = ValueKey(
      'draggable_${(_showPlaylist || _showDeviceSongs) ? 'full_$visibleForKey' : 'mini'}',
    );

    return SafeArea(
      bottom: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.playerGradientTop,
              AppColors.playerGradientBottom,
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: DraggableScrollableSheet(
            key: sheetKey,
            expand: false,
            minChildSize: minSize,
            initialChildSize: initialSize,
            maxChildSize: maxSize,
            builder: (context, controller) {
              return SingleChildScrollView(
                controller: controller,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    12.w,
                    8.h,
                    12.w,
                    8.h + reserveBottom + keyboardInset, // تأمين مساحة أسفل شاملة
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 8.h),
                      // Glass card container sized to its content
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 12.h),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ProgressSection(),
                              SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 110.h,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SoundMusicSlideBar(),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _ControlsRow(),
                                          _ArtworkAndTitle(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _BottomActionsRow(onPlaylistTap: _togglePlaylist),
                              if (_showPlaylist || _showDeviceSongs) ...[
                                SizedBox(height: 8.h),
                                // ارتفاع ديناميكي حسب عدد عناصر القائمة لتجنب مساحات فارغة
                                BlocBuilder<PlaylistCubit, PlaylistState>(
                                  builder: (context, s) {
                                    const int maxVisibleItems = 8;
                                    final int visible = (_showPlaylist
                                                ? s.paths.length
                                                : 8) >
                                            maxVisibleItems
                                        ? maxVisibleItems
                                        : (_showPlaylist ? s.paths.length : 8);
                                    final double headerH = 64.h;
                                    final double tileH = 54.h;
                                    final double sepH = 6.h;
                                    final double ctaH = 64.h;
                                    // تأمين مساحة دنيا لحالة القائمة الفارغة لتجنب الانكماش الشديد
                                    final double emptyPlaceholderH = 96.h;
                                    final double listH = visible > 0
                                        ? (visible * tileH +
                                            ((visible - 1) * sepH))
                                        : emptyPlaceholderH;
                                    final double bodyH = headerH + listH + ctaH;
                                    // تأكد أن المحتوى لا يتجاوز ارتفاع Draggable الفعلي
                                    final double screenH =
                                        MediaQuery.of(context).size.height;
                                    final double baseH =
                                        260.h; // تقدير نفس المستخدم بالأعلى
                                    final double safeGap = 12.h;
                                    // اطرح الحواف السفلية ولوحة المفاتيح لضمان عدم قص الزر السفلي
                                    final double allowedMax =
                                        (initialSize * screenH) -
                                            baseH -
                                            safeGap -
                                            reserveBottom -
                                            keyboardInset;
                                    final double height = math.min(
                                      math.max(180.h, bodyH),
                                      math.min(allowedMax, 520.h),
                                    );
                                    return SizedBox(
                                      height: height,
                                      child: _showPlaylist
                                          ? _PlaylistSheetBody(
                                              onAddMusic: _openDeviceSongs,
                                            )
                                          : _DeviceSongsInlineBody(
                                              onDone: _backToPlaylist,
                                              onCancel: _backToPlaylist,
                                            ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeviceSongsInlineBody extends StatefulWidget {
  const _DeviceSongsInlineBody({required this.onDone, required this.onCancel});
  final VoidCallback onDone;
  final VoidCallback onCancel;
  @override
  State<_DeviceSongsInlineBody> createState() => _DeviceSongsInlineBodyState();
}

class _DeviceSongsInlineBodyState extends State<_DeviceSongsInlineBody> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _songs = const [];
  final Set<int> _selected = {};
  bool _loading = true;
  String? _error;
  final ScrollController _scrollCtrl = ScrollController();
  double _scrollRatio = 0.0;

  @override
  void initState() {
    super.initState();
    _init();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    final off = _scrollCtrl.offset.clamp(0.0, max);
    final ratio = max <= 0 ? 0.0 : off / max;
    if (ratio != _scrollRatio) setState(() => _scrollRatio = ratio);
  }

  void _onSliderChange(double v) {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    _scrollCtrl.jumpTo(max * v.clamp(0.0, 1.0));
    setState(() => _scrollRatio = v);
  }

  Future<void> _init() async {
    try {
      if (Platform.isAndroid) {
        bool granted = await _audioQuery.permissionsStatus();
        if (!granted) granted = await _audioQuery.permissionsRequest();
        if (!granted) {
          setState(() => _error =
              'يرجى منح صلاحية الوصول إلى ملفات الصوت لعرض أغاني الجهاز.');
          return;
        }
      } else if (Platform.isIOS) {
        final status = await Permission.mediaLibrary.request();
        if (!status.isGranted) {
          setState(() => _error = 'يرجى منح صلاحية الوصول إلى مكتبة الموسيقى.');
          return;
        }
      }

      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );
      if (!mounted) return;
      setState(() {
        _songs = songs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر قراءة أغاني الجهاز: $e';
        _loading = false;
      });
    }
  }

  void _toggle(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _addSelected() async {
    if (_selected.isEmpty) {
      widget.onDone();
      return;
    }
    final playlist = context.read<PlaylistCubit>();
    final List<String> addedPaths = [];
    for (final s in _songs.where((e) => _selected.contains(e.id))) {
      final path = s.data;
      try {
        if (path.startsWith('/')) {
          final newPath = await playlist.copyToAppDir(path, fileName: s.title);
          addedPaths.add(newPath);
        } else if ((s.uri ?? '').startsWith('file://')) {
          final p = Uri.parse(s.uri!).toFilePath();
          final newPath = await playlist.copyToAppDir(p, fileName: s.title);
          addedPaths.add(newPath);
        } else {
          // content uri غير مدعوم حالياً بدون SAF
        }
      } catch (_) {}
    }
    if (addedPaths.isNotEmpty) {
      await playlist.addPaths(addedPaths);
    }
    if (mounted) widget.onDone();
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Image.asset(
                PlayerAssets.musicListPng,
                height: 22,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 8.w),
              const Expanded(
                child: AutoSizeText(
                  'أغاني الجهاز',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
              ),
              // تحديد الكل
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  setState(() {
                    if (_selected.length == _songs.length) {
                      _selected.clear();
                    } else {
                      _selected
                        ..clear()
                        ..addAll(_songs.map((e) => e.id));
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: const SweepGradient(colors: [
                      Color(0xff0E3408),
                      Color(0xff296D12),
                      Color(0xff0E3408),
                      Color(0xff296D12),
                      Color(0xff0E3408),
                      Color(0xff296D12),
                    ]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.select_all_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('تحديد الكل',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              // رجوع
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: widget.onCancel,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        S.of(context).back,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          Divider(color: Colors.white24, height: 12.h),
          // Body list + slider
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.white70)),
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Scrollbar(
                              controller: _scrollCtrl,
                              thumbVisibility: true,
                              interactive: true,
                              child: ListView.separated(
                                controller: _scrollCtrl,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: _songs.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 6.h),
                                itemBuilder: (ctx, i) {
                                  final s = _songs[i];
                                  final selected = _selected.contains(s.id);
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 10.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: Colors.white24, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.music_note,
                                            color: Colors.white70),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                s.title,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                s.artist ?? '',
                                                style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          onTap: () => _toggle(s.id),
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            reverseDuration: const Duration(
                                                milliseconds: 140),
                                            switchInCurve: Curves.easeOutCubic,
                                            switchOutCurve: Curves.easeInCubic,
                                            transitionBuilder:
                                                (child, animation) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: ScaleTransition(
                                                  scale: animation,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: selected
                                                ? Image.asset(
                                                    PlayerAssets.tickCirclePng,
                                                    key: const ValueKey(
                                                        'selected'),
                                                    width: 22,
                                                    height: 22,
                                                  )
                                                : Image.asset(
                                                    PlayerAssets.plusPng,
                                                    key: const ValueKey(
                                                        'unselected'),
                                                    width: 22,
                                                    height: 22,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (_songs.length >= 5) ...[
                            SizedBox(width: 8.w),
                            SizedBox(
                              width: 28,
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: SliderTheme(
                                  data: const SliderThemeData(
                                    trackHeight: 4,
                                    thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 8),
                                    overlayShape: RoundSliderOverlayShape(
                                        overlayRadius: 14),
                                    activeTrackColor: Color(0xff6EA75C),
                                    inactiveTrackColor: Color(0xffD9D9D9),
                                    thumbColor: Color(0xff6EA75C),
                                  ),
                                  child: Slider(
                                    min: 0.0,
                                    max: 1.0,
                                    value: _scrollRatio.clamp(0.0, 1.0),
                                    onChanged: (v) => _onSliderChange(v),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
          ),
          SizedBox(height: 8.h),
          // CTA - مضمونة الظهور فوق حافة النظام السفلية
          SafeArea(
            top: false,
            minimum: EdgeInsets.only(bottom: 8.h),
            child: SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _addSelected,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: SweepGradient(colors: const [
                      Color(0xff0E3408),
                      Color(0xff296D12),
                      Color(0xff0E3408),
                      Color(0xff296D12),
                      Color(0xff0E3408),
                      Color(0xff296D12),
                    ]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Center(
                    child: AutoSizeText(
                      'إضافة المحدد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ArtworkAndTitle extends StatelessWidget {
  const _ArtworkAndTitle();
  @override
  Widget build(BuildContext context) {
    // استمع لكل من PlaybackCubit و PlaylistCubit لضمان التحديث الفوري
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      buildWhen: (p, c) => p.paths != c.paths,
      builder: (context, playlistState) {
        return BlocBuilder<PlaybackCubit, PlaybackState>(
          buildWhen: (p, c) =>
              p.currentSong != c.currentSong ||
              p.isPlaying != c.isPlaying ||
              p.currentIndex != c.currentIndex,
          builder: (context, state) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: LayoutBuilder(
                          key: ValueKey(
                              'title_${state.currentSong}_${state.currentIndex}'),
                          builder: (ctx, constraints) {
                            return SizedBox(
                              width: constraints.maxWidth,
                              height: 22.h,
                              child: Marquee(
                                text: state.currentSong.isEmpty
                                    ? S.of(context).noSongSelected
                                    : state.currentSong,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Image.asset(
                  "assets/images/player/music-green-black.png",
                  height: 30,
                  width: 30,
                )
              ],
            );
          },
        );
      },
    );
  }
}

class _ArtworkWithEffects extends StatefulWidget {
  const _ArtworkWithEffects({
    required this.path,
    required this.isPlaying,
  });
  final String? path;
  final bool isPlaying;

  @override
  State<_ArtworkWithEffects> createState() => _ArtworkWithEffectsState();
}

class _ArtworkWithEffectsState extends State<_ArtworkWithEffects>
    with SingleTickerProviderStateMixin {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  Uint8List? _art;
  late final AnimationController _rotCtrl;
  static const double size = 220;

  @override
  void initState() {
    super.initState();
    _rotCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 12));
    _maybeSpin();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(covariant _ArtworkWithEffects oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      debugPrint(
          '🎨 [Artwork] Path changed: ${oldWidget.path} → ${widget.path}');
      _loadArtwork();
    }
    if (oldWidget.isPlaying != widget.isPlaying) {
      debugPrint(
          '🎨 [Artwork] Playing state changed: ${oldWidget.isPlaying} → ${widget.isPlaying}');
      _maybeSpin();
    }
  }

  void _maybeSpin() {
    if (widget.isPlaying) {
      _rotCtrl.repeat();
    } else {
      _rotCtrl.stop(canceled: false);
    }
  }

  Future<void> _loadArtwork() async {
    // إعادة تعيين الصورة أولاً لضمان التحديث
    if (mounted) setState(() => _art = null);

    if (widget.path == null || widget.path!.isEmpty) {
      debugPrint('🎨 [Artwork] Path is null or empty');
      return;
    }

    debugPrint('🎨 [Artwork] Loading artwork for: ${widget.path}');

    try {
      // ابحث عن الأغنية حسب مسار الملف للحصول على الـ id ثم استخرج العمل الفني
      final all = await _audioQuery.querySongs(uriType: UriType.EXTERNAL);
      final song = all.firstWhere(
        (s) =>
            s.data == widget.path ||
            (s.uri != null && (s.uri!.contains(widget.path!))),
        orElse: () => throw StateError('Song not found'),
      );
      debugPrint('🎨 [Artwork] Found song: ${song.title} (id: ${song.id})');

      final art = await _audioQuery.queryArtwork(song.id, ArtworkType.AUDIO,
          size: 512, quality: 100);
      if (mounted) {
        setState(() => _art = art);
        debugPrint(
            '🎨 [Artwork] Loaded successfully: ${art != null ? "${art.length} bytes" : "null"}');
      }
    } catch (e) {
      // في حالة الفشل، تبقى الصورة null (الأيقونة الافتراضية)
      debugPrint('🎨 [Artwork] Failed to load: $e');
      if (mounted) setState(() => _art = null);
    }
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageChild = ClipOval(
      child: _art != null
          ? Image.memory(_art!,
              fit: BoxFit.cover, width: size.w, height: size.w)
          : Container(
              width: size.w,
              height: size.w,
              color: Colors.black.withOpacity(0.15),
              child: const Center(
                  child:
                      Icon(Icons.music_note, size: 72, color: Colors.white70)),
            ),
    );

    return RotationTransition(
      turns: _rotCtrl,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              Color(0x55FFFFFF),
              Color(0x22FFFFFF),
              Color(0x11FFFFFF),
              Color(0x55FFFFFF)
            ],
          ),
        ),
        padding: EdgeInsets.all(size <= 100 ? 4 : 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                Border.all(color: Colors.white24, width: size <= 100 ? 0.7 : 1),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey('art_${widget.path ?? 'none'}'),
              child: imageChild,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniVisualizer extends StatefulWidget {
  const _MiniVisualizer({required this.isPlaying});
  final bool isPlaying;

  @override
  State<_MiniVisualizer> createState() => _MiniVisualizerState();
}

class _MiniVisualizerState extends State<_MiniVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..addListener(() => setState(() {}))
      ..repeat();
    _applyPlayState();
  }

  @override
  void didUpdateWidget(covariant _MiniVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) _applyPlayState();
  }

  void _applyPlayState() {
    if (widget.isPlaying) {
      if (!_ctrl.isAnimating) _ctrl.repeat();
    } else {
      _ctrl.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 20 أعمدة بارتفاعات متذبذبة ناعمة
    const bars = 20;
    final t = _ctrl.value * 2 * math.pi;
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(bars, (i) {
          final phase = i / bars * 2 * math.pi;
          final h = (math.sin(t + phase) * 0.5 + 0.5); // 0..1
          final height = 6 + h * 16; // 6..22
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Container(
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: BlocBuilder<PlaybackCubit, PlaybackState>(
        buildWhen: (p, c) =>
            p.progress != c.progress || p.isPlaying != c.isPlaying,
        builder: (context, state) {
          final cubit = context.read<PlaybackCubit>();
          return Column(
            children: [
              ZegoSliderBar(
                key: ValueKey('progress_${state.currentSong}'),
                onProgressChanged: (v) => cubit.seek(v),
                value: state.progress,
                realTimeRefresh: true,
              ),
              // SizedBox(height: 8.h),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     AutoSizeText(
              //       state.isPlaying
              //           ? S.of(context).auxLabel
              //           : S.of(context).muteLocal,
              //       style: const TextStyle(color: Colors.white60, fontSize: 12),
              //       maxLines: 1,
              //     )
              //   ],
              // )
            ],
          );
        },
      ),
    );
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow();
  @override
  Widget build(BuildContext context) {
    // استمع لكل من PlaybackCubit و PlaylistCubit
    return BlocBuilder<PlaylistCubit, PlaylistState>(
      buildWhen: (p, c) => p.paths != c.paths,
      builder: (context, playlistState) {
        return BlocBuilder<PlaybackCubit, PlaybackState>(
          buildWhen: (p, c) =>
              p.isPlaying != c.isPlaying || p.currentIndex != c.currentIndex,
          builder: (context, state) {
            final playback = context.read<PlaybackCubit>();
            Widget glassIcon(String icon,
                {double size = 24, VoidCallback? onTap}) {
              return InkWell(
                onTap: onTap,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    icon,
                    width: size,
                    height: size,
                  ),
                ),
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                glassIcon(
                  "assets/images/player/pre-play.png",
                  onTap: () {
                    final idx = state.currentIndex - 1;
                    if (idx >= 0 && idx < playlistState.paths.length) {
                      playback.playPath(playlistState.paths[idx], index: idx);
                    }
                  },
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(48),
                  onTap: () {
                    if (state.isPlaying) {
                      playback.pause();
                    } else {
                      if (state.currentIndex >= 0 &&
                          state.currentIndex < playlistState.paths.length) {
                        playback.resume();
                      } else if (playlistState.paths.isNotEmpty) {
                        playback.playPath(playlistState.paths.first, index: 0);
                      }
                    }
                  },
                  child: playOrPause(state),
                ),
                glassIcon(
                  "assets/images/player/next-play.png",
                  onTap: () {
                    final idx = state.currentIndex + 1;
                    if (idx >= 0 && idx < playlistState.paths.length) {
                      playback.playPath(playlistState.paths[idx], index: idx);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  SizedBox playOrPause(PlaybackState state) {
    return SizedBox(
      width: 60,
      height: 60,
      child: !state.isPlaying
          ? Image.asset(
              "assets/images/player/play.png",
              width: 60,
              height: 60,
            )
          : Image.asset(
              "assets/images/player/pause.png",
              width: 60,
              height: 60,
            ),
    );
  }
}

class _BottomActionsRow extends StatelessWidget {
  const _BottomActionsRow({required this.onPlaylistTap});
  final VoidCallback onPlaylistTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // مستوى الصوت

        // أزرار الإعدادات (غلاس بيل)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GlassPillToggle(
                labelBuilder: (context) => S.of(context).muteLocal,
                isActiveSelector: (s) => s.isMuteLocal,
                onTap: (ctx) => ctx.read<PlaybackCubit>().toggleMuteLocal(),
                faActiveIcon: FontAwesomeIcons.microphoneSlash,
                faInactiveIcon: FontAwesomeIcons.microphone,
                fixedWidth: 120,
              ),
              _GlassPillToggle(
                labelBuilder: (context) => S.of(context).auxLabel,
                isActiveSelector: (s) => s.isAux,
                onTap: (ctx) => ctx.read<PlaybackCubit>().toggleAux(),
                faActiveIcon: FontAwesomeIcons.broadcastTower,
                faInactiveIcon: FontAwesomeIcons.bullhorn,
                fixedWidth: 120,
              ),
              Center(
                child: IconButton(
                  onPressed: () {
                    // إظهار/إخفاء قائمة التشغيل داخل PlayerBottomSheet نفسه
                    onPlaylistTap();
                  },
                  icon: Image.asset(
                    PlayerAssets.addMusicPng,
                    height: 36,
                  ),
                  splashRadius: 28,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}

class SoundMusicSlideBar extends StatelessWidget {
  const SoundMusicSlideBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // شريط الصوت بشكل طولي عبر تدوير الـ Slider بمقدار 90 درجة
    return SizedBox(
      width: 36, // عرض مناسب لشريط عمودي
      height: 110.h,
      child: RotatedBox(
        quarterTurns: 3, // تدوير 90 درجة لجعل الشريط عمودياً
        child: BlocBuilder<PlaybackCubit, PlaybackState>(
          buildWhen: (p, c) => p.volume != c.volume,
          builder: (context, state) {
            return ZegoSliderBar(
              onProgressChanged: (v) =>
                  context.read<PlaybackCubit>().setVolume(v),
              value: state.volume,
              realTimeRefresh: true,
            );
          },
        ),
      ),
    );
  }
}

// Glass pill toggle button
class _GlassPillToggle extends StatelessWidget {
  const _GlassPillToggle({
    required this.labelBuilder,
    required this.isActiveSelector,
    required this.onTap,
    this.fixedWidth,
    this.faActiveIcon,
    this.faInactiveIcon,
  });

  final String Function(BuildContext) labelBuilder;
  final bool Function(PlaybackState) isActiveSelector;
  final void Function(BuildContext) onTap;
  final double? fixedWidth;
  final IconData? faActiveIcon;
  final IconData? faInactiveIcon;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackCubit, PlaybackState>(
      buildWhen: (p, c) => isActiveSelector(p) != isActiveSelector(c),
      builder: (context, s) {
        final active = isActiveSelector(s);
        final Widget iconWidget =
            (faActiveIcon != null && faInactiveIcon != null)
                ? FaIcon(
                    active ? faActiveIcon! : faInactiveIcon!,
                    size: 16,
                    color: Colors.white.withOpacity(active ? 1 : 0.8),
                  )
                : const SizedBox.shrink();

        final pill = InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onTap(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: SweepGradient(colors: [
                Color(0xff0E3408),
                Color(0xff296D12),
                Color(0xff0E3408),
                Color(0xff296D12),
                Color(0xff0E3408),
                Color(0xff296D12),
              ]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                SizedBox(width: 6.w),
                AutoSizeText(
                  labelBuilder(context),
                  style: TextStyle(
                    color: Colors.white.withOpacity(active ? 1 : 0.7),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );

        return fixedWidth != null
            ? SizedBox(width: fixedWidth, child: Center(child: pill))
            : pill;
      },
    );
  }
}

class _PlaylistSheetBody extends StatefulWidget {
  const _PlaylistSheetBody({required this.onAddMusic});
  final VoidCallback onAddMusic;
  @override
  State<_PlaylistSheetBody> createState() => _PlaylistSheetBodyState();
}

class _PlaylistSheetBodyState extends State<_PlaylistSheetBody> {
  late final ScrollController _scrollCtrl;
  double _scrollRatio = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    final off = _scrollCtrl.offset.clamp(0.0, max);
    final ratio = max <= 0 ? 0.0 : off / max;
    if (ratio != _scrollRatio) {
      setState(() => _scrollRatio = ratio);
    }
  }

  void _onSliderChange(double v) {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    _scrollCtrl.jumpTo(max * v.clamp(0.0, 1.0));
    setState(() => _scrollRatio = v);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // اعتمد على تدرّج المشغل الأب لتجنب تكرار التدرج داخل قائمة التشغيل
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Image.asset(
                  PlayerAssets.musicListPng,
                  height: 22,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: BlocBuilder<PlaylistCubit, PlaylistState>(
                    builder: (context, s) => AutoSizeText(
                      S.of(context).playlistTitle(s.paths.length),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                BlocBuilder<PlaylistCubit, PlaylistState>(
                  builder: (context, s) {
                    final isAllSelected = s.paths.isNotEmpty &&
                        s.selected.length == s.paths.length;
                    final hasSelection = s.selected.isNotEmpty;
                    return Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        if (hasSelection)
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () =>
                                context.read<PlaylistCubit>().removeSelected(),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                gradient: const SweepGradient(colors: [
                                  Color(0xff0E3408),
                                  Color(0xff296D12),
                                  Color(0xff0E3408),
                                  Color(0xff296D12),
                                  Color(0xff0E3408),
                                  Color(0xff296D12),
                                ]),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: Colors.white24, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.delete_forever_rounded,
                                      color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('حذف المحدد',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        if (s.paths.isNotEmpty)
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              final cubit = context.read<PlaylistCubit>();
                              if (isAllSelected) {
                                cubit.clearSelection();
                              } else {
                                cubit.selectAll();
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                gradient: const SweepGradient(colors: [
                                  Color(0xff0E3408),
                                  Color(0xff296D12),
                                  Color(0xff0E3408),
                                  Color(0xff296D12),
                                  Color(0xff0E3408),
                                  Color(0xff296D12),
                                ]),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: Colors.white24, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.select_all_rounded,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAllSelected ? 'إلغاء الكل' : 'تحديد الكل',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (s.paths.isNotEmpty)
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () =>
                                context.read<PlaylistCubit>().clearAll(),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                gradient: const SweepGradient(colors: [
                                  Color(0xff0E3408),
                                  Color(0xff296D12),
                                  Color(0xff0E3408),
                                  Color(0xff296D12),
                                  Color(0xff0E3408),
                                  Color(0xff296D12),
                                ]),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: Colors.white24, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.delete_sweep_rounded,
                                      color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('حذف الكل',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            Divider(color: Colors.white24, height: 12.h),
            // List
            Expanded(
              child: BlocBuilder<PlaybackCubit, PlaybackState>(
                buildWhen: (p, c) => p.currentIndex != c.currentIndex,
                builder: (context, playbackState) {
                  return BlocBuilder<PlaylistCubit, PlaylistState>(
                    builder: (context, state) {
                      if (state.paths.isEmpty) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final h = constraints.maxHeight;
                            // احسب الأحجام بحيث يظهر النص دائماً مع حماية من overflow
                            double iconH = (h * 0.50).clamp(20.0, 100.0);
                            double spacing = (h * 0.06).clamp(2.0, 8.0);
                            double rem = h - iconH - spacing;

                            // حجم خط النص المتبقي مع حد أدنى/أقصى واضح
                            final textFs = (rem - 2).clamp(9.0, 16.0);

                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    PlayerAssets.musicListPng,
                                    height: iconH,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(height: spacing),
                                  Flexible(
                                    child: AutoSizeText(
                                      S.of(context).emptyPlaylist,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      minFontSize: 8,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: textFs,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Scrollbar(
                              controller: _scrollCtrl,
                              thumbVisibility: true,
                              interactive: true,
                              child: ListView.separated(
                                controller: _scrollCtrl,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: state.paths.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 6.h),
                                itemBuilder: (ctx, i) {
                                  final name = state.paths[i].split('/').last;
                                  final selected = state.selected.contains(i);
                                  final isCurrentlyPlaying =
                                      playbackState.currentIndex == i;
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      context
                                          .read<PlaybackCubit>()
                                          .playPath(state.paths[i], index: i);
                                    },
                                    onLongPress: () => context
                                        .read<PlaylistCubit>()
                                        .toggleSelection(i),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 10.h),
                                      decoration: BoxDecoration(
                                        color: isCurrentlyPlaying
                                            ? AppColors.black.withOpacity(0.15)
                                            : Colors.white.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isCurrentlyPlaying
                                              ? Color(0xff296D12)
                                              : Colors.white24,
                                          width: isCurrentlyPlaying ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                              PlayerAssets.musicFillPng),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                color: isCurrentlyPlaying
                                                    ? Color(0xff296D12)
                                                    : Colors.white,
                                                fontWeight: isCurrentlyPlaying
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          InkWell(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            onTap: () => context
                                                .read<PlaylistCubit>()
                                                .toggleSelection(i),
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              reverseDuration: const Duration(
                                                  milliseconds: 140),
                                              switchInCurve:
                                                  Curves.easeOutCubic,
                                              switchOutCurve:
                                                  Curves.easeInCubic,
                                              transitionBuilder:
                                                  (child, animation) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: ScaleTransition(
                                                    scale: animation,
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: selected
                                                  ? Image.asset(
                                                      PlayerAssets
                                                          .tickCirclePng,
                                                      key: const ValueKey(
                                                          'selected'),
                                                      width: 22,
                                                      height: 22,
                                                    )
                                                  : Image.asset(
                                                      PlayerAssets.plusPng,
                                                      key: const ValueKey(
                                                          'unselected'),
                                                      width: 22,
                                                      height: 22,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (state.paths.length >= 5) ...[
                            SizedBox(width: 8.w),
                            // شريط جانبي للتنقل السريع بين الأغاني (مقلوب 180°)
                            SizedBox(
                              width: 28,
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: SliderTheme(
                                  data: const SliderThemeData(
                                    trackHeight: 4,
                                    thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 8),
                                    overlayShape: RoundSliderOverlayShape(
                                        overlayRadius: 14),
                                    activeTrackColor: Color(0xff6EA75C),
                                    inactiveTrackColor: Color(0xffD9D9D9),
                                    thumbColor: Color(0xff6EA75C),
                                  ),
                                  child: Slider(
                                    min: 0.0,
                                    max: 1.0,
                                    value: _scrollRatio.clamp(0.0, 1.0),
                                    onChanged: (v) => _onSliderChange(v),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(height: 8.h),
            // Bottom CTA
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: widget.onAddMusic,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: SweepGradient(colors: [
                      Color(0xff0E3408),
                      Color(0xff296D12),
                      Color(0xff0E3408),
                      Color(0xff296D12),
                      Color(0xff0E3408),
                      Color(0xff296D12),
                    ]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppColors.white, size: 16),
                      SizedBox(width: 6),
                      AutoSizeText(
                        "Add Music",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// تم دمج منتقي أغاني الجهاز داخل قائمة التشغيل عبر زر "إضافة أغاني"

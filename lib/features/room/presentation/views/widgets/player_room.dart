import 'package:lklk/core/utils/logger.dart';
import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/utils/functions/snackbar_helper.dart';
import 'package:lklk/core/zego_delegate.dart';
import 'package:lklk/features/room/presentation/views/widgets/media_player/zego_slider_bar.dart';
import 'package:lklk/generated/l10n.dart';
import 'package:lklk/internal/internal.dart';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lklk/features/room/presentation/views/widgets/media_player/player_bottom_sheet.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lklk/core/config/app_config.dart';
import 'package:lklk/internal/sdk/music/music_pipe_service.dart';
import 'package:lklk/internal/sdk/livekit/livekit_audio_service.dart';
import 'package:lklk/zego_sdk_manager.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/livekit_audio/data/livekit_token_api.dart';

class PlayerRoom extends StatefulWidget {
  const PlayerRoom({
    super.key,
    this.fromOverlay,
    this.miniButtonSize,
    // required this.progressStream,
  });
  // final Stream<double>? progressStream;
  final bool? fromOverlay;
  // حجم اختياري لزر المشغّل المصغّر. إن لم يمرر، تُستخدم القيم القديمة.
  final double? miniButtonSize;

  @override
  State<PlayerRoom> createState() => _PlayerRoomState();
}

class _PlayerRoomState extends State<PlayerRoom> {
  ZegoDelegate zegoDelegate = ZegoDelegate();
  bool _isLoading = false;
  String _currentSong = '';
  final double _initVolume = 0.30;
  bool _isPlaying = true;
  bool _isAux = true;
  bool _isMuteLocal = false;
  final bool _isShowPlaying = false;
  Duration _currentPosition = Duration.zero;
  // final Duration _totalDuration = Duration.zero;
  final List<File> _playlist = [];
  int _currentSongIndex = -1;
  bool _isPlaylistEmpty = true;
  final String _playlistKey = 'user_playlist';
  bool _isInitializedByThisWidget = false;
  bool _isSongLoading = false;
  double _currentProgress = 0.0;
  // Prevent multiple auto-advance triggers at the end of a track
  bool _endHandled = false;

  // Music pipe (WebSocket -> Node bot -> LiveKit) integration
  MusicPipeService? _musicPipe;
  StreamSubscription<MusicPipeState>? _pipeSub;
  String get _pipeRoomName => _derivePipeRoomName();

  String _derivePipeRoomName() {
    // Prefer LiveKit room ID if available; fallback to Zego room ID
    try {
      final lkId = LiveKitAudioService.instance.currentRoomID;
      if (lkId.isNotEmpty) return lkId;
    } catch (_) {}
    try {
      final zegoId = ZEGOSDKManager().expressService.currentRoomID;
      if (zegoId.isNotEmpty) return zegoId;
    } catch (_) {}
    return 'room-unknown';
  }

  Future<String> _fetchMusicBotToken(String roomName) async {
  final userId = (() {
    try {
      return ZEGOSDKManager().currentUser?.iduser;
    } catch (_) {
      return null;
    }
  })();
  final identity = (userId != null && userId.isNotEmpty)
      ? 'musicbot_' + userId
      : 'musicbot_' + DateTime.now().millisecondsSinceEpoch.toString();
  try {
    final api = LiveKitTokenApiImpl(ApiService());
    final token = await api.fetchToken(identity: identity, roomId: roomName);
    if (token != null && token.isNotEmpty) {
      return token;
    }
  } catch (e) {
    // Fallback to manual call if LiveKitTokenApiImpl fails
    try {
      final api = ApiService();
      final resp = await api.get('/livekit/token', queryParameters: {
        'identity': identity,
        'room': roomName,
      }, retries: 2);
      final data = resp.data;
      if (data is Map && data['token'] is String) {
        return data['token'] as String;
      }
      if (data is String && data.contains('.')) {
        return data;
      }
    } catch (_) {}
  }
  throw Exception('Failed to fetch MusicBot token');
}


  Future<void> _ensureMusicPipe() async {
    if (_musicPipe == null) {
      if (AppConfig.musicPipeWsUrl.isEmpty) {
        throw Exception('AppConfig.musicPipeWsUrl is empty. Configure WS URL.');
      }
      _musicPipe = MusicPipeService(wsUrl: AppConfig.musicPipeWsUrl);
      _pipeSub = _musicPipe!.stateStream.listen((s) {
        // Map remote playback state to UI
        if (!mounted) return;
        setState(() {
          _isPlaying = s.isPlaying;
          _currentPosition = Duration(milliseconds: s.positionMs);
          _currentProgress = s.positionMs.toDouble();
          // Optionally update title from bot
          if (s.title != null && s.title!.isNotEmpty) {
            _currentSong = s.title!;
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // في حال تم تمرير حجم مخصص، اعرض زر مصغّر مربع بهذا الحجم
    if (widget.miniButtonSize != null) {
      return SizedBox(
        width: widget.miniButtonSize,
        height: widget.miniButtonSize,
        child: minPlayerButton(),
      );
    }

    // السلوك الافتراضي القديم
    return SizedBox(
      height: 240,
      width: 220,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IndexedStack(
            index: _isShowPlaying ? 1 : 0,
            children: [
              minPlayerButton(),
            ],
          ),
        ],
      ),
    );
  }

  Align minPlayerButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedContainer(
        duration: Duration(seconds: 1),
        alignment: Alignment.center,
        width: widget.miniButtonSize ?? 52.w,
        height: widget.miniButtonSize ?? 52.w,
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(
            width: widget.miniButtonSize ?? 52.w,
            height: widget.miniButtonSize ?? 52.w,
          ),
          onPressed: _toggleIsShowPlaying,
          icon: SvgPicture.asset(
            'assets/icons/room_btn/player_music_icon_btn.svg',
            width: (widget.miniButtonSize ?? 52.w),
            height: (widget.miniButtonSize ?? 52.w),
          ),
        ),
      ),
    );
  }

  Widget volumeSection() {
    return SizedBox(
      width: 120,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            height: 18,
            child: Center(
              child: ZegoSliderBar(
                onProgressChanged: onVolumeChanged,
                value: _initVolume,
              ),
            ),
          ),
          const Icon(
            FontAwesomeIcons.volumeHigh,
            color: AppColors.white,
            size: 18,
          )
        ],
      ),
    );
  }

  Row nextPreviosPauseResume() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded, color: AppColors.white),
          iconSize: 32,
          onPressed: _isLoading ? null : _playPrevious,
        ),
        IconButton(
          icon: _isLoading
              ? const CircularProgressIndicator()
              : Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_filled_rounded,
                  size: 48,
                  color: AppColors.white,
                ),
          onPressed: () {
            if (_playlist.isEmpty) {
              SnackbarHelper.showMessage(context, S.of(context).emptyPlaylist);
              return;
            }
            _togglePlayPause();
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, color: AppColors.white),
          iconSize: 32,
          onPressed: _isLoading ? null : _playNext,
        ),
      ],
    );
  }

  // Row buttonsRow() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       IconButton(
  //         padding: const EdgeInsets.all(0),
  //         onPressed: () {
  //           _toggleIsMuteLocalPlaying();
  //         },
  //         icon: AutoSizeText(
  //           S.of(context).muteLocal,
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //               color: _isMuteLocal ? AppColors.white : AppColors.grey,
  //               fontWeight: FontWeight.w900),
  //         ),
  //       ),
  //       IconButton(
  //         padding: const EdgeInsets.all(0),
  //         onPressed: () {
  //           _toggleAuxPlaying();
  //         },
  //         icon: AutoSizeText(
  //           S.of(context).auxLabel,
  //           style: TextStyle(
  //               color: _isAux ? AppColors.white : AppColors.grey,
  //               fontWeight: FontWeight.w900),
  //         ),
  //       ),
  //       IconButton(
  //         padding: const EdgeInsets.all(0),
  //         onPressed: () {
  //           // فتح منتقي أغاني الجهاز داخل BottomSheet
  //           showModalBottomSheet(
  //             context: context,
  //             isScrollControlled: true,
  //             backgroundColor: Colors.transparent,
  //             builder: (_) => const DeviceSongsBottomSheet(),
  //           );
  //         },
  //         icon: const Icon(
  //           FontAwesomeIcons.add,
  //           color: AppColors.white,
  //           size: 17,
  //         ),
  //       ),
  //       IconButton(
  //         padding: const EdgeInsets.all(0),
  //         onPressed: () {
  //           // فتح BottomSheet لقائمة الأغاني بدلاً من AlertDialog
  //           // showModalBottomSheet(
  //           //   context: context,
  //           //   isScrollControlled: true,
  //           //   backgroundColor: Colors.transparent,
  //           //   builder: (_) => const PlaylistBottomSheet(),
  //           // );
  //         },
  //         icon: const Icon(
  //           FontAwesomeIcons.music,
  //           color: AppColors.white,
  //           size: 17,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  SizedBox songNameWithCancelBtn() {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          Expanded(
            child: Marquee(
              text: _currentSong.isNotEmpty
                  ? _currentSong
                  : S.of(context).noSongSelected,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          IconButton(
            iconSize: 12,
            onPressed: () {
              _toggleIsShowPlaying();
            },
            icon: const Icon(
              FontAwesomeIcons.xmark,
              color: AppColors.white,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    zegoDelegate = ZegoDelegate();
    zegoDelegate.setZegoEventCallback();
    zegoDelegate.muteLocalMediaPlayer(_isMuteLocal);
    // _initZegoSDK();

    if (!(widget.fromOverlay ?? false) && !AppConfig.enableMusicPipe) {
      _initZegoSDK();
      _isInitializedByThisWidget = true;
    }

    _loadPlaylist();
    if (!AppConfig.enableMusicPipe) {
      zegoDelegate.setVolumeMediaPlayer(_initVolume);
    }

    // Listen to playback progress to detect end of track and auto-advance
    if (!AppConfig.enableMusicPipe) {
      zegoDelegate.setZegoEventCallback(
        onMediaPlayerPlayingProgress: (double ratio) {
          // ratio: 0.0..1.0
          if (!mounted) return;
          // Trigger once when reaching ~100%
          if (ratio >= 0.999 && !_endHandled) {
            _endHandled = true;
            // Mark not playing and jump to next track
            _isPlaying = false;
            _playNext();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    if (_isInitializedByThisWidget && !(widget.fromOverlay ?? false)) {
      zegoDelegate.stopMediaPlayer();
      zegoDelegate.destroyMediaPlayer();
    }
    // Cleanup music pipe if present
    try { _pipeSub?.cancel(); } catch (_) {}
    _pipeSub = null;
    _musicPipe?.dispose();
    super.dispose();
  }

  Future<void> _initZegoSDK() async {
    await zegoDelegate.createMediaPlayer();
  }

  Future<void> _toggleAuxPlaying() async {
    log("[_toggleAuxPlaying] تبديل وضع AUX من: $_isAux");
    if (mounted) {
      setState(() => _isAux = !_isAux);
    }
    log("[_toggleAuxPlaying] قيمة AUX الجديدة: $_isAux");
    zegoDelegate.enableAuxMediaPlayer(_isAux);
  }

  Future<void> _toggleIsMuteLocalPlaying() async {
    log("[_toggleIsMuteLocalPlaying] تبديل كتم الصوت المحلي من: $_isMuteLocal");
    if (mounted) {
      setState(() => _isMuteLocal = !_isMuteLocal);
    }
    log("[_toggleIsMuteLocalPlaying] الحالة الجديدة لكتم الصوت المحلي: $_isMuteLocal");
    zegoDelegate.muteLocalMediaPlayer(_isMuteLocal);
  }

  void _updatePlaylistStatus() {
    if (mounted) {
      setState(() {
        _isPlaylistEmpty = _playlist.isEmpty;
      });
    }
    log("[_updatePlaylistStatus] حالة قائمة التشغيل: ${_isPlaylistEmpty ? 'فارغة' : 'محتوية'}");
  }

  Future<void> _toggleIsShowPlaying() async {
    // فتح الـ BottomSheet الاحترافي للمشغل بدلاً من تبديل ويدجت محلي
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PlayerBottomSheet(),
    );
  }

  Future<void> _togglePlayPause() async {
    log("[_togglePlayPause] تبديل التشغيل/الإيقاف المؤقت");
    if (_playlist.isEmpty) {
      log("[_togglePlayPause] قائمة التشغيل فارغة، لا يوجد شيء للتشغيل");
      return;
    }

    if (AppConfig.enableMusicPipe) {
      try {
        await _ensureMusicPipe();
        if (!_isPlaying) {
          if (_currentSongIndex == -1) {
            _currentSongIndex = 0;
            log("[_togglePlayPause] [Pipe] تشغيل أول أغنية عبر البوت");
            await _playSelectedSong(_playlist[_currentSongIndex]);
          } else {
            log("[_togglePlayPause] [Pipe] استئناف");
            _musicPipe?.resume();
          }
        } else {
          log("[_togglePlayPause] [Pipe] إيقاف مؤقت");
          _musicPipe?.pause();
        }
      } catch (e) {
        SnackbarHelper.showMessage(context, 'MusicPipe error: $e');
      }
    } else {
      if (!_isPlaying) {
        if (_currentSongIndex == -1) {
          _currentSongIndex = 0;
          log("[_togglePlayPause] لا توجد أغنية مختارة، تشغيل الأولى");
          await _playSelectedSong(_playlist[_currentSongIndex]);
        } else {
          log("[_togglePlayPause] استئناف التشغيل");
          zegoDelegate.resumeMediaPlayer();
        }
      } else {
        log("[_togglePlayPause] إيقاف التشغيل مؤقتاً");
        zegoDelegate.pauseMediaPlayer();
      }
    }

    if (mounted) {
      setState(() => _isPlaying = !_isPlaying);
    }
    log("[_togglePlayPause] الحالة الجديدة للتشغيل: $_isPlaying");
  }

  void _removeSong(int index,
      {void Function(void Function())? setStateDialog}) {
    log("[_removeSong] إزالة الأغنية من القائمة بفهرس: $index");
    final updateState = setStateDialog ??
        (fn) {
          if (mounted) {
            setState(fn);
          }
        };

    updateState(() {
      File fileToDelete = _playlist[index];
      try {
        fileToDelete.delete(); // حذف الملف من التخزين الدائم
        log("[_removeSong] تم حذف الملف: ${fileToDelete.path}");
      } catch (e) {
        log("[_removeSong] خطأ أثناء حذف الملف: $e");
      }
      _playlist.removeAt(index);
      if (_currentSongIndex == index) {
        _currentSongIndex = -1;
        _currentSong = '';
        _currentPosition = Duration.zero;
        // If we removed the currently playing item, stop remote stream if enabled
        if (AppConfig.enableMusicPipe) {
          _musicPipe?.stop();
        }
      }
      // إذا كان هناك حذف خاطئ لمرة ثانية (يظهر في الكود الأصلي) تأكد من عدم التكرار
      // _playlist.removeAt(index);
      _updatePlaylistStatus();

      if (_playlist.isNotEmpty && index <= _currentSongIndex) {
        _currentSongIndex =
            (_currentSongIndex - 1).clamp(0, _playlist.length - 1);
      }
    });

    try {
      _savePlaylist();
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showMessage(context, 'خطأ في حفظ القائمة: $e');
      }
    }
  }

  void _clearPlaylist() {
    log("[_clearPlaylist] مسح قائمة التشغيل بالكامل");
    if (mounted) {
      setState(() {
        _playlist.clear();
        _currentSongIndex = -1;
        _currentSong = '';
        _currentPosition = Duration.zero;
        if (AppConfig.enableMusicPipe) {
          _musicPipe?.stop();
        }
      });
    }

    try {
      _savePlaylist();
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showMessage(context, 'خطأ في حفظ القائمة: $e');
      }
    }
  }

  Future<void> _loadPlaylist() async {
    log("[_loadPlaylist] تحميل قائمة التشغيل من SharedPreferences");
    final prefs = await SharedPreferences.getInstance();
    final List<String>? paths = prefs.getStringList(_playlistKey);
    log("[_loadPlaylist] المسارات المُسترجعة: ${paths?.join(', ') ?? 'none'}");

    if (paths != null && paths.isNotEmpty) {
      List<File> existingFiles = [];

      for (String path in paths) {
        File file = File(path);
        bool exists = await file.exists();
        log("[_loadPlaylist] التحقق من وجود الملف: $path - موجود: $exists");
        if (exists) {
          existingFiles.add(file);
        }
      }

      log("[_loadPlaylist] عدد الملفات الصحيحة: ${existingFiles.length}");

      if (mounted) {
        setState(() {
          _playlist.addAll(existingFiles);
          if (_playlist.isNotEmpty) {
            _currentSongIndex = 0;
            _currentSong = _playlist[_currentSongIndex].path.split('/').last;
          }
        });
      }
      _updatePlaylistStatus();
    }
  }

  Future<void> _savePlaylist() async {
    log("[_savePlaylist] حفظ قائمة التشغيل إلى SharedPreferences");
    try {
      final prefs = await SharedPreferences.getInstance();
      final paths = _playlist.map((file) => file.path).toList();
      await prefs.setStringList(_playlistKey, paths);
      log("[_savePlaylist] حفظ القائمة بنجاح");
    } catch (e) {
      log("[_savePlaylist] خطأ أثناء حفظ القائمة: $e");
      if (mounted) {
        SnackbarHelper.showMessage(context, 'فشل في حفظ قائمة التشغيل: $e');
      }
    }
  }

  Future<bool> _requestPermission() async {
    PermissionStatus status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<void> _pickAndPlaySong() async {
    // تأكد من طلب الصلاحيات أولاً
    await _requestPermission();
    // if (!hasPermission) {
    //   SnackbarHelper.showMessage(context, 'الصلاحيات غير متاحة');
    //   return;
    // }

    log("[_pickAndPlaySong] PlayerRoomLog: Starting file picker process");
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          // Audio Formats
          'mp3', 'MP3', 'Mp3', 'mP3',
          'wav', 'WAV', 'Wav',
          'm4a', 'M4A', 'M4a', 'm4A',
          'flac', 'FLAC',
          'ogg', 'OGG',
          'aiff', 'AIFF',
          'wma', 'WMA',
          'aac', 'AAC',
          'opus', 'OPUS',

          // 'mp4', 'MP4', 'MPEG-4',
          // Video Formats// llllllllllllllllllllllllllllllllllllllllllllllllllllllllll
          // 'mkv', 'MKV',
          // 'avi', 'AVI',
          // 'mov', 'MOV',
          // 'wmv', 'WMV',
          // 'flv', 'FLV',
          // 'webm', 'WEBM',
          // '3gp', '3GP',
          // 'mpeg', 'MPEG', 'mpg', 'MPG',
          // 'ts', 'TS', 'm2ts', 'M2TS'
        ],
        withData: true,
      );

      log("[_pickAndPlaySong] PlayerRoomLog: Finalizing picker process");
      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        final appDir = await getApplicationDocumentsDirectory();
        File permanentFile;

        if (platformFile.path == null && platformFile.bytes != null) {
          // إذا لم يتوفر المسار نستخدم الـ bytes لإنشاء ملف
          String fileName = platformFile.name;
          permanentFile = File('${appDir.path}/$fileName');
          log("[_pickAndPlaySong] No path available. Creating file from bytes for: $fileName");
          await permanentFile.writeAsBytes(platformFile.bytes!);
        } else if (platformFile.path != null) {
          File tempFile = File(platformFile.path!);
          String fileName = platformFile.name;
          permanentFile = File('${appDir.path}/$fileName');

          log("[_pickAndPlaySong] Processing file - Temp: ${tempFile.path}, Permanent: ${permanentFile.path}");

          if (!await permanentFile.exists() ||
              (await permanentFile.length()) != (await tempFile.length())) {
            log("[_pickAndPlaySong] Copying file to permanent storage");
            await tempFile.copy(permanentFile.path);
            log("[_pickAndPlaySong] File copy completed successfully");
          } else {
            log("[_pickAndPlaySong] File already exists with same size, skipping copy");
          }
        } else {
          log("[_pickAndPlaySong] PlayerRoomLog: No file selected or both path and bytes are null");
          return;
        }

        // متابعة الإضافة لقائمة التشغيل والتشغيل
        _playlist.add(permanentFile);
        _currentSongIndex = _playlist.length - 1;
        _currentSong = permanentFile.path.split('/').last;
        await _savePlaylist();
        await _playSelectedSong(permanentFile);
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
        }
      } else {
        log("[_pickAndPlaySong] PlayerRoomLog: No file selected or path is null");
      }
    } catch (e) {
      log("[_pickAndPlaySong] PlayerRoomLog: Error in pickAndPlaySong: $e");
      if (mounted) {
        SnackbarHelper.showMessage(context, 'حدث خطأ أثناء اختيار الملف: $e');
      }
    }
  }

  Future<void> _playSelectedSong(File file) async {
    log("[_playSelectedSong] PlayerRoomLog: Attempting to play selected song: ${file.path}");

    if (_isSongLoading || !mounted) return;

    try {
      log("[_playSelectedSong] PlayerRoomLog: Checking file existence");
      if (!await file.exists()) {
        log("[_playSelectedSong] PlayerRoomLog: File not found: ${file.path}");
        throw Exception('الملف غير موجود: ${file.path}');
      }

      if (AppConfig.enableMusicPipe) {
        // Route to WebSocket pipe -> Node bot -> LiveKit
        await _ensureMusicPipe();
        setState(() {
          _isLoading = true;
          _currentPosition = Duration.zero;
          _isSongLoading = true;
          _currentProgress = 0.0;
        });
        final roomName = _pipeRoomName;
        final token = await _fetchMusicBotToken(roomName);
        // Ensure any previous stream is stopped before starting new one
        await _musicPipe!.stop();
        await _musicPipe!.startStreaming(
          roomName: roomName,
          token: token,
          file: file,
          title: file.path.split('/').last,
          mime: null,
        );
        setState(() {
          _currentSong = file.path.split('/').last;
          _isPlaying = true;
          _endHandled = false;
        });
        return;
      }

      log("[_playSelectedSong] PlayerRoomLog: Initializing playback setup");
      if (mounted) {
        setState(() {
          _isLoading = true;
          _currentPosition = Duration.zero;
          _isSongLoading = true;
          _currentProgress = 0.0;
        });
      }

      final currentState = await zegoDelegate.playerState;
      log("[_playSelectedSong] Current media player state: $currentState");
      if (currentState == ZegoMediaPlayerState.Playing) {
        await zegoDelegate.stopMediaPlayer();
      }

      if (!zegoDelegate.isInitialized) {
        log("[_playSelectedSong] Media player not initialized, initializing now");
        await zegoDelegate.createMediaPlayer();
      }

      await zegoDelegate.loadResourceWithPositionMediaPlayer(
        file.path,
        _currentPosition.inMilliseconds,
        ZegoAlphaLayoutType.Right,
      );

      zegoDelegate.enableAuxMediaPlayer(_isAux);
      zegoDelegate.startMediaPlayer();

      setState(() {
        _currentSong = file.path.split('/').last;
        _isPlaying = true; // تأكيد حالة التشغيل
        _endHandled = false; // reset end-of-track guard for new song
      });
      log("[_playSelectedSong] Now playing: $_currentSong");
    } catch (e) {
      log("[_playSelectedSong] Error playing song: $e");
      if (mounted) {
        SnackbarHelper.showMessage(context, 'خطأ في التشغيل: ${e.toString()}');
        _removeInvalidFiles(); // إزالة الملفات التالفة تلقائياً
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSongLoading = false;
        });
      }
    }
  }

  void _removeInvalidFiles() async {
    log("[_removeInvalidFiles] Checking for invalid files in playlist");
    List<File> validFiles = [];
    for (File file in _playlist) {
      bool exists = await file.exists();
      log("[_removeInvalidFiles] File validity check: ${file.path} - Exists: $exists");
      if (exists) {
        validFiles.add(file);
      }
    }

    log("[_removeInvalidFiles] Valid files remaining: ${validFiles.length}");

    if (mounted) {
      setState(() {
        _playlist.clear();
        _playlist.addAll(validFiles);
        _savePlaylist();
        _updatePlaylistStatus();
      });
    }
  }

  void _playNext() {
    log("[_playNext] الضغط على زر الأغنية التالية");
    if (_playlist.isEmpty || _currentSongIndex == -1) {
      log("[_playNext] لا توجد أغاني في القائمة");
      return;
    }
    SystemSound.play(SystemSoundType.click);
    int newIndex = _currentSongIndex + 1;
    if (newIndex < _playlist.length) {
      _currentSongIndex = newIndex;
      log("[_playNext] تشغيل أغنية بالفهرس: $_currentSongIndex");
      _playSelectedSong(_playlist[_currentSongIndex]);
    } else {
      log("[_playNext] تم الوصول لنهاية القائمة");
    }
  }

  void _playPrevious() {
    log("[_playPrevious] الضغط على زر الأغنية السابقة");
    if (_playlist.isEmpty || _currentSongIndex == -1) {
      log("[_playPrevious] لا توجد أغاني في القائمة");
      return;
    }

    int newIndex = _currentSongIndex - 1;
    if (newIndex >= 0) {
      _currentSongIndex = newIndex;
      log("[_playPrevious] تشغيل أغنية بالفهرس: $_currentSongIndex");
      _playSelectedSong(_playlist[_currentSongIndex]);
    } else {
      log("[_playPrevious] لا توجد أغنية سابقة");
    }
  }

  void onPlayerProgressChanged(double progress) async {
    log("[onPlayerProgressChanged] تغيير تقدم التشغيل إلى: $progress");
    if (AppConfig.enableMusicPipe) {
      try {
        _musicPipe?.seek(progress.toInt());
      } catch (e) {
        SnackbarHelper.showMessage(context, 'MusicPipe seek error: $e');
      }
    } else {
      await zegoDelegate.seekToMediaPlayer(progress);
    }
    if (mounted) {
      setState(() {
        _currentPosition = Duration(milliseconds: progress.toInt());
        _currentProgress = progress;
      });
    }
  }

  void onVolumeChanged(double volume) {
    log("[onVolumeChanged] تغيير مستوى الصوت إلى: $volume");
    if (AppConfig.enableMusicPipe) {
      _musicPipe?.setVolume(volume);
    } else {
      zegoDelegate.setVolumeMediaPlayer(volume);
    }
  }

  void onVolumeHighChanged(double volume) {
    log("[onVolumeHighChanged] تغيير معلمة الصوت العالي إلى: $volume");
    if (mounted) {
      setState(() {});
    }
    zegoDelegate.setVoiceChangerParamMediaPlayer(volume);
  }

  BoxDecoration musicDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary,
          AppColors.secondColor,
        ],
      ),
      borderRadius: BorderRadius.circular(20),
    );
  }

}
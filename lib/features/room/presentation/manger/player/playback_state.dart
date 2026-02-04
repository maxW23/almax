part of 'playback_cubit.dart';

/// حالة المشغل الصوتي
class PlaybackState extends Equatable {
  final bool isPlaying; // حالة التشغيل
  final double volume; // من 0..1
  final bool isAux; // تفعيل AUX
  final bool isMuteLocal; // كتم محلي
  final double progress; // 0..1
  final int durationMs; // مدة المقطع ms (إن وُجدت)
  final int currentIndex; // فهرس الأغنية في القائمة
  final String currentSong; // اسم/مسار الأغنية الحالية

  const PlaybackState({
    this.isPlaying = false,
    this.volume = 0.30,
    this.isAux = true,
    this.isMuteLocal = false,
    this.progress = 0.0,
    this.durationMs = 0,
    this.currentIndex = -1,
    this.currentSong = '',
  });

  PlaybackState copyWith({
    bool? isPlaying,
    double? volume,
    bool? isAux,
    bool? isMuteLocal,
    double? progress,
    int? durationMs,
    int? currentIndex,
    String? currentSong,
  }) {
    return PlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      isAux: isAux ?? this.isAux,
      isMuteLocal: isMuteLocal ?? this.isMuteLocal,
      progress: progress ?? this.progress,
      durationMs: durationMs ?? this.durationMs,
      currentIndex: currentIndex ?? this.currentIndex,
      currentSong: currentSong ?? this.currentSong,
    );
  }

  @override
  List<Object?> get props => [
        isPlaying,
        volume,
        isAux,
        isMuteLocal,
        progress,
        durationMs,
        currentIndex,
        currentSong,
      ];
}

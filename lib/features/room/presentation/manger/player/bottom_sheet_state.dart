part of 'bottom_sheet_cubit.dart';

class BottomSheetState extends Equatable {
  final bool isPlayerOpen;
  final bool isPlaylistOpen;
  final double extent; // 0..1 - مستوى التوسيع
  final bool isMini; // وضع مصغّر/كامل

  const BottomSheetState({
    this.isPlayerOpen = false,
    this.isPlaylistOpen = false,
    this.extent = 0.25,
    this.isMini = true,
  });

  BottomSheetState copyWith({
    bool? isPlayerOpen,
    bool? isPlaylistOpen,
    double? extent,
    bool? isMini,
  }) =>
      BottomSheetState(
        isPlayerOpen: isPlayerOpen ?? this.isPlayerOpen,
        isPlaylistOpen: isPlaylistOpen ?? this.isPlaylistOpen,
        extent: extent ?? this.extent,
        isMini: isMini ?? this.isMini,
      );

  @override
  List<Object?> get props => [isPlayerOpen, isPlaylistOpen, extent, isMini];
}

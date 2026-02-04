import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'bottom_sheet_state.dart';

/// Cubit لإدارة واجهات الـ BottomSheet (المشغل وقائمة الأغاني)
class BottomSheetCubit extends Cubit<BottomSheetState> {
  BottomSheetCubit() : super(const BottomSheetState());

  void openPlayerSheet() => emit(state.copyWith(isPlayerOpen: true));
  void closePlayerSheet() => emit(state.copyWith(isPlayerOpen: false));

  void openPlaylistSheet() => emit(state.copyWith(isPlaylistOpen: true));
  void closePlaylistSheet() => emit(state.copyWith(isPlaylistOpen: false));

  void setExtent(double extent) => emit(state.copyWith(extent: extent));

  void setMiniMode(bool mini) => emit(state.copyWith(isMini: mini));
}

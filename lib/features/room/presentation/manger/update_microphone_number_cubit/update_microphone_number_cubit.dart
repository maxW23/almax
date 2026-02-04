//
// import 'package:meta/meta.dart';

// import 'package:lklk/core/utils/logger.dart';

//
// import 'package:lklk/features/room_view/domain/use_cases/update_microphone_number_use_case.dart';
// import 'package:lklk/features/room_view/domain/entities/room_entity.dart';

// part 'update_microphone_number_state.dart';

// // class UpdateMicrophoneNumberCubit extends Cubit<MicrophoneNumberState> {
// //   UpdateMicrophoneNumberCubit() : super(UpdateMicrophoneNumberInitial());
// // }
// // microphone_number_cubit.dart

// class MicrophoneNumberCubit extends Cubit<MicrophoneNumberState> {
//   final UpdateMicrophoneNumberUseCase _updateMicrophoneNumberUseCase;

//   MicrophoneNumberCubit(this._updateMicrophoneNumberUseCase)
//       : super(MicrophoneNumberInitial());

//   void updateMicrophoneNumber(int roomId, int newMicrophoneNumber) async {
//     try {
//       emit(MicrophoneNumberLoading());
//       await _updateMicrophoneNumberUseCase.updateMicrophoneNumber(
//           roomId, newMicrophoneNumber);
//       emit(MicrophoneNumberUpdated());
//     } catch (e) {
//       emit(MicrophoneNumberError('Failed to update microphone number: $e'));
//     }
//   }
// }

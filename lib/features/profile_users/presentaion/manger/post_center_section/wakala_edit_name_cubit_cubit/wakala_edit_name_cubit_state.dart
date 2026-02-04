part of 'wakala_edit_name_cubit_cubit.dart';

// الفئة الأساسية
abstract class WakalaEditNameCubitState extends Equatable {
  const WakalaEditNameCubitState();

  @override
  List<Object> get props => [];
}

// الحالات المورثة
class WakalaEditNameCubitInitial extends WakalaEditNameCubitState {}

class WakalaEditNameLoading extends WakalaEditNameCubitState {}

class WakalaEditNameSuccess extends WakalaEditNameCubitState {
  final String newName;
  const WakalaEditNameSuccess(this.newName);

  @override
  List<Object> get props => [newName];
}

class WakalaEditNameError extends WakalaEditNameCubitState {
  final String message;
  const WakalaEditNameError(this.message);

  @override
  List<Object> get props => [message];
}

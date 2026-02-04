import 'package:equatable/equatable.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';

enum Status { initial, loading, success, error }

class FetchElementsCubitState extends Equatable {
  final String? message;
  final String? error;
  final List<ElementEntity>? elements;
  final List<ElementEntity>? myElements;
  final Status status;

  const FetchElementsCubitState({
    this.message,
    this.error,
    this.elements,
    this.myElements,
    this.status = Status.initial,
  });

  @override
  List<Object?> get props => [message, error, elements, status, myElements];

  FetchElementsCubitState copyWith({
    String? message,
    String? error,
    List<ElementEntity>? elements,
    List<ElementEntity>? myElements,
    Status? status,
  }) {
    return FetchElementsCubitState(
      message: message ?? this.message,
      error: error ?? this.error,
      elements: elements ?? this.elements,
      myElements: myElements ?? this.myElements,
      status: status ?? this.status,
    );
  }

  factory FetchElementsCubitState.initial() {
    return const FetchElementsCubitState(
      elements: [],
      myElements: [],
      error: null,
      message: null,
      status: Status.initial,
    );
  }

  bool isLoading() => status == Status.loading;
}

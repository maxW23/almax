import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';

abstract class ElementsState {}

class ElementsLoading extends ElementsState {}

class ElementsLoaded extends ElementsState {
  final List<ElementEntity> elements;

  ElementsLoaded(this.elements);

  List<Object?> get props => [elements];
}

class ElementsError extends ElementsState {
  final String message;

  ElementsError(this.message);

  List<Object?> get props => [message];
}

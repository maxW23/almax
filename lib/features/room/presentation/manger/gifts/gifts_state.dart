part of 'gifts_cubit.dart';

class GiftState extends Equatable {
  final String? message;
  final String? error;
  final List<ElementEntity>? elements;
  final List<ElementEntity>? elementsImage;
  final Status status;
  final bool isSending;
  final Map<String, dynamic>? gift;

  @override
  List<Object?> get props =>
      [message, error, elements, elementsImage, status, isSending, gift];

  const GiftState({
    this.elements,
    this.elementsImage,
    this.error,
    this.message,
    this.status = Status.initial,
    this.isSending = false,
    this.gift,
  });

  // دالة copyWith لتحديث القيم المطلوبة فقط
  GiftState copyWith({
    String? message,
    String? error,
    List<ElementEntity>? elements,
    List<ElementEntity>? elementsImage,
    Status? status,
    bool? isSending,
    Map<String, dynamic>? gift,
  }) {
    return GiftState(
      message: message ?? this.message,
      error: error ?? this.error,
      elements: elements ?? this.elements,
      elementsImage: elementsImage ?? this.elementsImage,
      status: status ?? this.status,
      isSending: isSending ?? this.isSending,
      gift: gift ?? this.gift,
    );
  }

  // دالة ثابتة لإنشاء حالة initial
  factory GiftState.initial() {
    return const GiftState(
      elements: [],
      elementsImage: [],
      error: null,
      message: null,
      status: Status.initial,
      isSending: false,
      gift: null,
    );
  }

  // دالة للتحقق إذا كانت الحالة loading
  bool isLoading() => status == Status.loading;
}

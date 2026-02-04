import 'package:flutter/foundation.dart';
import 'package:lklk/features/home/domain/entities/banner_entity.dart';

enum BannerStatus { initial, loading, loaded, error }

extension BannerStatusX on BannerStatus {
  bool get isInitial => this == BannerStatus.initial;
  bool get isLoading => this == BannerStatus.loading;
  bool get isLoaded => this == BannerStatus.loaded;
  bool get isError => this == BannerStatus.error;
}

class BannerState {
  final BannerStatus status;
  final String? errorMessage;
  final List<BannerModel>? banners;

  const BannerState({
    required this.status,
    this.banners,
    this.errorMessage,
  });

  @override
  int get hashCode =>
      status.hashCode ^ banners.hashCode ^ errorMessage.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BannerState &&
        other.status == status &&
        listEquals(other.banners, banners) &&
        other.errorMessage == errorMessage;
  }

  BannerState copyWith({
    BannerStatus? status,
    List<BannerModel>? banners,
    String? errorMessage,
  }) {
    return BannerState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

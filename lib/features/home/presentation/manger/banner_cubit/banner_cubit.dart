import 'dart:async';

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/home/domain/entities/banner_entity.dart';
import 'package:lklk/features/home/presentation/manger/banner_cubit/banner_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BannerCubit extends Cubit<BannerState> {
  BannerCubit() : super(const BannerState(status: BannerStatus.initial));
  List<BannerModel>? cachedBanners;
  Future<void> fetchBanners({bool forceRefresh = false}) async {
    // 1) حاول تحميل الكاش المحلي وإظهاره فوراً بدون حالة تحميل
    if (cachedBanners == null || cachedBanners!.isEmpty) {
      final local = await _loadCachedBanners();
      if (local != null && local.isNotEmpty) {
        cachedBanners = local;
        emit(state.copyWith(status: BannerStatus.loaded, banners: local));
      }
    }

    // 2) إذا لا نحتاج تحديث قسري ولدينا بيانات، لا نعيد الطلب
    if (!forceRefresh && cachedBanners != null && cachedBanners!.isNotEmpty) {
      return;
    }

    // 3) في حال عدم وجود كاش سابقاً، اعرض حالة تحميل
    if (state.status == BannerStatus.initial) {
      emit(state.copyWith(status: BannerStatus.loading));
    }

    try {
      final response = await ApiService().get('/banner1');
      final parsedData = jsonDecode(response.data);

      List<BannerModel> banners = (parsedData['banner'] as List)
          .map((banner) => BannerModel.fromJson(banner))
          .toList();

      await _cachedBanners(banners);
      cachedBanners = banners;

      emit(state.copyWith(status: BannerStatus.loaded, banners: banners));
    } catch (e) {
      // إذا كان لدينا كاش معروض بالفعل، لا نحطم الواجهة بحالة خطأ
      if (cachedBanners != null && cachedBanners!.isNotEmpty) {
        return;
      }
      emit(state.copyWith(
          status: BannerStatus.error,
          errorMessage: "Failed to get Banners $e"));
    }
  }

  _cachedBanners(List<BannerModel> banners) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = banners.map((banner) => banner.toJson()).toList();
    await prefs.setString('cachedBanners', jsonEncode(jsonList));
  }

  Future<List<BannerModel>?> _loadCachedBanners() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cachedBanners');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}

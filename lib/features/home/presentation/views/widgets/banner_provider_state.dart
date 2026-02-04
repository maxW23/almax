import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/features/home/presentation/manger/banner_cubit/banner_cubit.dart';
import 'package:lklk/features/home/presentation/manger/banner_cubit/banner_state.dart';
import 'package:lklk/features/home/presentation/views/widgets/image_slideshow_widget.dart';

// مكون جديد لعزل البانر عن التحديثات
class BannerProvider extends StatefulWidget {
  final Widget child;
  final BannerState? cachedBannerState;
  final Function(BannerState)? onBannerStateChanged;

  const BannerProvider({
    super.key,
    required this.child,
    this.cachedBannerState,
    this.onBannerStateChanged,
  });

  @override
  State<BannerProvider> createState() => _BannerProviderState();
}

class _BannerProviderState extends State<BannerProvider> {
  BannerCubit? _bannerCubit;

  @override
  void initState() {
    super.initState();

    // إذا كان لدينا حالة مخزنة مسبقاً، لا نحتاج لتحميل البانر مرة أخرى
    if (widget.cachedBannerState == null) {
      _bannerCubit = BannerCubit()..fetchBanners();
    }
  }

  @override
  Widget build(BuildContext context) {
    // إذا كان لدينا حالة مخزنة، نعرضها مباشرة دون استخدام Bloc
    if (widget.cachedBannerState != null) {
      final banners = widget.cachedBannerState!.banners;
      return banners != null
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ImageSlideshowWidget(
                  height: 100,
                  images: banners
                      .where((banner) => banner.img != null)
                      .map((banner) => banner.img!)
                      .toList(),
                  onTaps: banners
                      .map((banner) => () {
                            // تحتاج إلى تمرير دالة _onBannerTap من الوالد
                            // يمكنك تعديل هذا الجزء حسب احتياجاتك
                          })
                      .toList(),
                ),
              ),
            )
          : Container();
    }

    // إذا لم تكن هناك حالة مخزنة، نستخدم Bloc كالمعتاد
    return BlocProvider.value(
      value: _bannerCubit!,
      child: BlocListener<BannerCubit, BannerState>(
        listener: (context, state) {
          if (widget.onBannerStateChanged != null) {
            widget.onBannerStateChanged!(state);
          }
        },
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _bannerCubit?.close();
    super.dispose();
  }
}

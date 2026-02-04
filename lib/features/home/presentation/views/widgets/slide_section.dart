import 'package:lklk/core/utils/logger.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/core/utils/custom_fading_widget.dart';
import 'package:lklk/features/home/presentation/manger/banner_cubit/banner_cubit.dart';
import 'package:lklk/features/home/presentation/manger/banner_cubit/banner_state.dart';
import 'package:lklk/features/home/presentation/manger/room_cubit/room_cubit_cubit.dart';
import 'package:lklk/features/home/presentation/views/slide_view/top_relation_page.dart';
import 'package:lklk/features/home/presentation/views/widgets/banner_provider_state.dart';
import 'package:lklk/features/home/presentation/views/widgets/image_slideshow_widget.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/post_chargers_page.dart';
import 'package:lklk/features/room/presentation/views/widgets/room_view_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SlideSection extends StatelessWidget {
  final double heightImages;
  final double width;
  final BannerState? cachedBannerState;
  final ValueChanged<BannerState> onBannerStateChanged;
  final RoomCubit roomCubit;
  final UserCubit userCubit;

  const SlideSection({
    super.key,
    required this.heightImages,
    required this.width,
    required this.cachedBannerState,
    required this.onBannerStateChanged,
    required this.roomCubit,
    required this.userCubit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BannerProvider(
          cachedBannerState: cachedBannerState,
          onBannerStateChanged: onBannerStateChanged,
          child: BlocBuilder<BannerCubit, BannerState>(
            builder: (context, state) {
              final banners = state.banners;
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
                                    log("Banner slot tapped BEFORE checking link: ${banner.link}");
                                    debugAppLogger
                                        .debug('Banner tapped: ${banner.link}');
                                    _onBannerTap(
                                      context,
                                      banner.link,
                                      roomCubit,
                                      userCubit,
                                    );
                                  })
                              .toList(),
                        ),
                      ),
                    )
                  : _buildLoadingOrErrorState(state, width);
            },
          ),
        ),
        SizedBox(
          height: 90,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ImageSlideshowWidget(
                isLoop: false,
                indicatorRadius: 1,
                height: heightImages,
                width: width,
                fit: BoxFit.cover,
                images: const [AssetsData.top50RelationsBannerSliders],
                onTaps: [
                  () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TopRelationPage(),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOrErrorState(BannerState state, double width) {
    if (state.status.isLoading) {
      return CustomFadingWidget(
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          width: width,
          height: 100,
        ),
      );
    } else if (state.status.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: AutoSizeText(state.errorMessage ?? 'Error loading banners'),
        ),
      );
    }
    return Container();
  }

  void _onBannerTap(
    BuildContext context,
    String? link,
    RoomCubit roomCubit,
    UserCubit userCubit,
  ) {
    log("_onBannerTap link: $link");

    if (link == null || link == "null") return;

    if (link.startsWith('http')) {
      launchUrl(Uri.parse(link));
    } else if (link == 'no') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PostChargersPage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => RoomViewBloc(
            roomId: int.parse(link),
            roomCubit: roomCubit,
            userCubit: userCubit,
            backgroundImage: null,
            isForce: true,
            fromOverlay: false,
          ),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/core/constants/assets.dart';
import 'package:lklk/features/profile_users/domain/entities/post_charger_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/post_charger/post_charger_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'post_charger_item.dart';

class PostChargersPage extends StatelessWidget {
  const PostChargersPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.whiteIcon,
        body: SafeArea(
          child: BlocProvider<PostChargerCubit>(
            lazy: true,
            create: (context) => PostChargerCubit()..fetchUsers(),
            child: BlocBuilder<PostChargerCubit, PostChargerState>(
              builder: (context, state) {
                if (state.users != null) {
                  return ListView.builder(
                    cacheExtent: 300,
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: true,
                    addSemanticIndexes: false,
                    itemCount: state.users?.length ?? 0,
                    itemBuilder: (context, index) => RepaintBoundary(
                      child: PostChargerItem(
                        user: state.users![index],
                      ),
                    ),
                  );
                } else if (state.status == PostChargerStatus.initial ||
                    state.status == PostChargerStatus.loading) {
                  return ListView.builder(
                    cacheExtent: 300,
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: true,
                    addSemanticIndexes: false,
                    itemCount: 5,
                    itemBuilder: (context, index) => RepaintBoundary(
                      child: TickerMode(
                        enabled: false,
                        child: Skeletonizer(
                          child: PostChargerItem(
                            user: PostCharger(
                                id: 123413,
                                name: "namenamenamenamename",
                                wallet: 00000000000000,
                                country: 'sy',
                                img: AssetsData.userTestNetwork,
                                number: "8917234987928743"),
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (state.status == PostChargerStatus.error) {
                  return Center(child: AutoSizeText(state.errorMessage ?? ""));
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

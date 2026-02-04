import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/elements/elements_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/elements/elements_state.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/store_dialog.dart';

import 'store_item_card_element.dart';

class ElementsOnlinePage extends StatelessWidget {
  const ElementsOnlinePage(
      {super.key,
      this.selectedIndex,
      required this.onTap,
      required this.user,
      required this.updateSelectedItemId});
  final int? selectedIndex;
  final Function(int) onTap;
  final UserEntity user;
  final Function(int) updateSelectedItemId;
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ElementsCubit>(
      lazy: true,
      create: (context) => ElementsCubit()..fetchElements(),
      child: BlocBuilder<ElementsCubit, ElementsState>(
        builder: (context, state) {
          if (state is ElementsLoaded) {
            return GridView.builder(
              itemCount: state.elements.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 160,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.59,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              cacheExtent: 300,
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
              addSemanticIndexes: false,
              itemBuilder: (context, index) {
                final element = state.elements[index];
                return RepaintBoundary(
                  child: StoreItemCardElement(
                  name: element.elementName ?? '',
                  image: element.imgElementLocal ?? element.imgElement ?? '',
                  price: element.price ?? "0",
                  period: element.date ?? 0,
                  still: element.still,

                  isSelected: index == selectedIndex,
                  // isLocal: true,
                  buy: element.buy ?? true,
                  index: index,
                  onTap: () {
                    onTap(index); // Pass the index to the onTap callback
                    updateSelectedItemId(element.id ?? 10);
                  },
                  //  onTap: () {
                  icononTap: () {
                    element.type == 'entry'
                        ? showDialog(
                            context: context,
                            useSafeArea: true,
                            builder: (context) => SafeArea(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context)
                                      .viewPadding
                                      .bottom,
                                ),
                                child: CustomSVGAWidget(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  isRepeat: true,
                                  pathOfSvgaFile: SvgaUtils.getValidFilePath(
                                          element.elamentId.toString()) ??
                                      element.linkPathLocal ??
                                      element.linkPath!,
                                ),
                              ),
                            ))
                        : showDialog(
                            context: context,
                            builder: (context) => StoreDialog(
                              image: SvgaUtils.getValidFilePath(
                                      element.elamentId.toString()) ??
                                  element.linkPathLocal ??
                                  element.linkPath,
                              type: element.type ?? "",
                              user: user,
                            ),
                          );
                  },
                ),
              );
              },
            );
          } else if (state is ElementsLoading) {
            return Center(
              child: AutoSizeText(state.toString()),
            );
          } else if (state is ElementsError) {
            return Center(
              child: AutoSizeText(state.message),
            );
          } else {
            return Center(
              child: AutoSizeText(state.toString()),
            );
          }
        },
      ),
    );
  }
}

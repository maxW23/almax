import 'package:lklk/core/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/profile_users/presentaion/manger/fetch_elements_cubit/fetch_elements_cubit.dart';
import 'package:lklk/features/profile_users/presentaion/manger/fetch_elements_cubit/fetch_elements_cubit_state.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/cupboard_bottom_navigation_bar.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/store_dialog.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/store_item_card_element.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/store_profile_view.dart';

import '../../../../../core/player/svga_custom_player.dart';

class CupboardPageStore extends StatelessWidget {
  final List<ElementEntity> myElements;
  final int? selectedIndex;
  final Function(int) onTap;
  final UserEntity user;
  final Function(int) updateSelectedItemId;
  final StoreProfileView widget;
  final int? selectedItemId;
  final String elementType; // Add this to filter by type

  const CupboardPageStore({
    super.key,
    this.selectedIndex,
    required this.onTap,
    required this.user,
    required this.updateSelectedItemId,
    required this.widget,
    this.selectedItemId,
    required this.elementType,
    required this.myElements,
  });

  @override
  Widget build(BuildContext context) {
    log('CupboardPageStore');

    final FetchElementsCubit fetchElementsCubit =
        BlocProvider.of<FetchElementsCubit>(context);

    return BlocBuilder<FetchElementsCubit, FetchElementsCubitState>(
      bloc: fetchElementsCubit,
      builder: (context, state) {
        final filteredElements =
            myElements.where((element) => element.type == elementType).toList();

        bool isArabic() => Directionality.of(context) == TextDirection.rtl ||
            Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
        final requiresRoom = elementType == 'room_icon' ||
            elementType == 'room_background' ||
            elementType == 'room_color' ||
            elementType == 'room_frame';

        if (requiresRoom && state.message == 'no_room') {
          // Empty state: user doesn't own a room
          final msg = isArabic()
              ? 'يجب عليك إنشاء غرفة أولاً'
              : 'You need to create a room first';
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.meeting_room_outlined,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 10),
                Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: filteredElements.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.56,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                cacheExtent: 300,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                addSemanticIndexes: false,
                itemBuilder: (context, index) {
                  final element = filteredElements[index];
                  return RepaintBoundary(
                    child: StoreItemCardElement(
                    name: element.elementName ?? '',
                    image: element.imgElementLocal ?? element.imgElement,
                    price: element.price ?? "0",
                    period: element.date ?? 0,
                    isSelected: index == selectedIndex,
                    still: element.still,
                    // isLocal: true,
                    buy: element.buy ?? true,
                    cupborad: true,
                    index: index,
                    onTap: () {
                      onTap(index); // Pass the index to the onTap callback
                      updateSelectedItemId(element.id ?? 10);
                    },
                    icononTap: () {
                      element.type == 'entry'
                          ? showDialog(
                              context: context,
                              builder: (context) => CustomSVGAWidget(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  isRepeat: true,
                                  pathOfSvgaFile: SvgaUtils.getValidFilePath(
                                          element.elamentId.toString()) ??
                                      element.linkPathLocal ??
                                      element.linkPath!))
                          : showDialog(
                              context: context,
                              builder: (context) => StoreDialog(
                                image: SvgaUtils.getValidFilePath(
                                        element.elamentId.toString()) ??
                                    element.linkPathLocal ??
                                    element.linkPath!,
                                type: element.type!,
                                user: user,
                              ),
                            );
                    },
                  ));
                },
              ),
            ),
            CupboardBottomNavigationbar(
              widget: widget,
              selectedItemId: selectedItemId,
              fetchElementsCubit: fetchElementsCubit,
            ),
          ],
        );
      },
    );
  }
}

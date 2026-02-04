import 'package:flutter/material.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/store_dialog.dart';
import 'package:lklk/features/profile_users/presentaion/views/widgets/store_item_card_element.dart';

class ElementsLocalPage extends StatelessWidget {
  final List<ElementEntity> elements;
  final int? selectedIndex;
  final Function(int) onTap;
  final UserEntity user;
  final Function(int) updateSelectedItemId;
  const ElementsLocalPage({
    super.key,
    required this.elements,
    required this.selectedIndex,
    required this.onTap,
    required this.user,
    required this.updateSelectedItemId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GridView.builder(
        itemCount: elements.length,
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
          return RepaintBoundary(
            child: StoreItemCardElement(
            name: elements[index].elementName ?? "",
            image:
                elements[index].imgElementLocal ?? elements[index].imgElement,
            period: elements[index].date ?? "",
            still: elements[index].still,
            price: elements[index].price ?? "",
            buy: elements[index].buy ?? true,
            isSelected: index == selectedIndex,
            // svga: elements[index].link!,
            index: index,
            // onTap: () {
            //   onTap(index);
            // },
            onTap: () {
              onTap(index);

              updateSelectedItemId(elements[index].id ?? 12);
            },
            icononTap: () {
              elements[index].type == 'entry'
                  ? showDialog(
                      context: context,
                      useSafeArea: true,
                      builder: (context) => SafeArea(
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewPadding.bottom,
                              ),
                              child: CustomSVGAWidget(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                isRepeat: true,
                                pathOfSvgaFile: SvgaUtils.getValidFilePath(
                                        elements[index]
                                            .elamentId
                                            .toString()) ??
                                    elements[index].linkPathLocal ??
                                    elements[index].linkPath!,
                              ),
                            ),
                          ))
                  : showDialog(
                      context: context,
                      builder: (context) => StoreDialog(
                        image: SvgaUtils.getValidFilePath(
                                elements[index].elamentId.toString()) ??
                            elements[index].linkPathLocal ??
                            elements[index].linkPath!,
                        type: elements[index].type!,
                        user: user,
                      ),
                    );
            },
          ));
        },
      ),
    );
  }
}

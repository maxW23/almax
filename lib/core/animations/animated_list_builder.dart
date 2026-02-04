import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AnimatedListBuilder extends StatelessWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext, int) itemBuilder;
  final Duration animationDuration;
  final double horizontalOffset;
  final double verticalOffset;

  const AnimatedListBuilder({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.animationDuration = const Duration(milliseconds: 500),
    this.horizontalOffset = 50.0,
    this.verticalOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: animationDuration,
            child: SlideAnimation(
              horizontalOffset: horizontalOffset,
              verticalOffset: verticalOffset,
              child: FadeInAnimation(
                child: itemBuilder(context, index),
              ),
            ),
          );
        },
      ),
    );
  }
}
/*
AnimatedListBuilder(
  items: myItems, // Replace with your list of items
  itemBuilder: (context, index) {
    final item = myItems[index];
    return ListTile(
      title: AutoSizeText(item.name),
    );
  },
)

AnimatedListBuilder(
  items: myItems,
  itemBuilder: (context, index) {
    final item = myItems[index];
    return ListTile(
      title: AutoSizeText(item.name),
    );
  },
  animationDuration: Duration(milliseconds: 600),
  horizontalOffset: 100.0,
  verticalOffset: 20.0,
)

*/

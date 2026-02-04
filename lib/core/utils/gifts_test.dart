import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/player/svga_custom_player.dart';
import 'package:lklk/core/utils/functions/file_utils.dart';
import 'package:lklk/core/widgets/entry_svga_elements.dart';

class GiftsTest extends StatelessWidget {
  const GiftsTest({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Center(
          child: ListView.builder(
            itemCount: entryElements.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    children: [
                      CustomSVGAWidget(
                        height: 100,
                        width: double.infinity,
                        isRepeat: true,
                        pathOfSvgaFile: SvgaUtils.getValidFilePath(
                                entryElements[index].elamentId.toString()) ??
                            entryElements[index].linkPathLocal ??
                            entryElements[index].linkPath!,
                      ),
                      const SizedBox(
                        height: 120,
                      ),
                      AutoSizeText(
                        '${entryElements[index].elementName}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      AutoSizeText(
                        '${entryElements[index].price}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      AutoSizeText(
                        '${entryElements[index].type}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// class AnimatedEmojisPage extends StatelessWidget {
//   const AnimatedEmojisPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const AutoSizeText('Animated Emoji')),
//       body:  Center(
//         child: GridView.builder(
//           itemCount: 20,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//           itemBuilder: (context, index) {

//             return  AnimatedEmoji(
//               AnimatedEmojis
//                   .dizzyFace, //anguished // angry //anxiousWithSweat //astonished//bandageFace

//               //bigFrown // blush//brokenHeart//collision//concerned//confettiBall
//               //cowboy//clap//cursing//cry
//               //
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// /// Demo widget that demonstrates how to use [AnimationController] with [AnimatedEmoji].
// class DemoHoverEmoji extends StatefulWidget {
//   /// Demo widget that demonstrates how to use [AnimationController] with [AnimatedEmoji].
//   const DemoHoverEmoji({super.key});

//   @override
//   State<DemoHoverEmoji> createState() => _DemoHoverEmojiState();
// }

// class _DemoHoverEmojiState extends State<DemoHoverEmoji>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = AnimationController(
//       vsync: this,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       onEnter: (event) {
//         controller.forward(from: 0);
//       },
//       child: AnimatedEmoji(
//         AnimatedEmojis.brokenHeart,
//         controller: controller,
//         size: 128,
//         onLoaded: (duration) {
//           // Get the duration of the animation.
//           controller.duration = duration;
//         },
//       ),
//     );
//   }
// }

// /// Showcases advanced usage of animated emojis.
// class AdvancedUsageEmojis extends StatelessWidget {
//   const AdvancedUsageEmojis({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         AnimatedEmoji(
//           AnimatedEmojis.fromId('1f386'),
//         ),
//         AnimatedEmoji(
//           AnimatedEmojis.fromEmojiString('❤️')!,
//         ),
//         Builder(
//           builder: (context) {
//             // Get an emoji from name.
//             final emoji = AnimatedEmojis.fromName('victory');

//             // Check if the emoji supports skin tones.
//             return AnimatedEmoji(
//               emoji.hasSkinTones
//                   ? (emoji as AnimatedTonedEmojiData).mediumLight
//                   : emoji,
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

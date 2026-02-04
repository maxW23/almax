// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
// import 'package:lklk/core/constants/assets.dart';
// import 'package:lklk/core/player/svga_custom_player.dart';
// import 'package:lklk/core/widgets/files_elemnts.dart';
// import 'package:lklk/core/widgets/gifts_svga_elements_data.dart';

// class FilesTest extends StatelessWidget {
//   const FilesTest({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//           child: CustomSVGAWidget(
//         height: 80,
//         width: double.infinity,
//         pathOfSvgaFile: AssetsData.vip5SvgaName,
//         allowDrawingOverflow: true,
//         clearsAfterStop: true,
//         fit: BoxFit.cover,
//         isRepeat: true,
//       )
//           // ListView.separated(
//           //   separatorBuilder: (context, index) => const SizedBox(
//           //     height: 40,
//           //   ),
//           //   itemCount: giftsSVGAElements.length,
//           //   itemBuilder: (context, index) {
//           //     return Padding(
//           //       padding: const EdgeInsets.all(8.0),
//           //       child: Center(
//           //         child: Column(
//           //           children: [
//           //             CustomSVGAWidget(
//           //               height: 100,
//           //               width: double.infinity,
//           //               isRepeat: true,
//           //               pathOfSvgaFile: giftsSVGAElements[index].linkPath!,
//           //             ),
//           //             const SizedBox(
//           //               height: 120,
//           //             ),
//           //             AutoSizeText(
//           //               '${giftsSVGAElements[index].elementName}',
//           //               style: const TextStyle(color: Colors.black, fontSize: 22),
//           //             ),
//           //             AutoSizeText(
//           //               '${giftsSVGAElements[index].price}',
//           //               style: const TextStyle(color: Colors.black, fontSize: 22),
//           //             ),
//           //             AutoSizeText(
//           //               '${giftsSVGAElements[index].type}',
//           //               style: const TextStyle(color: Colors.black, fontSize: 22),
//           //             ),
//           //             const SizedBox(
//           //               height: 40,
//           //             ),
//           //           ],
//           //         ),
//           //       ),
//           //     );
//           //   },
//           // ),
//           ),
//     );
//   }
// }

// //  'assets/files/music box.svga',
// //       'assets/files/Mermaid(1).svga',
// //       'assets/files/love swan.svga',
// //       'assets/files/istana_.svga',
// //       'assets/files/ice house.svga',
// //       'assets/files/hummer_.svga',
// //       'assets/files/bugatti.svga',
// //       'assets/files/bmw i8.svga',
// //       'assets/files/yellow car.svga',
// //       'assets/files/airship.svga',
// //       'assets/files/bear_.svga',
// //       'assets/files/black car.svga',
// //       'assets/files/blue car.svga',
// //       'assets/files/car2_040.svga',
// //       'assets/files/cars n monster.svga',
// //       'assets/files/car_.svga',
// //       'assets/files/car_0.svga',
// //       'assets/files/castil girl .svga',
// //       'assets/files/castle.svga',
// //       'assets/files/classic car.svga',
// //       'assets/files/cruise.svga',
// //       'assets/files/customer service(2).svga',
// //       'assets/files/customer service(3).svga',
// //       'assets/files/dagger(1).svga',
// //       'assets/files/diamond(1).svga',
// //       'assets/files/dragon frame.svga',
// //       'assets/files/dragon ice .svga',
// //       'assets/files/dragon(1).svga',
// //       'assets/files/dragon(2).svga',
// //       'assets/files/elang_.svga',
// //       'assets/files/fire phoenic.svga',
// //       'assets/files/firebird_.svga',
// //       'assets/files/frame 10.svga',
// //       'assets/files/frame 11.svga',
// //       'assets/files/frame 12.svga',
// //       'assets/files/frame 13.svga',
// //       'assets/files/frame 14.svga',
// //       'assets/files/frame 5.svga',
// //       'assets/files/frame 6.svga',
// //       'assets/files/frame 7.svga',
// //       'assets/files/frame 8.svga',
// //       'assets/files/frame 9.svga',
// //       'assets/files/frame_2(1).svga',
// //       'assets/files/ghost_.svga',
// //       'assets/files/gold car 3d.svga',
// //       'assets/files/gold car com.svga',
// //       'assets/files/gold star frame rev3.svga',
// //       'assets/files/gunung_.svga',
// //       'assets/files/halloween.svga',
// //       'assets/files/helicopter(1).svga',
// //       'assets/files/helicopter(2).svga',
// //       'assets/files/helicopter.svga',
// //       'assets/files/kapal finish.svga',
// //       'assets/files/king.svga',
// //       'assets/files/knight(1).svga',
// //       'assets/files/kursi raja_.svga',
// //       'assets/files/love castle.svga',
// //       'assets/files/love plane.svga',
// //       'assets/files/naga1_.svga',
// //       'assets/files/naga2_.svga',
// //       'assets/files/official 2.svga',
// //       'assets/files/official.svga',
// //       'assets/files/orange lambo.svga',
// //       'assets/files/panter_.svga',
// //       'assets/files/phoenix_.svga',
// //       'assets/files/pink car_2.svga',
// //       'assets/files/pink castle.svga',
// //       'assets/files/piramida_.svga',
// //       'assets/files/plane1.svga',
// //       'assets/files/rafce car.svga',
// //       'assets/files/red car (1).svga',
// //       'assets/files/red car.svga',
// //       'assets/files/red ferarri.svga',
// //       'assets/files/river house.svga',
// //       'assets/files/robot.svga',
// //       'assets/files/robot_.svga',
// //       'assets/files/rock india 2.svga',
// //       'assets/files/rock india.svga',
// //       'assets/files/rock official.svga',
// //       'assets/files/rock.svga',
// //       'assets/files/rocket2.svga',
// //       'assets/files/sad girl.svga',
// //       'assets/files/snow house .svga',
// //       'assets/files/space ship.svga',
// //       'assets/files/spacecraft(1).svga',
// //       'assets/files/spaceship_.svga',
// //       'assets/files/ufo.svga',
// //       'assets/files/villa com.svga',
// //       'assets/files/yacht_2.svga',
// // class AnimatedEmojisPage extends StatelessWidget {
// //   const AnimatedEmojisPage({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const AutoSizeText('Animated Emoji')),
// //       body:  Center(
// //         child: GridView.builder(
// //           itemCount: 20,
// //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
// //           itemBuilder: (context, index) {

// //             return  AnimatedEmoji(
// //               AnimatedEmojis
// //                   .dizzyFace, //anguished // angry //anxiousWithSweat //astonished//bandageFace

// //               //bigFrown // blush//brokenHeart//collision//concerned//confettiBall
// //               //cowboy//clap//cursing//cry
// //               //
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }
// // }

// // /// Demo widget that demonstrates how to use [AnimationController] with [AnimatedEmoji].
// // class DemoHoverEmoji extends StatefulWidget {
// //   /// Demo widget that demonstrates how to use [AnimationController] with [AnimatedEmoji].
// //   const DemoHoverEmoji({super.key});

// //   @override
// //   State<DemoHoverEmoji> createState() => _DemoHoverEmojiState();
// // }

// // class _DemoHoverEmojiState extends State<DemoHoverEmoji>
// //     with SingleTickerProviderStateMixin {
// //   late final AnimationController controller;

// //   @override
// //   void initState() {
// //     super.initState();
// //     controller = AnimationController(
// //       vsync: this,
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return MouseRegion(
// //       onEnter: (event) {
// //         controller.forward(from: 0);
// //       },
// //       child: AnimatedEmoji(
// //         AnimatedEmojis.brokenHeart,
// //         controller: controller,
// //         size: 128,
// //         onLoaded: (duration) {
// //           // Get the duration of the animation.
// //           controller.duration = duration;
// //         },
// //       ),
// //     );
// //   }
// // }

// // /// Showcases advanced usage of animated emojis.
// // class AdvancedUsageEmojis extends StatelessWidget {
// //   const AdvancedUsageEmojis({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         AnimatedEmoji(
// //           AnimatedEmojis.fromId('1f386'),
// //         ),
// //         AnimatedEmoji(
// //           AnimatedEmojis.fromEmojiString('❤️')!,
// //         ),
// //         Builder(
// //           builder: (context) {
// //             // Get an emoji from name.
// //             final emoji = AnimatedEmojis.fromName('victory');

// //             // Check if the emoji supports skin tones.
// //             return AnimatedEmoji(
// //               emoji.hasSkinTones
// //                   ? (emoji as AnimatedTonedEmojiData).mediumLight
// //                   : emoji,
// //             );
// //           },
// //         ),
// //       ],
// //     );
// //   }
// // }

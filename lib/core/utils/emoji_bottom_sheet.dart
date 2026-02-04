import 'dart:convert';
import 'package:lklk/core/utils/logger.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/constants/app_colors.dart';

import 'package:lklk/core/utils/list_emoji.dart';
import 'package:lklk/features/room/presentation/manger/emoji_cubit/emoji_cubit.dart';

import 'package:lklk/live_audio_room_manager.dart';
import 'package:lklk/zego_sdk_manager.dart';

class EmojiBottomSheetWidget extends StatefulWidget {
  const EmojiBottomSheetWidget({
    super.key,
    required this.roomId,
  });
  final String roomId;
  @override
  State<EmojiBottomSheetWidget> createState() => _EmojiBottomSheetWidgetState();

  static Future<void> showBasicModalBottomSheet(
    BuildContext context,
    String roomId,
  ) async {
    final emojiPrivateCubit = BlocProvider.of<EmojiPrivateCubit>(context);

    showModalBottomSheet(
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      backgroundColor: AppColors.darkColor,
      context: context,
      builder: (BuildContext context) {
        return BlocProvider.value(
          value: emojiPrivateCubit,
          child: EmojiBottomSheetWidget(
            roomId: roomId,
          ),
        );
      },
    );
  }
}

class _EmojiBottomSheetWidgetState extends State<EmojiBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              // itemCount: emojiList.length,
              itemCount: emojiEntitiesGif.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                // final emojiName = emojiGIFList[index];/////////
                // final emojiName = emojiList[index];
                final emoji = emojiEntitiesGif[index];
                final emojiPath = emoji.path;
                // final emoji = emojiEntities[index];
                return GestureDetector(
                  onTap: () async {
                    final emojiName = emoji.name;
                    final emojiCubit = context.read<EmojiPrivateCubit>();
                    final navigator = Navigator.of(context);

                    final signaling = jsonEncode({
                      'type': 'emoji',
                      'content': emojiName,
                      'senderID': ZEGOSDKManager.instance.currentUser!.iduser,
                      'timestamp': DateTime.now()
                          .millisecondsSinceEpoch, // Add the timestamp here
                      // 'receiver_id': ZEGOSDKManager
                      //     .instance.currentUser!.userID,
                    });

                    // ignore: unused_local_variable
                    final ZIMMessageSentResult result = await ZIM
                        .getInstance()!
                        .sendMessage(
                          ZIMCommandMessage(
                            message: Uint8List.fromList(utf8.encode(signaling)),
                          ),
                          widget.roomId,
                          ZIMConversationType.room,
                          ZIMMessageSendConfig(),
                        );

                    log('~~~~~~~~~~~~~~~~ sendRoomCommand ${result.message} ${result.message.messageID} with emoji: $emojiName  senderID: ${ZEGOSDKManager.instance.currentUser!.iduser} signaling $signaling  ');
                    emojiCubit.selectEmojiPrivate(emoji.path,
                        ZEGOSDKManager.instance.currentUser!.iduser);

                    navigator.pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Center(
                      child: emoji.id == 1036
                          ? Image.asset(
                              emojiPath, height: 75, width: 75,
                              fit: BoxFit.cover,
                              // repeat: ImageRepeat.repeat,
                            )
                          : Image.asset(
                              emojiPath, height: 50, width: 50,
                              fit: BoxFit.cover,
                              // repeat: ImageRepeat.repeat,
                            ),
                      // AnimatedEmoji(
                      //   emojiName,
                      //   size: 50,
                      //   animate: false,
                      //   repeat: false,
                      // ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
// final List<AnimatedEmojiData> emojiList = [
//   AnimatedEmojis.smile,
//   AnimatedEmojis.smileWithBigEyes,
//   AnimatedEmojis.grin,
//   AnimatedEmojis.grinning,
//   AnimatedEmojis.laughing,
//   AnimatedEmojis.grinSweat,
//   AnimatedEmojis.joy,
//   AnimatedEmojis.rofl,
//   AnimatedEmojis.loudlyCrying,
//   AnimatedEmojis.wink,
//   AnimatedEmojis.kissing,
//   AnimatedEmojis.kissingSmilingEyes,
// ];
// class EmojiBottomSheetWidget extends StatefulWidget {
//   const EmojiBottomSheetWidget({
//     super.key,
//   });

//   @override
//   State<EmojiBottomSheetWidget> createState() =>
//       _CustomBottomSheetWidgetState();

//   static Future<void> showBasicModalBottomSheet(
//     BuildContext context,
//   ) async {
//     showModalBottomSheet(
//  barrierColor: Colors.transparent,
//       isScrollControlled: true,
//       backgroundColor: AppColors.darkColor.withValues(alpha: .6),
//       context: context,
//       builder: (BuildContext context) {
//         return const EmojiBottomSheetWidget();
//       },
//     );
//   }
// }

// class _CustomBottomSheetWidgetState extends State<EmojiBottomSheetWidget> {
//   int? selectedIndex;
//   int? selectedItemId;
//   bool isScrollable = false;
//   bool showNextIcon = true;
//   bool showBackIcon = true;
//   void updateSelectedItemId(int itemId) {
//     setState(() {
//       selectedItemId = itemId;
//     });
//   }

//   final List<AnimatedEmojiData> emojiList = [
//     AnimatedEmojis.smile,
//     AnimatedEmojis.smileWithBigEyes,
//     AnimatedEmojis.grin,
//     AnimatedEmojis.grinning,
//     AnimatedEmojis.laughing,
//     AnimatedEmojis.grinSweat,
//     AnimatedEmojis.joy,
//     AnimatedEmojis.rofl,
//     AnimatedEmojis.loudlyCrying,
//     AnimatedEmojis.wink,
//     AnimatedEmojis.kissing,
//     AnimatedEmojis.kissingSmilingEyes,

//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//       ),
//       height: 500,
//       child: Column(
//         children: [
//           Expanded(
//             child: GridView.builder(
//               itemCount: emojiList.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 4,
//               ),
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 4,
//                   ),
//                   child: Center(
//                     child: AnimatedEmoji(
//                       emojiList[index],
//                       size: 80,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
/**
 AnimatedEmojis.kissingClosedEyes,
    AnimatedEmojis.kissingHeart,
    AnimatedEmojis.heartFace,
    AnimatedEmojis.heartEyes,
    AnimatedEmojis.starStruck,
    AnimatedEmojis.partyingFace,
    AnimatedEmojis.melting,
    AnimatedEmojis.upsideDownFace,
    AnimatedEmojis.slightlyHappy,
    AnimatedEmojis.happyCry,
    AnimatedEmojis.holdingBackTears,
    AnimatedEmojis.blush,
    AnimatedEmojis.warmSmile,
    AnimatedEmojis.relieved,
    AnimatedEmojis.smirk,
    AnimatedEmojis.drool,
    AnimatedEmojis.yum,
    AnimatedEmojis.stuckOutTongue,
    AnimatedEmojis.squintingTongue,
    AnimatedEmojis.winkyTongue,
    AnimatedEmojis.zanyFace,
    AnimatedEmojis.woozy,
    AnimatedEmojis.pensive,
    AnimatedEmojis.pleading,
    AnimatedEmojis.grimacing,
    AnimatedEmojis.expressionless,
    AnimatedEmojis.neutralFace,
    AnimatedEmojis.mouthNone,
    AnimatedEmojis.faceInClouds,
    AnimatedEmojis.dottedLineFace,
    AnimatedEmojis.zipperFace,
    AnimatedEmojis.salute,
    AnimatedEmojis.thinkingFace,
    AnimatedEmojis.shushingFace,
    AnimatedEmojis.handOverMouth,
    AnimatedEmojis.smilingEyesWithHandOverMouth,
    AnimatedEmojis.yawn,
    AnimatedEmojis.hugFace,
    AnimatedEmojis.peeking,
    AnimatedEmojis.screaming,
    AnimatedEmojis.raisedEyebrow,
    AnimatedEmojis.monocle,
    AnimatedEmojis.unamused,
    AnimatedEmojis.rollingEyes,
    AnimatedEmojis.exhale,
    AnimatedEmojis.triumph,
    AnimatedEmojis.angry,
    AnimatedEmojis.rage,
    AnimatedEmojis.cursing,
    AnimatedEmojis.sad,
    AnimatedEmojis.sweat,
    AnimatedEmojis.worried,
    AnimatedEmojis.concerned,
    AnimatedEmojis.cry,
    AnimatedEmojis.bigFrown,
    AnimatedEmojis.frown,
    AnimatedEmojis.diagonalMouth,
    AnimatedEmojis.slightlyFrowning,
    AnimatedEmojis.anxiousWithSweat,
    AnimatedEmojis.scared,
    AnimatedEmojis.anguished,
    AnimatedEmojis.gasp,
    AnimatedEmojis.mouthOpen,
    AnimatedEmojis.surprised,
    AnimatedEmojis.astonished,
    AnimatedEmojis.flushed,
    AnimatedEmojis.mindBlown,
    AnimatedEmojis.scrunchedMouth,
    AnimatedEmojis.scrunchedEyes,
    AnimatedEmojis.weary,
    AnimatedEmojis.distraught,
    AnimatedEmojis.xEyes,
    AnimatedEmojis.dizzyFace,
    AnimatedEmojis.shakingFace,
    AnimatedEmojis.coldFace,
    AnimatedEmojis.hotFace,
    AnimatedEmojis.sick,
    AnimatedEmojis.vomit,
    AnimatedEmojis.sleep,
    AnimatedEmojis.sleepy,
    AnimatedEmojis.sneeze,
    AnimatedEmojis.thermometerFace,
    AnimatedEmojis.bandageFace,
    AnimatedEmojis.mask,
    AnimatedEmojis.liar,
    AnimatedEmojis.halo,
    AnimatedEmojis.cowboy,
    AnimatedEmojis.moneyFace,
    AnimatedEmojis.nerdFace,
    AnimatedEmojis.sunglassesFace,
    AnimatedEmojis.disguise,
    AnimatedEmojis.clown,
    AnimatedEmojis.impSmile,
    AnimatedEmojis.impFrown,
    AnimatedEmojis.ghost,
    AnimatedEmojis.skull,
    AnimatedEmojis.jackOLantern,
    AnimatedEmojis.poop,
    AnimatedEmojis.robot,
    AnimatedEmojis.alien,
    AnimatedEmojis.sunWithFace,
    AnimatedEmojis.moonFaceFirstQuarter,
    AnimatedEmojis.moonFaceLastQuarter,
    AnimatedEmojis.seeNoEvilMonkey,
    AnimatedEmojis.hearNoEvilMonkey,
    AnimatedEmojis.speakNoEvilMonkey,
    AnimatedEmojis.smileyCat,
    AnimatedEmojis.smileCat,
    AnimatedEmojis.joyCat,
    AnimatedEmojis.heartEyesCat,
    AnimatedEmojis.smirkCat,
    AnimatedEmojis.kissingCat,
    AnimatedEmojis.screamCat,
    AnimatedEmojis.cryingCatFace,
    AnimatedEmojis.poutingCat,
    AnimatedEmojis.glowingStar,
    AnimatedEmojis.sparkles,
    AnimatedEmojis.collision,
    AnimatedEmojis.fire,
    AnimatedEmojis.oneHundred,
    AnimatedEmojis.partyPopper,
    AnimatedEmojis.redHeart,
    AnimatedEmojis.orangeHeart,
    AnimatedEmojis.yellowHeart,
    AnimatedEmojis.greenHeart,
    AnimatedEmojis.lightBlueHeart,
    AnimatedEmojis.blueHeart,
    AnimatedEmojis.purpleHeart,
    AnimatedEmojis.brownHeart,
    AnimatedEmojis.blackHeart,
    AnimatedEmojis.greyHeart,
    AnimatedEmojis.whiteHeart,
    AnimatedEmojis.pinkHeart,
    AnimatedEmojis.cupid,
    AnimatedEmojis.giftHeart,
    AnimatedEmojis.sparklingHeart,
    AnimatedEmojis.heartGrow,
    AnimatedEmojis.beatingHeart,
    AnimatedEmojis.revolvingHearts,
    AnimatedEmojis.twoHearts,
    AnimatedEmojis.loveLetter,
    AnimatedEmojis.heartBox,
    AnimatedEmojis.heartExclamationPoint,
    AnimatedEmojis.bandagedHeart,
    AnimatedEmojis.brokenHeart,
    AnimatedEmojis.fireHeart,
    AnimatedEmojis.kiss,
    AnimatedEmojis.footprints,
    AnimatedEmojis.anatomicalHeart,
    AnimatedEmojis.blood,
    AnimatedEmojis.microbe,
    AnimatedEmojis.eyes,
    AnimatedEmojis.eye,
    AnimatedEmojis.bitingLip,
    AnimatedEmojis.legMechanical,
    AnimatedEmojis.armMechanical,
    AnimatedEmojis.muscle,
    AnimatedEmojis.clap,
    AnimatedEmojis.thumbsUp,
    AnimatedEmojis.thumbsDown,
    AnimatedEmojis.raisingHands,
    AnimatedEmojis.wave,
    AnimatedEmojis.victory,
    AnimatedEmojis.crossedFingers,
    AnimatedEmojis.indexFinger,
    AnimatedEmojis.foldedHands,
    AnimatedEmojis.dancerWoman,
    AnimatedEmojis.rose,
    AnimatedEmojis.wiltedFlower,
    AnimatedEmojis.fallenLeaf,
    AnimatedEmojis.plant,
    AnimatedEmojis.leaves,
    AnimatedEmojis.luck,
    AnimatedEmojis.snowflake,
    AnimatedEmojis.volcano,
    AnimatedEmojis.sunrise,
    AnimatedEmojis.sunriseOverMountains,
    AnimatedEmojis.rainbow,
    AnimatedEmojis.bubbles,
    AnimatedEmojis.ocean,
    AnimatedEmojis.windFace,
    AnimatedEmojis.tornado,
    AnimatedEmojis.electricity,
    AnimatedEmojis.droplet,
    AnimatedEmojis.rainCloud,
    AnimatedEmojis.cloudWithLightning,
    AnimatedEmojis.dizzy,
    AnimatedEmojis.comet,
    AnimatedEmojis.globeShowingEuropeAfrica,
    AnimatedEmojis.globeShowingAmericas,
    AnimatedEmojis.globeShowingAsiaAustralia,
    AnimatedEmojis.cowFace,
    AnimatedEmojis.unicorn,
    AnimatedEmojis.lizard,
    AnimatedEmojis.dragon,
    AnimatedEmojis.tRex,
    AnimatedEmojis.dinosaur,
    AnimatedEmojis.turtle,
    AnimatedEmojis.crocodile,
    AnimatedEmojis.snake,
    AnimatedEmojis.frog,
    AnimatedEmojis.rabbit,
    AnimatedEmojis.rat,
    AnimatedEmojis.poodle,
    AnimatedEmojis.dog,
    AnimatedEmojis.guideDog,
    AnimatedEmojis.serviceDog,
    AnimatedEmojis.pig,
    AnimatedEmojis.racehorse,
    AnimatedEmojis.donkey,
    AnimatedEmojis.ox,
    AnimatedEmojis.goat,
    AnimatedEmojis.kangaroo,
    AnimatedEmojis.tiger,
    AnimatedEmojis.monkey,
    AnimatedEmojis.gorilla,
    AnimatedEmojis.orangutan,
    AnimatedEmojis.chipmunk,
    AnimatedEmojis.otter,
    AnimatedEmojis.bat,
    AnimatedEmojis.bird,
    AnimatedEmojis.blackBird,
    AnimatedEmojis.rooster,
    AnimatedEmojis.hatchingChick,
    AnimatedEmojis.babyChick,
    AnimatedEmojis.hatchedChick,
    AnimatedEmojis.eagle,
    AnimatedEmojis.peace,
    AnimatedEmojis.goose,
    AnimatedEmojis.peacock,
    AnimatedEmojis.seal,
    AnimatedEmojis.shark,
    AnimatedEmojis.dolphin,
    AnimatedEmojis.whale,
    AnimatedEmojis.blowfish,
    AnimatedEmojis.crab,
    AnimatedEmojis.octopus,
    AnimatedEmojis.jellyfish,
    AnimatedEmojis.spider,
    AnimatedEmojis.snail,
    AnimatedEmojis.ant,
    AnimatedEmojis.mosquito,
    AnimatedEmojis.mosquito,
    AnimatedEmojis.cockroach,
    AnimatedEmojis.fly,
    AnimatedEmojis.bee,
    AnimatedEmojis.ladyBug,
    AnimatedEmojis.butterfly,
    AnimatedEmojis.bug,
    AnimatedEmojis.worm,
    AnimatedEmojis.pawPrints,
    AnimatedEmojis.tomato,
    AnimatedEmojis.cooking,
    AnimatedEmojis.spaghetti,
    AnimatedEmojis.steamingBowl,
    AnimatedEmojis.popcorn,
    AnimatedEmojis.hotBeverage,
    AnimatedEmojis.clinkingBeerMugs,
    AnimatedEmojis.clinkingGlasses,
    AnimatedEmojis.bottleWithPoppingCork,
    AnimatedEmojis.wineGlass,
    AnimatedEmojis.tropicalDrink,
    AnimatedEmojis.construction,
    AnimatedEmojis.policeCarLight,
    AnimatedEmojis.bicycle,
    AnimatedEmojis.flyingSaucer,
    AnimatedEmojis.rocket,
    AnimatedEmojis.airplaneDeparture,
    AnimatedEmojis.airplaneArrival,
    AnimatedEmojis.rollerCoaster,
    AnimatedEmojis.camping,
    AnimatedEmojis.confettiBall,
    AnimatedEmojis.balloon,
    AnimatedEmojis.birthdayCake,
    AnimatedEmojis.wrappedGift,
    AnimatedEmojis.fireworks,
    AnimatedEmojis.pinata,
    AnimatedEmojis.mirrorBall,
    AnimatedEmojis.soccerBall,
    AnimatedEmojis.baseball,
    AnimatedEmojis.softball,
    AnimatedEmojis.tennis,
    AnimatedEmojis.badminton,
    AnimatedEmojis.lacrosse,
    AnimatedEmojis.cricketGame,
    AnimatedEmojis.fieldHockey,
    AnimatedEmojis.iceHockey,
    AnimatedEmojis.directHit,
    AnimatedEmojis.flyingDisc,
    AnimatedEmojis.boomerang,
    AnimatedEmojis.kite,
    AnimatedEmojis.pingPong,
    AnimatedEmojis.bowling,
    AnimatedEmojis.die,
    AnimatedEmojis.slotMachine,
    AnimatedEmojis.cameraFlash,
    AnimatedEmojis.violin,
    AnimatedEmojis.drum,
    AnimatedEmojis.maracas,
    AnimatedEmojis.batteryFull,
    AnimatedEmojis.batteryLow,
    AnimatedEmojis.moneyWithWings,
    AnimatedEmojis.balanceScale,
    AnimatedEmojis.lightBulb,
    AnimatedEmojis.graduationCap,
    AnimatedEmojis.umbrella,
    AnimatedEmojis.gemStone,
    AnimatedEmojis.gear,
    AnimatedEmojis.pencil,
    AnimatedEmojis.alarmClock,
    AnimatedEmojis.bellhopBell,
    AnimatedEmojis.bell,
    AnimatedEmojis.crystalBall,
    AnimatedEmojis.aries,
    AnimatedEmojis.taurus,
    AnimatedEmojis.gemini,
    AnimatedEmojis.cancer,
    AnimatedEmojis.leo,
    AnimatedEmojis.virgo,
    AnimatedEmojis.libra,
    AnimatedEmojis.scorpio,
    AnimatedEmojis.sagittarius,
    AnimatedEmojis.capricorn,
    AnimatedEmojis.aquarius,
    AnimatedEmojis.pisces,
    AnimatedEmojis.ophiuchus,
    AnimatedEmojis.exclamation,
    AnimatedEmojis.question,
    AnimatedEmojis.exclamationQuestionMark,
    AnimatedEmojis.exclamationDouble,
    AnimatedEmojis.crossMark,
    AnimatedEmojis.sos,
    AnimatedEmojis.phoneOff,
    AnimatedEmojis.checkMark,
    AnimatedEmojis.newSymbol,
    AnimatedEmojis.free,
    AnimatedEmojis.upSymbol,
    AnimatedEmojis.cool,
    AnimatedEmojis.litter,
    AnimatedEmojis.musicalNotes,
    AnimatedEmojis.plusSign,
    AnimatedEmojis.chequeredFlag,
    AnimatedEmojis.triangularFlag,
    AnimatedEmojis.blackFlag,
    AnimatedEmojis.whiteFlag,
 */

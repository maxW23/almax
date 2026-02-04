// // ignore_for_file: public_member_api_docs, sort_constructors_first

// import 'package:flutter/material.dart';
// import 'package:lklk/core/widgets/entry_elemnts.dart';
// import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';

// import 'package:svgaplayer_flutter/svgaplayer_flutter.dart';

// class MyWidget extends StatefulWidget {
//   const MyWidget({super.key});

//   @override
//   State<MyWidget> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<MyWidget> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 3), () {
//       logSvgaDurations(entyElemntsSvga);
//     });
//     // TODO: implement initState
//   }

//   Future<Duration> getSvgaDuration(String filePath) async {
//     const parser = SVGAParser.shared;
//     try {
//       final animation = await parser.decodeFromAssets(filePath);

//       // Assuming that the animation has a totalFrame and fps field in its params
//       final int totalFrames = animation.params.frames;
//       final int fps = animation.params.fps;

//       // Calculate duration
//       final double durationInSeconds = totalFrames / fps;
//       final duration = Duration(seconds: durationInSeconds.round());
// // + const Duration(seconds: 2)
//       return duration;
//     } catch (e) {
//       //log('Error getting SVGA duration: $e');
//       return Duration.zero;
//     }
//   }

//   Future<void> logSvgaDurations(List<ElementEntity> gifts) async {
//     for (var gift in gifts) {
//       final duration = await getSvgaDuration(gift.linkPath!);
//       //log('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ${gift.id} ${gift.elementName} - Duration: $duration');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

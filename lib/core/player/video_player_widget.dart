// import 'package:flutter/material.dart';
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';

// class PlayerPageTest extends StatefulWidget {
//   final String assetPath;
//   final Widget? child;

//   const PlayerPageTest({
//     super.key,
//     required this.assetPath,
//     this.child,
//   });

//   @override
//   State<PlayerPageTest> createState() => _PlayerPageTestState();
// }

// class _PlayerPageTestState extends State<PlayerPageTest> {
//   late ChewieController _chewieController;

//   @override
//   void initState() {
//     _initializePlayer();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _chewieController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializePlayer() async {
//     final VideoPlayerController videoPlayerController =
//         VideoPlayerController.asset(widget.assetPath);
//     await videoPlayerController.initialize();
//     setState(() {
//       _chewieController = ChewieController(
//         videoPlayerController: videoPlayerController,
//         autoPlay: true,
//         looping: true,
//         showControls: false,
//         allowMuting: false,
//         allowPlaybackSpeedChanging: false,
//         allowFullScreen: false,
//         showOptions: false,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           if (widget.child != null) widget.child!,
//           FutureBuilder<void>(
//             future: _initializePlayer(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 return
//                     // _chewieController != null &&
//                     _chewieController.videoPlayerController.value.isInitialized
//                         ? Chewie(
//                             controller: _chewieController,
//                           )
//                         : Container();
//               } else {
//                 // Show loading indicator or placeholder while initializing
//                 return const CircularProgressIndicator(); // Example loading indicator
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

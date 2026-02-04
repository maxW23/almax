// import 'package:flutter/material.dart';
// import 'package:lklk/core/constants/assets.dart';
// import 'package:lklk/core/player/video_player_widget.dart';
// import 'package:video_player/video_player.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen();

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: <Widget>[
//         VideoPlayerWidget(
//           videoPlayerController: VideoPlayerController.asset(
//             'assets/gifts/dollars.mp4',
//           ),
//           looping: true,
//           autoplay: true,
//         ),
//         VideoPlayerWidget(
//           videoPlayerController: VideoPlayerController.network(
//               'https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4'),
//           looping: false,
//           autoplay: true,
//         ),
//         VideoPlayerWidget(
//           videoPlayerController: VideoPlayerController.asset(
//             AssetsData.gift1mp4,
//           ),
//           looping: false,
//           autoplay: false,
//         ),
//         VideoPlayerWidget(
//           videoPlayerController: VideoPlayerController.asset(
//             AssetsData.gift1mp4,
//           ),
//           autoplay: true,
//         ),
//         VideoPlayerWidget(
//           videoPlayerController: VideoPlayerController.network(
//               "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4"),
//           looping: true,
//           autoplay: false,
//         ),
//       ],
//     );
//   }
// }

// class AutoplayVideo extends StatefulWidget {
//   final bool repeat;

//   const AutoplayVideo({ this.repeat = false});

//   @override
//   State<AutoplayVideo> createState() => _AutoplayVideoState();
// }

// class _AutoplayVideoState extends State<AutoplayVideo> {
//   late VideoPlayerController _videoPlayerController;

//   @override
//   void initState() {
//     super.initState();
//     initializeController();
//   }

//   Future<void> initializeController() async {
//     _videoPlayerController = VideoPlayerController.asset(
//       'assets/gifts/dollars.mp4',
//     );

//     await _videoPlayerController.initialize();
//     if (widget.repeat) {
//       _videoPlayerController.setLooping(true); // Set looping if repeat is true
//     }
//     await _videoPlayerController
//         .play(); // Ensure video starts playing after initialization
//     setState(() );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.deepOrange,
//       child: Stack(
//         children: [
//           Center(
//             child: Container(
//               color: Colors.amber, // Set transparent background color
//               child: AspectRatio(
//                 aspectRatio: _videoPlayerController.value.aspectRatio,
//                 child: VideoPlayer(_videoPlayerController),
//               ),
//             ),
//           ),
//           Center(
//             child: _videoPlayerController.value.isInitialized
//                 ? const SizedBox.shrink()
//                 : const CircularProgressIndicator(),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _videoPlayerController.dispose();
//   }
// }

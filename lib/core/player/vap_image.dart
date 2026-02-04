// import 'package:flutter/material.dart';
// import 'package:vap/vap.dart';

// class VapPageImage extends StatefulWidget {
//   const VapPageImage();

//   @override
//   State<VapPageImage> createState() => _VapPageImageState();
// }

// class _VapPageImageState extends State<VapPageImage> {
//   @override
//   void initState() {
//     super.initState();
//     _playAsset("assets/gifts/white_frame_user.mp4");
//   }

//   Future<Map<dynamic, dynamic>?> _playAsset(String asset) async {
//     var res = await VapController.playAsset(asset);
//     return res;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           IgnorePointer(
//             child: VapView(),
//           ),
//           const Positioned(
//             bottom: 20,
//             left: 20,
//             child: AutoSizeText(
//               'Your child widget',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

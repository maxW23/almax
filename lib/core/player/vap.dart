// // import 'dart:io';
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'dart:async';
// // import 'package:dio/dio.dart';
// import 'package:lklk/core/utils/logger.dart';

// import 'package:oktoast/oktoast.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:vap/vap.dart';
// // // import 'package:flutter_vap2/flutter_vap.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:vap/vap.dart';
// // Import other necessary packages

// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// // Import other necessary packages

// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// // Import other necessary packages
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// // Import other necessary packages

// class VapPage extends StatefulWidget {
//   const VapPage({Key? key}) : super(key: key);

//   @override
//   _VapPageState createState() => _VapPageState();
// }

// class _VapPageState extends State<VapPage> {
//   bool _isPluginInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializePlugin();
//   }

//   Future<void> _initializePlugin() async {
//     // Perform plugin initialization here
//     // For example:
//     // await VapController.initialize();
//     setState(() {
//       _isPluginInitialized = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return OKToast(
//       child: MaterialApp(
//         home: Scaffold(
//           body: Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: const BoxDecoration(
//               color: Color.fromARGB(255, 140, 41, 43),
//               image: DecorationImage(
//                 image: AssetImage("assets/images/galaxy.jpg"),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Stack(
//               alignment: Alignment.bottomCenter,
//               children: [
//                 if (_isPluginInitialized) ...[
//                   IgnorePointer(
//                     child: VapView(),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _playVideo(String asset) {
//     if (_isPluginInitialized) {
//       VapController.playAsset(asset);
//     } else {
//       // Plugin is not initialized yet, wait for initialization to complete
//       // You can optionally show a loading indicator or perform other actions
//     }
//   }
// }

// // class VapPage extends StatefulWidget {
// //   const VapPage();

// //   @override
// //   State<VapPage> createState() => _VapPageState();
// // }

// // class _VapPageState extends State<VapPage> {
// //   // List<String> downloadPathList = [];
// //   // bool isDownload = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // initDownloadPath();
// //   }

// //   // Future<void> initDownloadPath() async {
// //   //   Directory appDocDir = await getApplicationDocumentsDirectory();
// //   //   String rootPath = appDocDir.path;
// //   //   downloadPathList = ["$rootPath/vap_demo1.mp4", "$rootPath/vap_demo2.mp4"];
// //   //   AppLogger.debug("downloadPathList:$downloadPathList");
// //   // }

// //   @override
// //   Widget build(BuildContext context) {
// //     return OKToast(
// //       child: MaterialApp(
// //         home: Scaffold(
// //           body: Container(
// //             width: double.infinity,
// //             height: double.infinity,
// //             decoration: const BoxDecoration(
// //               color: Color.fromARGB(255, 140, 41, 43),
// //               image: DecorationImage(
// //                   image: AssetImage("assets/images/galaxy.jpg")),
// //             ),
// //             child: Stack(
// //               alignment: Alignment.bottomCenter,
// //               children: [
// //                 Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     CupertinoButton(
// //                       color: Colors.purple,
// //                       child: const AutoSizeText("asset play"),
// //                       // onPressed: () =>
// //                       // _playAsset("assets/gifts/fram balck gold.mp4"),
// //                       onPressed: () =>
// //                           _playAsset("assets/gifts/white_frame_user.mp4"),
// //                     ),

// //                     // CupertinoButton(
// //                     //   color: Colors.purple,
// //                     //   child: AutoSizeText(
// //                     //       "download video source${isDownload ? "(✅)" : ""}"),
// //                     //   onPressed: _download,
// //                     // ),
// //                     // CupertinoButton(
// //                     //   color: Colors.purple,
// //                     //   child: AutoSizeText("File1 play"),
// //                     //   onPressed: () => _playFile(downloadPathList[0]),
// //                     // ),
// //                     // CupertinoButton(
// //                     //   color: Colors.purple,
// //                     //   child: AutoSizeText("File2 play"),
// //                     //   onPressed: () => _playFile(downloadPathList[1]),
// //                     // ),
// //                     // CupertinoButton(
// //                     //   color: Colors.purple,
// //                     //   child: AutoSizeText("asset play"),
// //                     //   onPressed: () => _playAsset("assets/gifts/demo.mp4"),
// //                     //   // onPressed: () => _playAsset("assets/gifts/demo.mp4"),

// //                     // ),
// //                     CupertinoButton(
// //                       color: Colors.purple,
// //                       child: const AutoSizeText("stop play"),
// //                       onPressed: () => VapController.stop(),
// //                     ),
// //                     // CupertinoButton(
// //                     //   color: Colors.purple,
// //                     //   child: AutoSizeText("queue play"),
// //                     //   onPressed: _queuePlay,
// //                     // ),
// //                     // CupertinoButton(
// //                     //   color: Colors.purple,
// //                     //   child: AutoSizeText("cancel queue play"),
// //                     //   onPressed: _cancelQueuePlay,
// //                     // ),
// //                   ],
// //                 ),
// //                 IgnorePointer(
// //                   child: VapView(
// //                       // onVapViewCreated: (controller) {
// //                       //     vapViewController = controller;
// //                       // }
// //                       ),
// //                   // child: VapView(),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // _download() async {
// //   //   await Dio().download(
// //   //       "http://file.jinxianyun.com/vap_demo1.mp4", downloadPathList[0]);
// //   //   await Dio().download(
// //   //       "http://file.jinxianyun.com/vap_demo2.mp4", downloadPathList[1]);
// //   //   setState(() {
// //   //     isDownload = true;
// //   //   });
// //   // }

// //   // Future<Map<dynamic, dynamic>?> _playFile(String path) async {
// //   //   var res = await VapController.playPath(path);
// //   //   if (res!["status"] == "failure") {
// //   //     showToast(res["errorMsg"]);
// //   //   }
// //   //   return res;
// //   // }

// //   // Future<Map<dynamic, dynamic>?> _playpath(String asset) async {
// //   //   var res = await VapController.playPath(asset);

// //   //   if (res!["status"] == "failure") {
// //   //     showToast(res["errorMsg"]);
// //   //   }
// //   //   return res;
// //   // }

// //   Future<Map<dynamic, dynamic>?> _playAsset(String asset) async {
// //     var res = await VapController.playAsset(asset);

// //     if (res!["status"] == "failure") {
// //       showToast(res["errorMsg"]);
// //     }
// //     return res;
// //   }

// //   // _queuePlay() async {
// //   //   QueueUtil.get("vapQueue")
// //   //       ?.addTask(() => VapController.playPath(downloadPathList[0]));
// //   //   QueueUtil.get("vapQueue")
// //   //       ?.addTask(() => VapController.playPath(downloadPathList[1]));
// //   // }

// //   // _cancelQueuePlay() {
// //   //   QueueUtil.get("vapQueue")?.cancelTask();
// //   // }
// // }

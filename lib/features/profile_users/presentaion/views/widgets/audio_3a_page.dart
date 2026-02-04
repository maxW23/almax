// import 'package:flutter/foundation.dart';
// import 'package:lklk/zego_sdk_key_center.dart';
// import 'package:universal_io/io.dart';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:zego_express_engine/zego_express_engine.dart';

// import '../../../../../core/widgets/sound_wave.dart';

// class Audio3aPage extends StatefulWidget {
//   const Audio3aPage({super.key});

//   @override
//   _Audio3aPageState createState() => _Audio3aPageState();
// }

// class _Audio3aPageState extends State<Audio3aPage> {
//   final _roomID = 'audio_3a';
//   final _streamID = 'audio_3a_s';
//   late ZegoRoomState _roomState;
//   late ZegoPublisherState _publisherState;
//   late ZegoPlayerState _playerState;

//   Widget? _previewViewWidget;
//   Widget? _playViewWidget;

//   late TextEditingController _publishStreamIDController;
//   late TextEditingController _playStreamIDController;

//   late bool _isOpenAEC;
//   late bool _isOpenHeadphoneAec;
//   late ZegoAECMode _aecMode;
//   late bool _isOpenAGC;
//   late bool _isOpenANS;
//   late ZegoANSMode _ansMode;

//   late ZegoDelegate _zegoDelegate;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     _zegoDelegate = ZegoDelegate();

//     _roomState = ZegoRoomState.Disconnected;
//     _publisherState = ZegoPublisherState.NoPublish;
//     _playerState = ZegoPlayerState.NoPlay;

//     _publishStreamIDController = TextEditingController();
//     _publishStreamIDController.text = _streamID;

//     _playStreamIDController = TextEditingController();
//     _playStreamIDController.text = _streamID;

//     _isOpenAEC = false;
//     _isOpenHeadphoneAec = false;
//     _aecMode = ZegoAECMode.Aggressive;
//     _isOpenAGC = false;
//     _isOpenANS = false;
//     _ansMode = ZegoANSMode.Soft;

//     _zegoDelegate.setZegoEventCallback(
//         onRoomStateUpdate: onRoomStateUpdate,
//         onPublisherStateUpdate: onPublisherStateUpdate,
//         onPlayerStateUpdate: onPlayerStateUpdate);
//     _zegoDelegate.createEngine().then((value) {
//       _zegoDelegate.loginRoom(_roomID);
//     });
//   }

//   @override
//   void dispose() {
//     _zegoDelegate.dispose();
//     _zegoDelegate.clearZegoEventCallback();
//     if (_roomState == ZegoRoomState.Connected) {
//       _zegoDelegate
//           .logoutRoom(_roomID)
//           .then((value) => _zegoDelegate.destroyEngine());
//     } else {
//       _zegoDelegate.destroyEngine();
//     }
//     super.dispose();
//   }

//   // zego express callback

//   void onRoomStateUpdate(String roomID, ZegoRoomState state, int errorCode,
//       Map<String, dynamic> extendedData) {
//     if (roomID == _roomID) {
//       setState(() {
//         _roomState = state;
//       });
//     }
//   }

//   void onPublisherStateUpdate(String streamID, ZegoPublisherState state,
//       int errorCode, Map<String, dynamic> extendedData) {
//     if (streamID == _publishStreamIDController.text.trim()) {
//       setState(() {
//         _publisherState = state;
//       });
//     }
//   }

//   void onPlayerStateUpdate(String streamID, ZegoPlayerState state,
//       int errorCode, Map<String, dynamic> extendedData) {
//     if (streamID == _playStreamIDController.text.trim()) {
//       setState(() {
//         _playerState = state;
//       });
//     }
//   }

//   // widget callback

//   void onPublishBtnPress() {
//     if (_publisherState == ZegoPublisherState.Publishing) {
//       _zegoDelegate.stopPublishing();
//     } else {
//       _zegoDelegate
//           .startPublishing(
//         _publishStreamIDController.text.trim(),
//       )
//           .then((widget) {
//         setState(() {
//           _previewViewWidget = widget;
//         });
//       });
//     }
//   }

//   void onPlayBtnPress() {
//     if (_playerState != ZegoPlayerState.NoPlay) {
//       _zegoDelegate.stopPlaying(_playStreamIDController.text.trim());
//     } else {
//       _zegoDelegate
//           .startPlaying(
//         _playStreamIDController.text.trim(),
//       )
//           .then((widget) {
//         setState(() {
//           _playViewWidget = widget;
//         });
//       });
//     }
//   }

//   void onAECSwitchChanged(bool isChecked) {
//     _isOpenAEC = isChecked;
//     _zegoDelegate.enableAEC(isChecked);
//     setState(() {});
//   }

//   void onHeadphoneAecSwitchChanged(bool isChecked) {
//     _isOpenHeadphoneAec = isChecked;
//     _zegoDelegate.enableHeadphoneAEC(isChecked);
//     setState(() {});
//   }

//   void onAECModeChanged(ZegoAECMode? mode) {
//     if (mode != null) {
//       _aecMode = mode;
//       _zegoDelegate.setAECMode(mode);
//       setState(() {});
//     }
//   }

//   void onAGCSwitchChanged(bool isChecked) {
//     _isOpenAGC = isChecked;
//     _zegoDelegate.enableAGC(isChecked);
//     setState(() {});
//   }

//   void onANSSwitchChanged(bool isChecked) {
//     _isOpenANS = isChecked;
//     _zegoDelegate.enableANS(isChecked);
//     setState(() {});
//   }

//   void onANSModeChanged(ZegoANSMode? mode) {
//     if (mode != null) {
//       _ansMode = mode;
//       _zegoDelegate.setANSMode(mode);
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const AutoSizeText('音频3A处理'),
//       ),
//       body: SafeArea(
//           child: SingleChildScrollView(
//         child: mainContent(context),
//       )),
//     );
//   }

//   Widget mainContent(BuildContext context) {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // SizedBox(
//           //   child: ZegoLogView(),
//           //   height: MediaQuery.of(context).size.height * 0.1,
//           // ),
//           roomInfoWidget(),
//           viewWidget(),
//           streamIDWidget(context),
//           aecWidget(context),
//           agcWidget(),
//           ansWidget()
//         ],
//       ),
//     );
//   }

//   Widget roomInfoWidget() {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       AutoSizeText("RoomID: $_roomID"),
//       AutoSizeText('RoomState: ${_zegoDelegate.roomStateDesc(_roomState)}')
//     ]);
//   }

//   Widget viewWidget() {
//     return Container(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//               height: MediaQuery.of(context).size.height * 0.5,
//               padding: const EdgeInsets.all(10.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                       flex: 15,
//                       child: Stack(
//                         alignment: AlignmentDirectional.topCenter,
//                         children: [
//                           Container(
//                             color: Colors.grey[300],
//                             child: _previewViewWidget,
//                           ),
//                           preWidgetTopWidget()
//                         ],
//                       )),
//                   Expanded(flex: 1, child: Container()),
//                   Expanded(
//                       flex: 15,
//                       child: Stack(
//                         alignment: AlignmentDirectional.topCenter,
//                         children: [
//                           Container(
//                             color: Colors.grey[300],
//                             child: _playViewWidget,
//                           ),
//                           playWidgetTopWidget()
//                         ],
//                       )),
//                 ],
//               ))
//         ],
//       ),
//     );
//   }

//   Widget preWidgetTopWidget() {
//     return Padding(
//         padding: const EdgeInsets.only(bottom: 10),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Center(
//               child: AutoSizeText('Local Preview View',
//                   style: TextStyle(color: Colors.white))),
//           Expanded(child: Container()),
//           const Padding(padding: EdgeInsets.only(top: 5)),
//           Container(
//               padding: const EdgeInsets.only(left: 10),
//               width: MediaQuery.of(context).size.width * 0.4,
//               child: CupertinoButton.filled(
//                   onPressed: onPublishBtnPress,
//                   padding: const EdgeInsets.all(10.0),
//                   child: AutoSizeText(
//                     _publisherState == ZegoPublisherState.Publishing
//                         ? '✅ StopPublishing'
//                         : 'StartPublishing',
//                     style: const TextStyle(fontSize: 14.0),
//                   )))
//         ]));
//   }

//   // Buttons and titles on the play widget
//   Widget playWidgetTopWidget() {
//     return Padding(
//         padding: const EdgeInsets.only(bottom: 10),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Center(
//               child: AutoSizeText('Remote Play View',
//                   style: TextStyle(color: Colors.white))),
//           Expanded(child: Container()),
//           const Padding(padding: EdgeInsets.only(top: 5)),
//           Container(
//             padding: const EdgeInsets.only(left: 10),
//             width: MediaQuery.of(context).size.width * 0.4,
//             child: CupertinoButton.filled(
//                 onPressed: onPlayBtnPress,
//                 padding: const EdgeInsets.all(10.0),
//                 child: AutoSizeText(
//                   _playerState != ZegoPlayerState.NoPlay
//                       ? (_playerState == ZegoPlayerState.Playing
//                           ? '✅ StopPlaying'
//                           : '❌ StopPlaying')
//                       : 'StartPlaying',
//                   style: const TextStyle(fontSize: 14.0),
//                 )),
//           )
//         ]));
//   }

//   Widget streamIDWidget(context) {
//     return Padding(
//         padding: const EdgeInsets.only(left: 10, right: 10),
//         child: Row(
//           children: [
//             Expanded(
//                 flex: 15,
//                 child: Row(children: [
//                   const AutoSizeText(
//                     'Publish StreamID:',
//                     style: TextStyle(fontSize: 11),
//                   ),
//                   SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.2,
//                       child: TextField(
//                         controller: _publishStreamIDController,
//                         style: const TextStyle(fontSize: 11),
//                         decoration: const InputDecoration(
//                             contentPadding: EdgeInsets.all(10.0),
//                             isDense: true,
//                             enabledBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.grey)),
//                             focusedBorder: OutlineInputBorder(
//                                 borderSide:
//                                     BorderSide(color: Color(0xff0e88eb)))),
//                       ))
//                 ])),
//             Expanded(flex: 1, child: Container()),
//             Expanded(
//                 flex: 15,
//                 child: Row(children: [
//                   const AutoSizeText('play StreamID:',
//                       style: TextStyle(fontSize: 11)),
//                   SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.2,
//                       child: TextField(
//                         controller: _playStreamIDController,
//                         style: const TextStyle(fontSize: 11),
//                         decoration: const InputDecoration(
//                             contentPadding: EdgeInsets.all(10.0),
//                             isDense: true,
//                             enabledBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: Colors.grey)),
//                             focusedBorder: OutlineInputBorder(
//                                 borderSide:
//                                     BorderSide(color: Color(0xff0e88eb)))),
//                       ))
//                 ]))
//           ],
//         ));
//   }

//   Widget aecWidget(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//             margin: const EdgeInsets.only(top: 10),
//             color: Colors.grey[300],
//             width: MediaQuery.of(context).size.width,
//             alignment: Alignment.topLeft,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                     padding:
//                         const EdgeInsets.only(left: 10, top: 10, bottom: 10),
//                     child: const AutoSizeText(
//                       '回声消除',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
//                     )),
//                 const AutoSizeText(
//                     '如果您的设备自带硬件级别的回声消除功能，那么开启 SDK 的 AEC 功能时并不能明显地感觉到回声消除的效果',
//                     style: TextStyle(fontSize: 14)),
//               ],
//             )),
//         Container(
//           padding: const EdgeInsets.only(left: 10, right: 10),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   const AutoSizeText('回声消除'),
//                   Switch(value: _isOpenAEC, onChanged: onAECSwitchChanged),
//                   Expanded(child: Container()),
//                   Offstage(
//                     offstage: kIsWeb || Platform.isWindows || Platform.isMacOS,
//                     child: const AutoSizeText('耳机回声处理'),
//                   ),
//                   Offstage(
//                       offstage:
//                           kIsWeb || Platform.isWindows || Platform.isMacOS,
//                       child: Switch(
//                         value: _isOpenHeadphoneAec,
//                         onChanged: onHeadphoneAecSwitchChanged,
//                       )),
//                 ],
//               ),
//               Offstage(
//                 offstage: kIsWeb,
//                 child: Row(
//                   children: [
//                     const Expanded(child: AutoSizeText('音量')),
//                     DropdownButton<ZegoAECMode>(
//                       items: [
//                         DropdownMenuItem(
//                           value: ZegoAECMode.Aggressive,
//                           child:
//                               AutoSizeText(ZegoAECMode.Aggressive.toString()),
//                         ),
//                         DropdownMenuItem(
//                           value: ZegoAECMode.Medium,
//                           child: AutoSizeText(ZegoAECMode.Medium.toString()),
//                         ),
//                         DropdownMenuItem(
//                           value: ZegoAECMode.Soft,
//                           child: AutoSizeText(ZegoAECMode.Soft.toString()),
//                         ),
//                       ],
//                       onChanged: onAECModeChanged,
//                       value: _aecMode,
//                     )
//                   ],
//                 ),
//               )
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   Widget agcWidget() {
//     return Column(
//       children: [
//         Container(
//           margin: const EdgeInsets.only(top: 10),
//           color: Colors.grey[300],
//           width: MediaQuery.of(context).size.width,
//           alignment: Alignment.topLeft,
//           child: Container(
//               padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
//               child: const AutoSizeText(
//                 '自动增益',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
//               )),
//         ),
//         Container(
//           padding: const EdgeInsets.only(left: 10, right: 10),
//           child: Row(
//             children: [
//               const AutoSizeText('自动增益'),
//               Switch(value: _isOpenAGC, onChanged: onAGCSwitchChanged),
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   Widget ansWidget() {
//     return Column(
//       children: [
//         Container(
//           margin: const EdgeInsets.only(top: 10),
//           color: Colors.grey[300],
//           width: MediaQuery.of(context).size.width,
//           alignment: Alignment.topLeft,
//           child: Container(
//               padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
//               child: const AutoSizeText(
//                 '噪声抑制',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
//               )),
//         ),
//         Container(
//           padding: const EdgeInsets.only(left: 10, right: 10),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   const AutoSizeText('噪声抑制'),
//                   Switch(value: _isOpenANS, onChanged: onANSSwitchChanged),
//                 ],
//               ),
//               Offstage(
//                   offstage: kIsWeb,
//                   child: Row(
//                     children: [
//                       const Expanded(child: AutoSizeText('音量')),
//                       DropdownButton<ZegoANSMode>(
//                         items: [
//                           DropdownMenuItem(
//                             value: ZegoANSMode.Soft,
//                             child: AutoSizeText(ZegoANSMode.Soft.toString()),
//                           ),
//                           DropdownMenuItem(
//                             value: ZegoANSMode.Medium,
//                             child: AutoSizeText(ZegoANSMode.Medium.toString()),
//                           ),
//                           DropdownMenuItem(
//                             value: ZegoANSMode.Aggressive,
//                             child:
//                                 AutoSizeText(ZegoANSMode.Aggressive.toString()),
//                           ),
//                           DropdownMenuItem(
//                             value: ZegoANSMode.AI,
//                             child: AutoSizeText(ZegoANSMode.AI.toString()),
//                           ),
//                         ],
//                         onChanged: onANSModeChanged,
//                         value: _ansMode,
//                       )
//                     ],
//                   ))
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }

// typedef RoomStateUpdateCallback = void Function(
//     String, ZegoRoomState, int, Map<String, dynamic>);
// typedef PublisherStateUpdateCallback = void Function(
//     String, ZegoPublisherState, int, Map<String, dynamic>);
// typedef PlayerStateUpdateCallback = void Function(
//     String, ZegoPlayerState, int, Map<String, dynamic>);

// class ZegoDelegate {
//   RoomStateUpdateCallback? _onRoomStateUpdate;
//   PublisherStateUpdateCallback? _onPublisherStateUpdate;
//   PlayerStateUpdateCallback? _onPlayerStateUpdate;

//   late int _preViewID;
//   late int _playViewID;

//   Widget? preWidget;
//   Widget? playWidget;
//   ZegoDelegate()
//       : _preViewID = -1,
//         _playViewID = -1;

//   dispose() {
//     if (_preViewID != -1) {
//       ZegoExpressEngine.instance.destroyCanvasView(_preViewID);
//       _preViewID = -1;
//     }
//     if (_playViewID != -1) {
//       ZegoExpressEngine.instance.destroyCanvasView(_playViewID);
//       _playViewID = -1;
//     }
//   }

//   void _initCallback() {
//     ZegoExpressEngine.onRoomStateUpdate = (String roomID, ZegoRoomState state,
//         int errorCode, Map<String, dynamic> extendedData) {
//       // ZegoLog().addLog(
//       //     '🚩 🚪 Room state update, state: $state, errorCode: $errorCode, roomID: $roomID');
//       _onRoomStateUpdate?.call(roomID, state, errorCode, extendedData);
//     };

//     ZegoExpressEngine.onPublisherStateUpdate = (String streamID,
//         ZegoPublisherState state,
//         int errorCode,
//         Map<String, dynamic> extendedData) {
//       // ZegoLog().addLog(
//       // '🚩 📤 Publisher state update, state: $state, errorCode: $errorCode, streamID: $streamID');
//       if (state == ZegoPublisherState.Publishing && errorCode == 0) {
//         // ZegoLog().addLog('🚩 📥 Publishing stream success');
//       }
//       if (errorCode != 0) {
//         // ZegoLog().addLog('🚩 ❌ 📥 Publishing stream fail');
//       }
//       _onPublisherStateUpdate?.call(streamID, state, errorCode, extendedData);
//     };

//     ZegoExpressEngine.onPlayerStateUpdate = (String streamID,
//         ZegoPlayerState state,
//         int errorCode,
//         Map<String, dynamic> extendedData) {
//       // ZegoLog().addLog(
//       // '🚩 📥 Player state update, state: $state, errorCode: $errorCode, streamID: $streamID');
//       if (state == ZegoPlayerState.Playing && errorCode == 0) {
//         // ZegoLog().addLog('🚩 📥 Playing stream success');
//       }
//       if (errorCode != 0) {
//         // ZegoLog().addLog('🚩 ❌ 📥 Playing stream fail');
//       }
//       _onPlayerStateUpdate?.call(streamID, state, errorCode, extendedData);
//     };
//   }

//   void setZegoEventCallback({
//     RoomStateUpdateCallback? onRoomStateUpdate,
//     PublisherStateUpdateCallback? onPublisherStateUpdate,
//     PlayerStateUpdateCallback? onPlayerStateUpdate,
//   }) {
//     if (onRoomStateUpdate != null) {
//       _onRoomStateUpdate = onRoomStateUpdate;
//     }
//     if (onPublisherStateUpdate != null) {
//       _onPublisherStateUpdate = onPublisherStateUpdate;
//     }
//     if (onPlayerStateUpdate != null) {
//       _onPlayerStateUpdate = onPlayerStateUpdate;
//     }
//   }

//   void clearZegoEventCallback() {
//     _onRoomStateUpdate = null;
//     ZegoExpressEngine.onRoomStateUpdate = null;

//     _onPublisherStateUpdate = null;
//     ZegoExpressEngine.onPublisherStateUpdate = null;

//     _onPlayerStateUpdate = null;
//     ZegoExpressEngine.onPlayerStateUpdate = null;
//   }

//   Future<void> createEngine({bool? enablePlatformView}) async {
//     _initCallback();

//     await ZegoExpressEngine.destroyEngine();

//     enablePlatformView =
//         enablePlatformView ?? ZegoConfig.instance.enablePlatformView;
//     // ZegoLog().addLog("enablePlatformView :$enablePlatformView");
//     ZegoEngineProfile profile = ZegoEngineProfile(
//         SDKKeyCenter.appID, ZegoConfig.instance.scenario,
//         enablePlatformView: enablePlatformView,
//         appSign: kIsWeb ? null : SDKKeyCenter.appSign);
//     await ZegoExpressEngine.createEngineWithProfile(profile);

//     // ZegoLog().addLog('🚀 Create ZegoExpressEngine');
//   }

//   void destroyEngine() {
//     ZegoExpressEngine.destroyEngine();
//   }

//   String roomStateDesc(ZegoRoomState roomState) {
//     String result = 'Unknown';
//     switch (roomState) {
//       case ZegoRoomState.Disconnected:
//         result = "Disconnected 🔴";
//         break;
//       case ZegoRoomState.Connecting:
//         result = "Connecting 🟡";
//         break;
//       case ZegoRoomState.Connected:
//         result = "Connected 🟢";
//         break;
//       default:
//         result = "Unknown";
//     }
//     return result;
//   }

//   Future<void> loginRoom(String roomID) async {
//     if (roomID.isNotEmpty) {
//       // Instantiate a ZegoUser object
//       ZegoUser user = ZegoUser("21", "UserIdHelper.instance.userName");
//       if (kIsWeb) {
//         ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
//         // config.token = await TokenHelper.instance.getToken(roomID);
//         // Login Room WEB only supports token;
//         ZegoExpressEngine.instance.loginRoom(roomID, user, config: config);
//       } else {
//         // Login Room
//         await ZegoExpressEngine.instance.loginRoom(roomID, user);
//       }

//       // ZegoLog().addLog('🚪 Start login room, roomID: $roomID');
//     }
//   }

//   Future<void> logoutRoom(String roomID) async {
//     if (roomID.isNotEmpty) {
//       await ZegoExpressEngine.instance.logoutRoom(roomID);

//       // ZegoLog().addLog('🚪 Start logout room, roomID: $roomID');
//     }
//   }

//   Future<Widget?> startPublishing(String streamID, {String? roomID}) async {
//     publishFunc(int viewID) {
//       ZegoExpressEngine.instance
//           .startPreview(canvas: ZegoCanvas(viewID, backgroundColor: 0xffffff));
//       if (roomID != null) {
//         ZegoExpressEngine.instance.startPublishingStream(streamID,
//             config: ZegoPublisherConfig(roomID: roomID));
//       } else {
//         ZegoExpressEngine.instance.startPublishingStream(streamID);
//       }
//       // ZegoLog().addLog('📥 Start publish stream, streamID: $streamID');
//     }

//     if (streamID.isNotEmpty) {
//       if (_preViewID == -1) {
//         preWidget = await ZegoExpressEngine.instance.createCanvasView((viewID) {
//           _preViewID = viewID;
//           publishFunc(_preViewID);
//         });
//       } else {
//         publishFunc(_preViewID);
//       }
//     }
//     return preWidget;
//   }

//   void stopPublishing() {
//     ZegoExpressEngine.instance.stopPreview();
//     ZegoExpressEngine.instance.stopPublishingStream();
//   }

//   Future<Widget?> startPlaying(String streamID,
//       {String? cdnURL, bool needShow = true, String? roomID}) async {
//     playFunc(int viewID) {
//       ZegoCDNConfig? cdnConfig;
//       if (cdnURL != null) {
//         cdnConfig = ZegoCDNConfig(cdnURL);
//       }

//       if (needShow) {
//         ZegoExpressEngine.instance.startPlayingStream(streamID,
//             canvas: ZegoCanvas(viewID, backgroundColor: 0xffffff),
//             config: ZegoPlayerConfig(ZegoStreamResourceMode.Default,
//                 videoCodecID: ZegoVideoCodecID.Default,
//                 cdnConfig: cdnConfig,
//                 roomID: roomID));
//       } else {
//         ZegoExpressEngine.instance.startPlayingStream(
//           streamID,
//         );
//       }

//       // ZegoLog().addLog('📥 Start publish stream, streamID: $streamID');
//     }

//     if (streamID.isNotEmpty) {
//       if (_playViewID == -1 && needShow) {
//         playWidget =
//             await ZegoExpressEngine.instance.createCanvasView((viewID) {
//           _playViewID = viewID;
//           playFunc(_playViewID);
//         });
//       } else {
//         playFunc(_playViewID);
//       }
//     }
//     return playWidget;
//   }

//   void stopPlaying(String streamID) {
//     ZegoExpressEngine.instance.stopPlayingStream(streamID);
//   }

//   void enableHeadphoneAEC(bool enable) {
//     if (Platform.isAndroid || Platform.isIOS) {
//       ZegoExpressEngine.instance.enableHeadphoneAEC(enable);
//     }
//   }

//   void enableAEC(bool enable) {
//     ZegoExpressEngine.instance.enableAEC(enable);
//   }

//   void setAECMode(ZegoAECMode mode) {
//     ZegoExpressEngine.instance.setAECMode(mode);
//   }

//   void enableAGC(bool enable) {
//     ZegoExpressEngine.instance.enableAGC(enable);
//   }

//   void enableANS(bool enable) {
//     ZegoExpressEngine.instance.enableANS(enable);
//   }

//   void setANSMode(ZegoANSMode mode) {
//     ZegoExpressEngine.instance.setANSMode(mode);
//   }
// }

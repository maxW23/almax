// import 'package:flutter/material.dart';
// import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
// import 'package:path_provider/path_provider.dart';

// class VoiceRecorderWidget extends StatefulWidget {
//   final Function(String) onAudioSaved;

//   const VoiceRecorderWidget({Key? key, required this.onAudioSaved}) : super(key: key);

//   @override
//   _VoiceRecorderWidgetState createState() => _VoiceRecorderWidgetState();
// }

// class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
//   late FlutterAudioRecorder _audioRecorder;
//   bool _isRecording = false;

//   @override
//   void initState() {
//     super.initState();
//     _initAudioRecorder();
//   }

//   Future<void> _initAudioRecorder() async {
//     try {
//       if (!mounted) return;

//       // Get the directory for storing audio files
//       String customPath = '/flutter_audio_recorder_';
//       Directory appDocDirectory = await getApplicationDocumentsDirectory();
//       customPath = appDocDirectory.path + customPath + DateTime.now().millisecondsSinceEpoch.toString();

//       // Initialize the audio recorder
//       _audioRecorder = FlutterAudioRecorder(customPath,
//           audioFormat: AudioFormat.WAV, sampleRate: 16000);
//       await _audioRecorder.initialized;
//     } catch (e) {
//       AppLogger.debug("Failed to initialize audio recorder: $e");
//     }
//   }

//   Future<void> _startRecording() async {
//     try {
//       await _audioRecorder.start();
//       setState(() {
//         _isRecording = true;
//       });
//     } catch (e) {
//       AppLogger.debug("Failed to start recording: $e");
//     }
//   }

//   Future<void> _stopRecording() async {
//     var recording = await _audioRecorder.stop();
//     String path = recording.path;

//     setState(() {
//       _isRecording = false;
//     });

//     widget.onAudioSaved(path);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic),
//       onPressed: () {
//         if (_isRecording) {
//           _stopRecording();
//         } else {
//           _startRecording();
//         }
//       },
//     );
//   }
// }

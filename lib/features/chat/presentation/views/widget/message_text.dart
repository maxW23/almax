import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lklk/core/constants/app_colors.dart';
import 'package:lklk/features/chat/domain/enitity/message_entity.dart';

class MessageText extends StatelessWidget {
  final MessagePrivate message;
  final bool current;
  const MessageText({
    super.key,
    required this.message,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 40,
        // maxHeight: 250,
        maxWidth: MediaQuery.of(context).size.width * 0.7,
        minWidth: MediaQuery.of(context).size.width * 0.1,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        // color: current ? AppColors.white : AppColors.white,
        borderRadius: BorderRadius.circular(
          20,
        ),
        // current
        //     ? const BorderRadius.only(
        //         topLeft: Radius.circular(20),
        //         bottomLeft: Radius.circular(20),
        //         topRight: Radius.circular(20),
        //       )
        //     : const BorderRadius.only(
        //         topLeft: Radius.circular(20),
        //         bottomRight: Radius.circular(20),
        //         topRight: Radius.circular(20),
        //       ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 10, bottom: 5, right: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              current ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: AutoSizeText(
                message.message,
                style: TextStyle(
                  color: current ? Colors.black : Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            current
                ? const Icon(
                    Icons.done_all,
                    color: Colors.white,
                    size: 14,
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}

////////////////////
///class MessageAudio extends StatefulWidget {
//   const MessageAudio({ required this.message, required this.current});
//   final MessagePrivate message;
//   final bool current;
//   @override
//   State<MessageAudio> createState() => _MessageAudioState();
// }

// class _MessageAudioState extends State<MessageAudio> {
//   final player = AudioPlayer();
//   Duration? duration = Duration.zero;
//   Duration seekBarPosition = Duration.zero;
//   bool isPlaying = false;

//   @override
//   void initState() {
//     setData();
//     super.initState();
//   }

//   void setData() async {
//     Uri.parse(widget.message.message).isAbsolute
//         ? duration = await player.setUrl(widget.message.message)
//         : duration = await player.setFilePath(widget.message.message);

//     setState(() );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment:
//           widget.current ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: MediaQuery.of(context).size.width * 0.7,
//           padding: const EdgeInsets.symmetric(
//             horizontal: 12,
//           ),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(30),
//             color: (Colors.yellowAccent).withValues(alpha: widget.current ? 1 : 0.1),
//           ),
//           child: Row(
//             /// mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               IconButton(
//                 onPressed: () {
//                   isPlaying ? player.pause() : play();
//                   setState(() {
//                     isPlaying = !isPlaying;
//                   });
//                 },
//                 icon: Icon(
//                   isPlaying ? Icons.pause : Icons.play_arrow,
//                   color: widget.current ? Colors.white : (Colors.yellowAccent),
//                   // size: 25,
//                 ),
//               ),
//               Expanded(
//                 child: Slider(
//                     activeColor: Colors.green,
//                     inactiveColor: Colors.brown,
//                     max: player.duration?.inMilliseconds.toDouble() ?? 1,
//                     value: player.position.inMilliseconds.toDouble(),
//                     onChanged: (d) {
//                       setState(() {
//                         player.seek(Duration(milliseconds: d.toInt()));
//                       });
//                     }),
//               ),
//               AutoSizeText(
//                 _printDuration(player.position),
//                 style: TextStyle(
//                     fontSize: 12, color: widget.current ? Colors.white : null),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// this function is used to play audio wither its from url or path file
//   void play() {
//     if (player.duration != null && player.position >= player.duration!) {
//       player.seek(Duration.zero);
//       setState(() {
//         isPlaying = false;
//       });
//     }
//     AppLogger.debug(player.duration);
//     AppLogger.debug(player.position);
//     player.play();

//     player.positionStream.listen((duration) {
//       // duration == player.duration;
//       setState(() {
//         seekBarPosition = duration;
//       });
//       if (player.duration != null && player.position >= player.duration!) {
//         player.stop();
//         player.seek(Duration.zero);
//         setState(() {
//           isPlaying = false;
//           seekBarPosition = Duration.zero;
//         });
//       }
//     });
//   }

//   /// function used to print the duration of the current audio duration
//   String _printDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     String hoursString =
//         duration.inHours == 0 ? '' : "${twoDigits(duration.inHours)}:";
//     return "$hoursString$twoDigitMinutes:$twoDigitSeconds";
//   }
// }

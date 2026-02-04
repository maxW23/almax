library wave_blob;

// Widget waveBlobWidgetItem({
//   required List<Color> colors,
//   required double amplitude,
//   required double scale,
//   required double width,
//   required double height,

// }) {
//   // double scale0 = scale;
//   // double amplitude0 = amplitude;
//   // Timer? timer;

//   // Since we can't use setState directly in a method, we use a StatefulBuilder or another state management approach here.
//   // return StatefulBuilder(
//   //   builder: (context, setState) {
//   //     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//   //       startTimer();
//   //     });
//   //log('wave is : ${amplitude < 1 ? 0 : amplitude * 1000000}');
//   return Center(
//     child: SizedBox(
//       width: width,
//       height: height,
//       child: amplitude > 2
//           ? WaveBlob(
//               blobCount: 2,
//               amplitude: amplitude * 1000000,
//               scale: scale,
//               centerCircle: false,
//               overCircle: false,
//               circleColors: colors,
//               child: const SizedBox(),
//             )
//           :
//            WaveBlob(
//               blobCount: 1,
//               amplitude: 0,
//               scale: 1,
//               centerCircle: false,
//               overCircle: false,
//               circleColors: colors,
//               child: const SizedBox(),
//             ),
//     ),
//     // );
//     // },
//   );
// }

// Note: WaveBlob is assumed to be a custom widget.
// class WaveBlob extends StatelessWidget {
//   final int blobCount;
//   final double amplitude;
//   final double scale;
//   final bool centerCircle;
//   final bool overCircle;
//   final List<Color> circleColors;
//   final Widget child;

//   const WaveBlob({
//     super.key,
//     required this.blobCount,
//     required this.amplitude,
//     required this.scale,
//     required this.centerCircle,
//     required this.overCircle,
//     required this.circleColors,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Implementation of WaveBlob widget.
//     return Container();
//   }
// }

// class WaveBlobWidget extends StatefulWidget {
//   const WaveBlobWidget(
//       {super.key,
//       required this.colors,
//       required this.amplitude,
//       required this.scale});
//   final List<Color> colors;
//   final double amplitude;
//   final double scale;

//   @override
//   State<WaveBlobWidget> createState() => _MyAppState();
// }

// class _MyAppState extends State<WaveBlobWidget> {
//   double _scale = 1.0;
//   double _amplitude = 4250.0;

//   @override
//   void initState() {
//     _amplitude = widget.amplitude;
//     _scale = widget.scale;
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       Timer.periodic(const Duration(milliseconds: 50), (timer) {
//         setState(() {});
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // //log('scale = $_scale -- amplitude = $_amplitude');
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 27, 34, 42),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // SizedBox(
//             //   width: MediaQuery.sizeOf(context).width * 0.8,
//             //   child: Slider(
//             //     value: _amplitude,
//             //     activeColor: Colors.blue,
//             //     inactiveColor: Colors.lightBlueAccent.withValues(alpha: 0.2),
//             //     min: 0.0,
//             //     max: 8500.0,
//             //     onChanged: (v) {
//             //       _amplitude = v;
//             //     },
//             //   ),
//             // ),
//             // const AutoSizeText('Scale'),
//             // SizedBox(
//             //   width: MediaQuery.sizeOf(context).width * 0.8,
//             //   child: Row(
//             //     children: [
//             //       Expanded(
//             //         child: Slider(
//             //           value: _scale,
//             //           activeColor: Colors.blue,
//             //           inactiveColor: Colors.lightBlueAccent.withValues(alpha: 0.2),
//             //           min: 1.0,
//             //           max: 1.3,
//             //           onChanged: (v) {
//             //             setState(() => _scale = v);
//             //           },
//             //         ),
//             //       ),
//             //       // Checkbox(
//             //       //   value: _autoScale,
//             //       //   activeColor: Colors.blue,
//             //       //   checkColor: Colors.white,
//             //       //   onChanged: (v) {
//             //       //     _autoScale = v!;
//             //       //   },
//             //       // ),
//             //       // const AutoSizeText('Auto'),
//             //     ],
//             //   ),
//             // ),
//             // const SizedBox(height: 20.0),
//             WaveBlobWidgetItem(
//               amplitude: _amplitude,
//               scale: _scale,
//               colors: widget.colors,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

// class WaveBlobWidgetItem extends StatefulWidget {
//   const WaveBlobWidgetItem({
//     super.key,
//     required this.colors,
//     required this.amplitude,
//     required this.scale, required this.width, required this.height,
//   });
//   final double amplitude,scale;
//   final double width, height;
//   final List<Color> colors;

//   @override
//   State<WaveBlobWidgetItem> createState() => _WaveBlobWidgetItemState();
// }

// class _WaveBlobWidgetItemState extends State<WaveBlobWidgetItem> {
//   double _scale = 1.0;
//   double _amplitude = 4250.0;
// Timer? _timer;
//   @override
//   void initState() {
//     _amplitude = widget.amplitude;
//     _scale = widget.scale;
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//      _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
//         setState(() {});
//       });
//     });
//   }
// @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: widget.width,
//       height:widget.height,
//       child: WaveBlob(
//         blobCount: 4,
//         amplitude: _amplitude,
//         scale: _scale,
//         // autoScale: _autoScale,
//         centerCircle: false,
//         overCircle: true,
//         circleColors: widget.colors,
//         child: const SizedBox(),
//       ),
//     );
//   }
// }

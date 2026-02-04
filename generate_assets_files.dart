// import 'dart:io';

// void main() {
//   final directory = Directory('assets/gifts_image_svga');
//   final buffer = StringBuffer();

//   buffer.writeln();
//   buffer.writeln('class Assets {');
//   buffer.writeln('  Assets._();');
//   buffer.writeln();
//   buffer.writeln('  static const files = [');

//   directory.listSync().forEach((file) {
//     if (file is File) {
//       final fileName = file.path.split('/').last.replaceAll('\\', '/');
//       buffer.writeln("    'assets/$fileName',");
//     }
//   });
//   buffer.writeln('  ');

//   buffer.writeln('  ];');
//   buffer.writeln('}');

//   final outputFile = File('lib/assets_generated/gifts_image_svga.dart');
//   outputFile.writeAsStringSync(buffer.toString());

//   //log('Asset list generated: lib/gifts_image_svga.dart');
// }

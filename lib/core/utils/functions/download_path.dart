import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> getDownloadsDirectory() async {
  final Directory dir = await getApplicationDocumentsDirectory();
  final String filePath = '${dir.path}/downloads/';
  return filePath;
}

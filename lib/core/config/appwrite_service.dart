import 'package:appwrite/appwrite.dart';
import 'package:lklk/core/config/appwrite_config.dart';
import 'package:lklk/core/utils/logger.dart';

class AppwriteService {
  static Future<void> createTestDocument() async {
    AppwriteConfig.init(); // التحقق من التهيئة

    try {
      await AppwriteConfig.databases!.createDocument(
        databaseId: '687d45af00221673b1c4',
        collectionId: '687d45d4000515f34e76',
        documentId: ID.unique(),
        data: {'message': 'Hello from Flutter!'},
      );
    } catch (e) {
      AppLogger.debug('Error creating document: $e');
      rethrow;
    }
  }
}

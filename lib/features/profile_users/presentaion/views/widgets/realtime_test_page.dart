import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:lklk/core/config/appwrite_config.dart';
import 'package:lklk/core/utils/logger.dart';

class RealtimeTestPage extends StatefulWidget {
  const RealtimeTestPage({super.key});

  @override
  State<RealtimeTestPage> createState() => _RealtimeTestPageState();
}

class _RealtimeTestPageState extends State<RealtimeTestPage>
    with WidgetsBindingObserver {
  final List<Map<String, dynamic>> documents = [];
  RealtimeSubscription? _subscription;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAppwrite();
  }

  Future<void> _initializeAppwrite() async {
    try {
      await AppwriteConfig.close();
      await AppwriteConfig.init();
      await _loadExistingDocuments();
      _initRealtime();
    } catch (e) {
      setState(() {
        _errorMessage = 'Initialization error: $e';
      });
      AppLogger.debug(_errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadExistingDocuments() async {
    try {
      final response = await AppwriteConfig.databases!.listDocuments(
        databaseId: '687d45af00221673b1c4',
        collectionId: '687d45d4000515f34e76',
        queries: [Query.limit(100)],
      );

      setState(() {
        documents.addAll(response.documents.map((doc) => doc.data));
      });
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        setState(() {
          _errorMessage = 'Permission denied. Check collection permissions.';
        });
      } else {
        setState(() {
          _errorMessage = 'Error loading documents: ${e.message}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
      });
    }
  }

  Future<void> _initRealtime() async {
    try {
      _subscription = AppwriteConfig.subscribe([
        'databases.687d45af00221673b1c4.collections.687d45d4000515f34e76.documents'
      ]);

      _subscription?.stream.listen((response) {
        if (response.events
            .contains('databases.*.collections.*.documents.*.create')) {
          setState(() {
            documents.add(response.payload);
          });
        }
      }, onError: (error) => AppLogger.debug('Realtime error: $error'));
    } catch (e) {
      AppLogger.debug('Realtime init error: $e');
    }
  }

  // دالة جديدة لإضافة بيانات تجريبية
  Future<void> _addTestData() async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final testData = {
        'message': 'Test message ${documents.length + 1}',
        'timestamp': timestamp,
        'sender': (1000 + documents.length).toString(),
      };

      await AppwriteConfig.databases!.createDocument(
        databaseId: '687d45af00221673b1c4',
        collectionId: '687d45d4000515f34e76',
        documentId: ID.unique(),
        data: testData,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add test data: $e'),
          backgroundColor: const Color(0xFFFF0000),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Realtime Test')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_errorMessage != null)
              ? Center(child: Text(_errorMessage!))
              : (documents.isEmpty)
                  ? const Center(child: Text('No documents found'))
                  : ListView.builder(
                      itemCount: documents.length,
                      reverse: false,
                      cacheExtent: 300,
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      addSemanticIndexes: false,
                      itemBuilder: (_, index) {
                        final doc = documents[index];
                        return RepaintBoundary(
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ExpansionTile(
                              title: Text(
                                  doc['message']?.toString() ?? 'No message'),
                              subtitle: Text("ID: ${doc['\$id']}"),
                              children: doc.entries.map((entry) {
                                return ListTile(
                                  title: Text(entry.key),
                                  subtitle:
                                      Text(entry.value?.toString() ?? 'null'),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
      // إضافة الزر العائم هنا
      floatingActionButton: FloatingActionButton(
        onPressed: _addTestData,
        tooltip: 'Add Test Data',
        child: const Icon(Icons.add),
      ),
    );
  }
}

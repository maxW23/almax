import 'dart:convert';

/// Decode a JSON string into a Map<String, dynamic> in an isolate.
Map<String, dynamic> decodeJsonToMapIsolate(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  if (decoded is Map) {
    // Ensure keys are strings
    return Map<String, dynamic>.from(
      decoded.map((k, v) => MapEntry(k.toString(), v)),
    );
  }
  throw const FormatException('JSON is not an object');
}

/// Decode a JSON string into a List<dynamic> in an isolate.
List<dynamic> decodeJsonToListIsolate(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is List) {
    return decoded;
  }
  if (decoded is Iterable) {
    return List<dynamic>.from(decoded);
  }
  throw const FormatException('JSON is not a list');
}

/// Generic JSON decode in an isolate. Returns JSON-compatible Dart structures.
dynamic decodeJsonDynamicIsolate(String raw) {
  return jsonDecode(raw);
}

/// Encode a Dart JSON-compatible structure (Map/List/primitive) into a JSON string in an isolate.
String encodeJsonIsolate(dynamic data) {
  return jsonEncode(data);
}

import 'dart:convert';

class InvitePerson {
  final int? id;
  final String? name;
  final String? userId; // invited user id (may be null)

  InvitePerson({this.id, this.name, this.userId});

  factory InvitePerson.fromMap(Map<String, dynamic> map) {
    return InvitePerson(
      id: _toIntSafe(map['id']),
      name: map['name']?.toString(),
      userId: map['user_id']?.toString(),
    );
  }

  static int? _toIntSafe(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static List<InvitePerson> listFromResponseBody(String body) {
    try {
      final parsed = jsonDecode(body);
      if (parsed is Map && parsed['peopel'] is List) {
        final list = (parsed['peopel'] as List)
            .whereType<dynamic>()
            .map((e) => InvitePerson.fromMap(_asMap(e)))
            .toList();
        return list;
      }
    } catch (_) {}
    return const <InvitePerson>[];
  }

  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }
}

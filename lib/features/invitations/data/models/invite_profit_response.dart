import 'dart:convert';

class InviteProfitResponse {
  final int people;
  final num profit;

  InviteProfitResponse({required this.people, required this.profit});

  factory InviteProfitResponse.fromJson(Map<String, dynamic> json) {
    // API screenshot shows key spelled as "peopel". Be defensive and accept variants.
    final dynamic peopleRaw = json['people'] ?? json['peopel'] ?? json['peopol'];
    final dynamic profitRaw = json['profit'] ?? json['profits'];

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    num parseNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? 0;
    }

    return InviteProfitResponse(
      people: parseInt(peopleRaw),
      profit: parseNum(profitRaw),
    );
  }

  static InviteProfitResponse fromResponseBody(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return InviteProfitResponse.fromJson(decoded);
      }
      // Some servers may return stringified map
      if (decoded is String) {
        final inner = json.decode(decoded);
        if (inner is Map<String, dynamic>) {
          return InviteProfitResponse.fromJson(inner);
        }
      }
      return InviteProfitResponse(people: 0, profit: 0);
    } catch (_) {
      return InviteProfitResponse(people: 0, profit: 0);
    }
  }
}

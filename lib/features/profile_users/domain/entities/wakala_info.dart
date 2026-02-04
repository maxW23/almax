class WakalaInfo {
  final String gold;
  final String? gift;
  final String wakelName;
  final String wakelId;
  final String wakalaName;
  final String diamond;

  WakalaInfo({
    required this.gold,
    required this.wakelName,
    required this.wakelId,
    required this.wakalaName,
    required this.diamond,
    this.gift,
  });

  factory WakalaInfo.fromJson(Map<String, dynamic> json) {
    return WakalaInfo(
      gold: json['gold'] ?? "",
      wakelName: json['wakel_name'] ?? "",
      wakelId: json['wakel_id'] ?? "",
      wakalaName: json['wakala_name'] ?? "",
      diamond: json['diamond'] ?? "",
      gift: json['gift'] ?? "",
    );
  }
}

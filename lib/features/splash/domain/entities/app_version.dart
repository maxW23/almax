class AppVersionInfo {
  final int numb;
  final int version;
  final String response;

  AppVersionInfo({
    required this.numb,
    required this.version,
    required this.response,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      numb: json['numb'] ?? 0,
      version: json['version'] ?? 0,
      response: json['response'] ?? '',
    );
  }
}

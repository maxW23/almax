class PostCharger {
  final int id;
  final String name;
  final String? number;
  final int wallet;
  final String? country;
  final String? img;

  PostCharger({
    required this.id,
    required this.name,
    required this.wallet,
    this.number,
    this.country,
    this.img,
  });

  factory PostCharger.fromJson(Map<String, dynamic> json) {
    return PostCharger(
      id: json['id'],
      name: json['name'] ?? '',
      number: json['number'],
      wallet: json['wallet'] ?? 0,
      country: json['country'],
      img: json['img'],
    );
  }
}

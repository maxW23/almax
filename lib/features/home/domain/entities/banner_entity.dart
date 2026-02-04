class BannerModel {
  final int? id;
  final String? titel;
  final String? img;
  final String? link;

  BannerModel({
    this.id,
    this.titel,
    this.img,
    this.link,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int, // Correct: string key 'id'
      titel: json['titel'] as String,
      img: json['img'] as String,
      link: json['link']
          as String, // Ensure 'link' is String if API returns it as String
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titel': titel,
      'img': img,
      'link': link,
    };
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class RoomEntity {
  final int id;
  final String name;
  final String background;
  final String img;
  final String country;
  final String helloText;
  final String microphoneNumber;
  final String owner;
  final String? type;
  final String? pass;
  final String? coin;
  final String? fire;
  final String? topvalues;
  final String? isFavourite;

  // Presentation fields for list item design
  final String? ic;
  final String? back;
  final String? frame;
  final String? color1;
  final String? color2;
  final String? word;

  RoomEntity(
      {required this.id,
      required this.name,
      required this.background,
      required this.img,
      required this.country,
      required this.helloText,
      required this.microphoneNumber,
      required this.owner,
      this.type,
      this.pass,
      this.topvalues,
      this.coin,
      this.isFavourite,
      this.fire,
      this.ic,
      this.back,
      this.frame,
      this.color1,
      this.color2,
      this.word});

  RoomEntity copyWith({
    int? id,
    String? name,
    String? background,
    String? img,
    String? country,
    String? helloText,
    String? microphoneNumber,
    String? owner,
    String? type,
    String? pass,
    String? coin,
    String? fire,
    String? isFavourite,
    String? topvalues,
    String? ic,
    String? back,
    String? frame,
    String? color1,
    String? color2,
    String? word,
  }) {
    return RoomEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        background: background ?? this.background,
        img: img ?? this.img,
        country: country ?? this.country,
        helloText: helloText ?? this.helloText,
        microphoneNumber: microphoneNumber ?? this.microphoneNumber,
        owner: owner ?? this.owner,
        type: type ?? this.type,
        pass: pass ?? this.pass,
        fire: fire ?? this.fire,
        topvalues: topvalues ?? this.topvalues,
        isFavourite: isFavourite ?? this.isFavourite,
        coin: coin ?? this.coin,
        ic: ic ?? this.ic,
        back: back ?? this.back,
        frame: frame ?? this.frame,
        color1: color1 ?? this.color1,
        color2: color2 ?? this.color2,
        word: word ?? this.word);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'background': background,
      'img': img,
      'country': country,
      'helloText': helloText,
      'microphoneNumber': microphoneNumber,
      'owner': owner,
      'type': type,
      'pass': pass,
      'coin': coin,
      'fire': fire,
      'topvalues': topvalues,
      'isFavourite': isFavourite,
      'ic': ic,
      'back': back,
      'frame': frame,
      'color1': color1,
      'color2': color2,
      'word': word,
    };
  }

  factory RoomEntity.fromMap(Map<String, dynamic> map) {
    return RoomEntity(
      id: map['id'] as int,
      name: map['name'].toString(),
      background: map['background'].toString(),
      img: map['img'].toString(),
      country: map['country'].toString(),
      helloText: map['hello_text'].toString(),
      microphoneNumber: map['microphone_number'].toString(),
      owner: map['owner'].toString(),
      type: map['type']?.toString(),
      pass: map['pass']?.toString(),
      coin: map['coin']?.toString(),
      fire: map['fire']?.toString(),
      topvalues: map['topvalues']?.toString(),
      isFavourite: map['isFavourite']?.toString(),
      ic: map['ic']?.toString(),
      back: map['back']?.toString(),
      frame: map['frame']?.toString(),
      color1: (map['color1'] ?? map['color_1'])?.toString(),
      color2: (map['color2'] ?? map['color_2'])?.toString(),
      word: map['word']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  // factory RoomEntity.fromJson(String source) => RoomEntity.fromMap(json.decode(source) as Map<String, dynamic>);
  factory RoomEntity.fromJson(Map<String, dynamic> source) {
    return RoomEntity(
      id: source['id'] as int,
      name: source['name'].toString(),
      background: source['background'].toString(),
      img: source['img'].toString(),
      country: source['country'].toString(),
      helloText: source['hello_text'].toString(),
      microphoneNumber: source['microphone_number'].toString(),
      owner: source['owner'].toString(),
      type: source['type']?.toString(),
      pass: source['pass']?.toString(),
      coin: source['coin']?.toString(),
      fire: source['fire']?.toString(),
      isFavourite: source['isFavourite']?.toString(),
      topvalues: source['topvalues']?.toString(),
      ic: source['ic']?.toString(),
      back: source['back']?.toString(),
      frame: source['frame']?.toString(),
      color1: (source['color1'] ?? source['color_1'])?.toString(),
      color2: (source['color2'] ?? source['color_2'])?.toString(),
      word: source['word']?.toString(),
    );
  }

  @override
  String toString() {
    return 'RoomEntity(id: $id, name: $name, background: $background, img: $img, country: $country, helloText: $helloText, microphoneNumber: $microphoneNumber, owner: $owner, type: $type, pass: $pass,coin:$coin,fire:$fire,topvalues:$topvalues,isFavourite:$isFavourite,ic:$ic,back:$back,frame:$frame,color1:$color1,color2:$color2,word:$word)';
  }

  @override
  bool operator ==(covariant RoomEntity other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.background == background &&
        other.img == img &&
        other.country == country &&
        other.helloText == helloText &&
        other.microphoneNumber == microphoneNumber &&
        other.owner == owner &&
        other.type == type &&
        other.coin == coin &&
        other.fire == fire &&
        other.topvalues == topvalues &&
        other.isFavourite == isFavourite &&
        other.pass == pass &&
        other.ic == ic &&
        other.back == back &&
        other.frame == frame &&
        other.color1 == color1 &&
        other.color2 == color2 &&
        other.word == word;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        background.hashCode ^
        img.hashCode ^
        country.hashCode ^
        helloText.hashCode ^
        microphoneNumber.hashCode ^
        owner.hashCode ^
        type.hashCode ^
        coin.hashCode ^
        fire.hashCode ^
        topvalues.hashCode ^
        isFavourite.hashCode ^
        pass.hashCode ^
        ic.hashCode ^
        back.hashCode ^
        frame.hashCode ^
        color1.hashCode ^
        color2.hashCode ^
        word.hashCode;
  }
}

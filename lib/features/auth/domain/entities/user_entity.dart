// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lklk/features/home/domain/entities/avatar_data_zego.dart';
import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';

part 'user_entity.g.dart';

@HiveType(typeId: 2)
class UserEntity {
  @HiveField(0)
  String iduser;

  @HiveField(1)
  String? id;

  @HiveField(2)
  String? name;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? img;

  @HiveField(5)
  String? banned;

  @HiveField(6)
  String? type;

  @HiveField(7)
  String? pin;

  @HiveField(8)
  String? email_verified_at;

  @HiveField(9)
  String? created_at;

  @HiveField(10)
  String? updated_at;

  @HiveField(11)
  String? idd;

  @HiveField(12)
  String? birth;

  @HiveField(13)
  String? profile_state;

  @HiveField(14)
  String? statuse;

  @HiveField(15)
  String? level1;

  @HiveField(16)
  String? gender;

  @HiveField(17)
  String? charger_country;

  @HiveField(18)
  String? country;

  @HiveField(19)
  int? wallet;

  @HiveField(20)
  String? stringid;

  @HiveField(21)
  String? friend;

  @HiveField(22)
  String? idrelation;

  @HiveField(23)
  String? imgrelation;

  @HiveField(24)
  String? vip;

  @HiveField(25)
  String? monLevel;

  @HiveField(26)
  String? target;

  // New target value for target screen (non-Hive cached)
  String? target2;

  @HiveField(27)
  num? diamond;

  @HiveField(28)
  String? giftCount;

  @HiveField(29)
  String? namerelation;

  @HiveField(30)
  String? number;

  @HiveField(31)
  ElementEntity? elementFrame;

  @HiveField(32)
  String? level2;

  @HiveField(33)
  String? idColor;

  @HiveField(34)
  String? idColorTwo;

  @HiveField(35)
  String? rmonLevelTwo;

  @HiveField(36)
  String? display;

  @HiveField(37)
  String? giftRecive;

  @HiveField(38)
  String? giftSend;

  @HiveField(39)
  String? wakalaName;
  @HiveField(40)
  String? entryID;

  @HiveField(41)
  String? entryTimer;
  @HiveField(42)
  List<String>? ownerIds;

  @HiveField(43)
  List<String>? adminRoomIds;
  @HiveField(44)
  String? totalSocre;
  @HiveField(45)
  String? howManyTime;
  @HiveField(46)
  String? type1;
  @HiveField(47)
  String? newType;
  @HiveField(48)
  String? show_gift; // حالة عرض الهدايا

  @HiveField(49)
  String? new_img; // صورة جديدة

  @HiveField(50)
  String? timer; // مؤقت

  @HiveField(51)
  String? entrylink; // رابط الدخول

  // أيقونات (ic1 إلى ic15)
  @HiveField(52)
  String? ic1;
  @HiveField(53)
  String? ic2;
  @HiveField(54)
  String? ic3;
  @HiveField(55)
  String? ic4;
  @HiveField(56)
  String? ic5;
  @HiveField(57)
  String? ic6;
  @HiveField(58)
  String? ic7;
  @HiveField(59)
  String? ic8;
  @HiveField(60)
  String? ic9;
  @HiveField(61)
  String? ic10;
  @HiveField(62)
  String? ic11;
  @HiveField(63)
  String? ic12;
  @HiveField(64)
  String? ic13;
  @HiveField(65)
  String? ic14;
  @HiveField(66)
  String? ic15;

  // حقول غير معروفة (ws1 إلى ws5)
  @HiveField(67)
  String? ws1;
  @HiveField(68)
  String? ws2;
  @HiveField(69)
  String? ws3;
  @HiveField(70)
  String? ws4;
  @HiveField(71)
  String? ws5;
  @HiveField(72)
  String? power;
  @HiveField(73)
  String? level3; // عدد النقاط الحالية
  @HiveField(74)
  String? newlevel3; // نقاط المستوى التالي
  @HiveField(75)
  String? mon; // مثل "5.6M"
  @HiveField(76)
  String? point; // مثل "5488"
  @HiveField(77)
  String? worp; // حالة مثل "w"
  @HiveField(78)
  String? entryimg; // صورة الدخول
  @HiveField(79)
  String? ip; // عنوان IP
  @HiveField(80)
  String? imei; // معرف الجهاز
  // الحقول التالية لا يتم تخزينها في Hive
  // New fields
  String roomID = '';
  String? streamID;
  int viewID = -1;
  ValueNotifier<Widget?> videoViewNotifier = ValueNotifier(null);
  ValueNotifier<bool> isCameraOnNotifier = ValueNotifier(false);
  ValueNotifier<bool> isUsingSpeaker = ValueNotifier(true);
  ValueNotifier<bool> isMicOnNotifier = ValueNotifier(false);
  ValueNotifier<bool> isUsingFrontCameraNotifier = ValueNotifier(true);
  ValueNotifier<String?> avatarUrlNotifier;
  ValueNotifier<String?> framePathNotifier;
  ValueNotifier<String?> nameUser;
  ValueNotifier<String?> userImage = ValueNotifier(null);
  // Non-Hive: total spent score
  String? totalSpent; // from total_spent

  UserEntity({
    required this.iduser,
    this.id,
    this.name,
    this.email,
    this.img,
    this.banned,
    this.type,
    this.pin,
    this.email_verified_at,
    this.created_at,
    this.updated_at,
    this.idd,
    this.birth,
    this.profile_state,
    this.statuse,
    this.level1,
    this.gender,
    this.charger_country,
    this.country,
    this.wallet,
    this.stringid,
    this.friend,
    this.idrelation,
    this.imgrelation,
    this.vip,
    this.monLevel,
    this.target,
    this.target2,
    this.diamond,
    this.namerelation,
    this.number,
    this.elementFrame,
    this.level2,
    this.level3,
    this.newlevel3,
    this.idColor,
    this.idColorTwo,
    this.rmonLevelTwo,
    this.display,
    this.giftCount,
    this.giftSend,
    this.giftRecive,
    this.totalSocre,
    this.newType,
    this.howManyTime,
    this.type1,
    this.wakalaName,
    // New fields
    this.streamID,
    this.entryID,
    this.entryTimer,
    this.ownerIds,
    this.adminRoomIds,
    this.show_gift,
    this.new_img,
    this.timer,
    this.entrylink,
    this.ic1,
    this.ic2,
    this.ic3,
    this.ic4,
    this.ic5,
    this.ic6,
    this.ic7,
    this.ic8,
    this.ic9,
    this.ic10,
    this.ic11,
    this.ic12,
    this.ic13,
    this.ic14,
    this.ic15,
    this.ws1,
    this.ws2,
    this.ws3,
    this.ws4,
    this.ws5,
    this.power,
    this.mon,
    this.point,
    this.totalSpent,
    this.worp,
    this.entryimg,
    this.ip,
    this.imei,
    String? avatarUrl,
    String? nameUser,
    String? framePath,
  })  : avatarUrlNotifier = ValueNotifier(avatarUrl),
        nameUser = ValueNotifier(nameUser),
        framePathNotifier = ValueNotifier(framePath);

  // Updated toJson method
  Map<String, dynamic> toMap() {
    return {
      'iduser': iduser,
      'id': id,
      'name': name,
      'email': email,
      'img': img,
      'banned': banned,
      'type': type,
      'pin': pin,
      'email_verified_at': email_verified_at,
      'created_at': created_at,
      'updated_at': updated_at,
      'idd': idd,
      'birth': birth,
      'profile_state': profile_state,
      'statuse': statuse,
      'level': level1,
      'gender': gender,
      'charger_country': charger_country,
      'country': country,
      'wallet': wallet,
      'stringid': stringid,
      'friend': friend,
      'idrelation': idrelation,
      'imgrelation': imgrelation,
      'vip': vip,
      'monLevel': monLevel,
      'target': target,
      'target2': target2,
      'diamond': diamond,
      'namerelation': namerelation,
      'number': number,
      'giftRecive': giftRecive,
      'giftSend': giftSend,
      // 'elementFrame': elementFrame,
      'elementFrame': elementFrame?.toMap(), // Updated to use toMap
      'level2': level2,
      'level3': level3,
      'newlevel3': newlevel3,
      'idColor': idColor,
      'idColorTwo': idColorTwo,
      'rmonLevelTwo': rmonLevelTwo,
      'display': display,
      'streamID': streamID,
      'roomID': roomID,
      'viewID': viewID,
      'avatarUrl': avatarUrlNotifier.value,
      'nameUser': nameUser.value,
      'framePath': framePathNotifier.value,
      'userImage': userImage.value,
      'isCameraOn': isCameraOnNotifier.value,
      'isMicOn': isMicOnNotifier.value,
      'isUsingSpeaker': isUsingSpeaker.value,
      'isUsingFrontCamera': isUsingFrontCameraNotifier.value,
      'videoView': videoViewNotifier.value?.toString(),
      'giftCount': giftCount,
      'totalSocre': totalSocre,
      'howManyTime': howManyTime,
      'type1': type1,
      'newType': newType,
      'wakalaName': wakalaName,
      'entryID': entryID,
      'entryTimer': entryTimer,
      'owner_ids': ownerIds,
      'admin_room_ids': adminRoomIds,
      // ... الحقول الحالية ...
      'show_gift': show_gift,
      'new_img': new_img,
      'timer': timer,
      'entrylink': entrylink,
      'ic1': ic1,
      'ic2': ic2,
      'ic3': ic3,
      'ic4': ic4,
      'ic5': ic5,
      'ic6': ic6,
      'ic7': ic7,
      'ic8': ic8,
      'ic9': ic9,
      'ic10': ic10,
      'ic11': ic11,
      'ic12': ic12,
      'ic13': ic13,
      'ic14': ic14,
      'ic15': ic15,
      'ws1': ws1,
      'ws2': ws2,
      'ws3': ws3,
      'ws4': ws4,
      'ws5': ws5,
      'power': power,
      'mon': mon,
      'point': point,
      'worp': worp,
      'entryimg': entryimg,
      'ip': ip,
      'imei': imei,
    };
  }

  String toJson() => json.encode(toMap());

  // Updated toString method
  @override
  @override
  String toString() {
    return '''
UserEntity {
    iduser: $iduser,
    id: $id,
    name: $name,
    email: $email,
    img: $img,
    banned: $banned,
    type: $type,
    pin: $pin,
    email_verified_at: $email_verified_at,
    created_at: $created_at,
    updated_at: $updated_at,
    idd: $idd,
    birth: $birth,
    profile_state: $profile_state,
    statuse: $statuse,
    level: $level1,
    gender: $gender,
    charger_country: $charger_country,
    country: $country,
    wallet: $wallet,
    stringid: $stringid,
    friend: $friend,
    idrelation: $idrelation,
    imgrelation: $imgrelation,
    vip: $vip,
    monLevel: $monLevel,
    target: $target,
    diamond: $diamond,
    namerelation: $namerelation,
    number: $number,
    elementFrame: ${elementFrame?.toString()},
    level2: $level2,
    idColor: $idColor,
    idColorTwo: $idColorTwo,
    rmonLevelTwo: $rmonLevelTwo,
    level3: $level3,
    newlevel3: $newlevel3,
    display: $display,
    giftRecive: $giftRecive,
    giftSend: $giftSend,
    wakalaName: $wakalaName,
    entryID: $entryID,
    entryTimer: $entryTimer,
    ownerIds: ${ownerIds?.join(', ')},
    adminRoomIds: ${adminRoomIds?.join(', ')},
    totalSocre: $totalSocre,
    howManyTime: $howManyTime,
    type1: $type1,
    newType: $newType,
    giftCount: $giftCount,
    
    // Non-Hive fields
    roomID: $roomID,
    streamID: $streamID,
    viewID: $viewID,
    avatarUrl: ${avatarUrlNotifier.value},
    nameUser: ${nameUser.value},
    framePath: ${framePathNotifier.value},
    userImage: ${userImage.value},
    isCameraOn: ${isCameraOnNotifier.value},
    isMicOn: ${isMicOnNotifier.value},
    isUsingSpeaker: ${isUsingSpeaker.value},
    isUsingFrontCamera: ${isUsingFrontCameraNotifier.value},
    videoView: ${videoViewNotifier.value},
    
    show_gift: $show_gift,
    new_img: $new_img,
    timer: $timer,
    entrylink: $entrylink,
    ic1: $ic1,
    ic2: $ic2,
    ic3: $ic3,
    ic4: $ic4,
    ic5: $ic5,
    ic6: $ic6,
    ic7: $ic7,
    ic8: $ic8,
    ic9: $ic9,
    ic10: $ic10,
    ic11: $ic11,
    ic12: $ic12,
    ic13: $ic13,
    ic14: $ic14,
    ic15: $ic15,
    ws1: $ws1,
    ws2: $ws2,
    ws3: $ws3,
    ws4: $ws4,
    ws5: $ws5,
      power: $power,
  }''';
  }

  factory UserEntity.fromGoogleSignIn(GoogleSignInAccount googleUser) {
    return UserEntity(
      iduser: googleUser.id,
      name: googleUser.displayName ?? "",
      email: googleUser.email,
      img: googleUser.photoUrl ?? "",
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> source) {
    return UserEntity(
      iduser: (source['iduser']).toString(),
      id: (source['id']).toString(),
      name: source['name'].toString(),
      email: source['email'].toString(),
      type: source['type'].toString(),
      banned: source['banned'].toString(),
      birth: source['birth'].toString(),
      charger_country: source['charger_country'].toString(),
      country: source['country'].toString(),
      created_at: source['created_at'].toString(),
      email_verified_at: source['email_verified_at'].toString(),
      gender: source['gender'].toString(),
      idd: source['idd'].toString(),
      img: source['img'].toString(),
      level1: source['level'].toString(),
      pin: source['pin'].toString(),
      profile_state: source['profile_state'].toString(),
      statuse: source['statuse'].toString(),
      updated_at: source['updated_at'].toString(),
      // wallet: source['wallet'] as int?,
      wallet: source['wallet'] != null
          ? int.tryParse(source['wallet'].toString())
          : null,

      stringid: source['stringid'].toString(),
      friend: source['friend'].toString(),
      idrelation: source['idrelation'].toString(),
      imgrelation: source['imgrelation'].toString(),
      diamond: source['diamond'] != null
          ? num.tryParse(source['diamond'].toString()) // Changed to double
          : null,
      monLevel: source['mon'].toString(),
      namerelation: source['namerelation'].toString(),
      target: source['target'].toString(),
      target2: source['target2']?.toString(),
      vip: source['vip'].toString(),
      idColor: source['id_color'].toString(),
      level2: source['level2'].toString(),
      level3: source['level3']?.toString(),
      newlevel3: source['newlevel3']?.toString(),
      number: source['number'].toString(),
      //  elementFrame: elementFrame?.toMap(), // Updated to use toMap
      elementFrame: source['frame'] != null
          ? ElementEntity.fromJson(source['frame'] as Map<String, dynamic>)
          : null,
      idColorTwo: source['idcolor2'].toString(),
      rmonLevelTwo: source['rmon'].toString(),
      display: source['display'].toString(),
      avatarUrl: source['img'].toString(),
      nameUser: source['name'].toString(),
      framePath: (source['frame'] != null && source['frame']['link'] != null)
          ? source['frame']['link'].toString()
          : null,
      giftSend: source['gift_send'].toString(),
      giftRecive: source['gift_recive'].toString(),
      giftCount: source['gift_count']?.toString(),
      totalSocre: source['total_score']?.toString(),
      howManyTime: source['how_many_time']?.toString(),
      type1: source['type1']?.toString(),
      newType: source['new_type']?.toString(),
      wakalaName: source['wakala_name']?.toString(),
      entryID: source['entryID']?.toString(),
      entryTimer: source['entrytimer']?.toString(),
      // ... الحقول الحالية ...
      ownerIds:
          (source['owner'] as List?)?.map((e) => e.toString()).toList() ?? [],

      adminRoomIds:
          (source['room_admin'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      // ... بقية الحقول ...
      // ... تعيين الحقول الحالية ...
      show_gift: source['show_gift']?.toString(),
      new_img: source['new_img']?.toString(),
      timer: source['timer']?.toString(),
      entrylink: source['entrylink']?.toString(),
      ic1: source['ic1']?.toString(),
      ic2: source['ic2']?.toString(),
      ic3: source['ic3']?.toString(),
      ic4: source['ic4']?.toString(),
      ic5: source['ic5']?.toString(),
      ic6: source['ic6']?.toString(),
      ic7: source['ic7']?.toString(),
      ic8: source['ic8']?.toString(),
      ic9: source['ic9']?.toString(),
      ic10: source['ic10']?.toString(),
      ic11: source['ic11']?.toString(),
      ic12: source['ic12']?.toString(),
      ic13: source['ic13']?.toString(),
      ic14: source['ic14']?.toString(),
      ic15: source['ic15']?.toString(),
      ws1: source['ws1']?.toString(),
      ws2: source['ws2']?.toString(),
      ws3: source['ws3']?.toString(),
      ws4: source['ws4']?.toString(),
      ws5: source['ws5']?.toString(),
      mon: source['mon']?.toString(),
      point: source['point']?.toString(),
      totalSpent: source['total_spent']?.toString(),
      worp: source['worp']?.toString(),
      entryimg: source['entryimg']?.toString(),
      ip: source['ip']?.toString(),
      imei: source['imei']?.toString(),
      power: source['power']?.toString(),
    );
  }
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      iduser: map['iduser'].toString(),
      id: map['id'].toString(),
      name: map['name'].toString(),
      email: map['email'].toString(),
      img: map['img']?.toString(),
      banned: map['banned']?.toString(),
      type: map['type']?.toString(),
      pin: map['pin']?.toString(),
      email_verified_at: map['email_verified_at']?.toString(),
      created_at: map['created_at']?.toString(),
      updated_at: map['updated_at']?.toString(),
      idd: map['idd']?.toString(),
      birth: map['birth']?.toString(),
      profile_state: map['profile_state']?.toString(),
      statuse: map['statuse']?.toString(),
      level1: map['level']?.toString(),
      level2: map['level2']?.toString(),
      level3: map['level3']?.toString(),
      newlevel3: map['newlevel3']?.toString(),
      gender: map['gender']?.toString(),
      charger_country: map['charger_country']?.toString(),
      country: map['country']?.toString(),
      wallet: map['wallet'] != null ? map['wallet'] as int : null,
      stringid: map['stringid']?.toString(),
      friend: map['friend']?.toString(),
      imgrelation: map['imgrelation']?.toString(),
      idrelation: map['idrelation']?.toString(),
      diamond: map['diamond'] != null
          ? num.tryParse(map['diamond'].toString())
          : null,
      monLevel: map['mon']?.toString(),
      namerelation: map['namerelation']?.toString(),
      target: map['target']?.toString(),
      target2: map['target2']?.toString(),
      vip: map['vip']?.toString(),
      number: map['number']?.toString(),
      display: map['display']?.toString(),
      avatarUrl: map['img']?.toString(),
      nameUser: map['name']?.toString(),
      framePath: (map['frame'] != null && map['frame']['link'] != null)
          ? map['frame']['link'].toString()
          : null,
      giftCount: map['gift_count']?.toString(),
      giftRecive: map['gift_recive']?.toString(),
      giftSend: map['gift_send']?.toString(),
      totalSocre: map['total_score']?.toString(),
      howManyTime: map['how_many_time']?.toString(),
      type1: map['type1']?.toString(),
      newType: map['new_type']?.toString(),
      wakalaName: map['wakala_name']?.toString(),
      entryID: map['entryID']?.toString(),
      entryTimer: map['entrytimer']?.toString(),
      ownerIds: (map['owner'] is List)
          ? (map['owner'] as List)
              .map((e) => e['id']?.toString() ?? '')
              .toList()
          : null,
      adminRoomIds: (map['room_admin'] is List)
          ? (map['room_admin'] as List)
              .map((e) => e['room_id']?.toString() ?? '')
              .toList()
          : null,
      mon: map['mon']?.toString(),
      point: map['point']?.toString(),
      totalSpent: map['total_spent']?.toString(),
      worp: map['worp']?.toString(),
      entryimg: map['entryimg']?.toString(),
      ip: map['ip']?.toString(),
      imei: map['imei']?.toString(),
      power: map['power']?.toString(),
    );
  }
  UserEntity copyWith({
    String? iduser,
    String? id,
    String? name,
    String? email,
    String? img,
    String? banned,
    String? type,
    String? pin,
    String? email_verified_at,
    String? created_at,
    String? updated_at,
    String? idd,
    String? birth,
    String? profile_state,
    String? statuse,
    String? level1,
    String? gender,
    String? charger_country,
    String? country,
    int? wallet,
    String? stringid,
    String? friend,
    String? idrelation,
    String? imgrelation,
    String? vip,
    String? monLevel,
    String? target,
    String? target2,
    num? diamond,
    String? giftCount,
    String? namerelation,
    String? number,
    ElementEntity? elementFrame,
    String? level2,
    String? level3,
    String? newlevel3,
    String? idColor,
    String? idColorTwo,
    String? rmonLevelTwo,
    String? display,
    String? giftRecive,
    String? giftSend,
    String? wakalaName,
    String? entryID,
    String? entryTimer,
    List<String>? ownerIds,
    List<String>? adminRoomIds,
    String? totalSocre,
    String? howManyTime,
    String? type1,
    String? newType,
    String? show_gift,
    String? new_img,
    String? timer,
    String? entrylink,
    String? ic1,
    String? ic2,
    String? ic3,
    String? ic4,
    String? ic5,
    String? ic6,
    String? ic7,
    String? ic8,
    String? ic9,
    String? ic10,
    String? ic11,
    String? ic12,
    String? ic13,
    String? ic14,
    String? ic15,
    String? ws1,
    String? ws2,
    String? ws3,
    String? ws4,
    String? ws5,
    String? power,
    String? totalSpent,
    // الحقول غير المخزنة في Hive
    String? roomID,
    String? streamID,
    int? viewID,
    ValueNotifier<Widget?>? videoViewNotifier,
    ValueNotifier<bool>? isCameraOnNotifier,
    ValueNotifier<bool>? isUsingSpeaker,
    ValueNotifier<bool>? isMicOnNotifier,
    ValueNotifier<bool>? isUsingFrontCameraNotifier,
    ValueNotifier<String?>? avatarUrlNotifier,
    ValueNotifier<String?>? framePathNotifier,
    ValueNotifier<String?>? nameUser,
    ValueNotifier<String?>? userImage,
  }) {
    return UserEntity(
      iduser: iduser ?? this.iduser,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      img: img ?? this.img,
      banned: banned ?? this.banned,
      type: type ?? this.type,
      pin: pin ?? this.pin,
      email_verified_at: email_verified_at ?? this.email_verified_at,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      idd: idd ?? this.idd,
      birth: birth ?? this.birth,
      profile_state: profile_state ?? this.profile_state,
      statuse: statuse ?? this.statuse,
      level1: level1 ?? this.level1,
      gender: gender ?? this.gender,
      charger_country: charger_country ?? this.charger_country,
      country: country ?? this.country,
      wallet: wallet ?? this.wallet,
      stringid: stringid ?? this.stringid,
      friend: friend ?? this.friend,
      idrelation: idrelation ?? this.idrelation,
      imgrelation: imgrelation ?? this.imgrelation,
      vip: vip ?? this.vip,
      monLevel: monLevel ?? this.monLevel,
      target: target ?? this.target,
      target2: target2 ?? this.target2,
      diamond: diamond ?? this.diamond,
      namerelation: namerelation ?? this.namerelation,
      number: number ?? this.number,
      elementFrame: elementFrame ?? this.elementFrame,
      level2: level2 ?? this.level2,
      level3: level3 ?? this.level3,
      newlevel3: newlevel3 ?? this.newlevel3,
      idColor: idColor ?? this.idColor,
      idColorTwo: idColorTwo ?? this.idColorTwo,
      rmonLevelTwo: rmonLevelTwo ?? this.rmonLevelTwo,
      display: display ?? this.display,
      giftRecive: giftRecive ?? this.giftRecive,
      giftSend: giftSend ?? this.giftSend,
      wakalaName: wakalaName ?? this.wakalaName,
      entryID: entryID ?? this.entryID,
      entryTimer: entryTimer ?? this.entryTimer,
      ownerIds: ownerIds ?? this.ownerIds,
      adminRoomIds: adminRoomIds ?? this.adminRoomIds,
      totalSocre: totalSocre ?? this.totalSocre,
      howManyTime: howManyTime ?? this.howManyTime,
      type1: type1 ?? this.type1,
      newType: newType ?? this.newType,
      giftCount: giftCount ?? this.giftCount,
      show_gift: show_gift ?? this.show_gift,
      new_img: new_img ?? this.new_img,
      timer: timer ?? this.timer,
      entrylink: entrylink ?? this.entrylink,
      ic1: ic1 ?? this.ic1,
      ic2: ic2 ?? this.ic2,
      ic3: ic3 ?? this.ic3,
      ic4: ic4 ?? this.ic4,
      ic5: ic5 ?? this.ic5,
      ic6: ic6 ?? this.ic6,
      ic7: ic7 ?? this.ic7,
      ic8: ic8 ?? this.ic8,
      ic9: ic9 ?? this.ic9,
      ic10: ic10 ?? this.ic10,
      ic11: ic11 ?? this.ic11,
      ic12: ic12 ?? this.ic12,
      ic13: ic13 ?? this.ic13,
      ic14: ic14 ?? this.ic14,
      ic15: ic15 ?? this.ic15,
      ws1: ws1 ?? this.ws1,
      ws2: ws2 ?? this.ws2,
      ws3: ws3 ?? this.ws3,
      ws4: ws4 ?? this.ws4,
      ws5: ws5 ?? this.ws5,
      power: power ?? this.power,
      totalSpent: totalSpent ?? this.totalSpent,
      avatarUrl: avatarUrlNotifier?.value ?? this.avatarUrlNotifier.value,
      nameUser: nameUser?.value ?? this.nameUser.value,
      framePath: framePathNotifier?.value ?? this.framePathNotifier.value,
    )
      ..roomID = roomID ?? this.roomID
      ..streamID = streamID ?? this.streamID
      ..viewID = viewID ?? this.viewID
      ..videoViewNotifier = videoViewNotifier ?? this.videoViewNotifier
      ..isCameraOnNotifier = isCameraOnNotifier ?? this.isCameraOnNotifier
      ..isUsingSpeaker = isUsingSpeaker ?? this.isUsingSpeaker
      ..isMicOnNotifier = isMicOnNotifier ?? this.isMicOnNotifier
      ..isUsingFrontCameraNotifier =
          isUsingFrontCameraNotifier ?? this.isUsingFrontCameraNotifier
      ..userImage = userImage ?? this.userImage;
  }

  @override
  bool operator ==(covariant UserEntity other) {
    if (identical(this, other)) return true;

    return other.iduser == iduser &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.img == img &&
        other.banned == banned &&
        other.type == type &&
        other.pin == pin &&
        other.email_verified_at == email_verified_at &&
        other.created_at == created_at &&
        other.updated_at == updated_at &&
        other.idd == idd &&
        other.birth == birth &&
        other.profile_state == profile_state &&
        other.statuse == statuse &&
        other.level1 == level1 &&
        other.gender == gender &&
        other.charger_country == charger_country &&
        other.country == country &&
        other.wallet == wallet &&
        other.stringid == stringid &&
        other.friend == friend &&
        other.idrelation == idrelation &&
        other.imgrelation == imgrelation &&
        other.display == display &&
        other.giftCount == giftCount &&
        other.giftRecive == giftRecive &&
        other.totalSocre == totalSocre &&
        other.giftSend == giftSend &&
        other.newType == newType &&
        other.howManyTime == howManyTime &&
        other.type1 == type1 &&
        other.wakalaName == wakalaName &&
        other.entryID == entryID &&
        other.entryTimer == entryTimer &&
        other.power == power &&
        other.diamond == diamond;
  }

  factory UserEntity.fromString(String jsonString) {
    final Map<String, dynamic> source = json.decode(jsonString);
    return UserEntity.fromJson(source);
  }
  @override
  int get hashCode {
    return iduser.hashCode ^
        id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        img.hashCode ^
        banned.hashCode ^
        type.hashCode ^
        pin.hashCode ^
        email_verified_at.hashCode ^
        created_at.hashCode ^
        updated_at.hashCode ^
        idd.hashCode ^
        totalSocre.hashCode ^
        birth.hashCode ^
        profile_state.hashCode ^
        statuse.hashCode ^
        level1.hashCode ^
        gender.hashCode ^
        charger_country.hashCode ^
        country.hashCode ^
        wallet.hashCode ^
        stringid.hashCode ^
        friend.hashCode ^
        idrelation.hashCode ^
        imgrelation.hashCode ^
        display.hashCode ^
        giftCount.hashCode ^
        giftRecive.hashCode ^
        giftRecive.hashCode ^
        newType.hashCode ^
        howManyTime.hashCode ^
        type1.hashCode ^
        wakalaName.hashCode ^
        entryID.hashCode ^
        entryTimer.hashCode ^
        power.hashCode ^
        diamond.hashCode;
  }

  // في ملف user_entity.dart
  factory UserEntity.fromAvatarData(
    String encodedAvatarData, {
    required String userId,
    required String userName,
    String? streamID,
    int viewID = -1,
    bool isCameraOn = false,
    bool isMicOn = false,
    bool isUsingSpeaker = true,
    bool isUsingFrontCamera = true,
  }) {
    final avatarData = AvatarData.fromEncodedString(encodedAvatarData);

    return UserEntity(
      iduser: userId,
      id: userId,
      name: userName,
      img: avatarData.imageUrl,
      vip: avatarData.vipLevel,
      entryID: avatarData.entryID,
      entryTimer: avatarData.entryTimer,
      ownerIds: avatarData.ownerIds,
      adminRoomIds: avatarData.adminRoomIds,
      totalSocre: avatarData.totalSocre,
      level1: avatarData.level1,
      level2: avatarData.level2,
      // AvatarData.level3 carries displayed level now
      newlevel3: avatarData.newlevel3,
      elementFrame: avatarData.frameId != null
          ? ElementEntity(elamentId: avatarData.frameId)
          : null,
      // SVGA urls mapped if present
      ws1: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.isNotEmpty)
          ? avatarData.svgaSquareUrls![0]
          : null,
      ws2: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 1)
          ? avatarData.svgaSquareUrls![1]
          : null,
      ws3: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 2)
          ? avatarData.svgaSquareUrls![2]
          : null,
      ws4: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 3)
          ? avatarData.svgaSquareUrls![3]
          : null,
      ws5: (avatarData.svgaSquareUrls != null && avatarData.svgaSquareUrls!.length > 4)
          ? avatarData.svgaSquareUrls![4]
          : null,
      ic1: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.isNotEmpty)
          ? avatarData.svgaRectUrls![0]
          : null,
      ic2: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 1)
          ? avatarData.svgaRectUrls![1]
          : null,
      ic3: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 2)
          ? avatarData.svgaRectUrls![2]
          : null,
      ic4: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 3)
          ? avatarData.svgaRectUrls![3]
          : null,
      ic5: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 4)
          ? avatarData.svgaRectUrls![4]
          : null,
      ic6: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 5)
          ? avatarData.svgaRectUrls![5]
          : null,
      ic7: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 6)
          ? avatarData.svgaRectUrls![6]
          : null,
      ic8: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 7)
          ? avatarData.svgaRectUrls![7]
          : null,
      ic9: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 8)
          ? avatarData.svgaRectUrls![8]
          : null,
      ic10: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 9)
          ? avatarData.svgaRectUrls![9]
          : null,
      ic11: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 10)
          ? avatarData.svgaRectUrls![10]
          : null,
      ic12: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 11)
          ? avatarData.svgaRectUrls![11]
          : null,
      ic13: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 12)
          ? avatarData.svgaRectUrls![12]
          : null,
      ic14: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 13)
          ? avatarData.svgaRectUrls![13]
          : null,
      ic15: (avatarData.svgaRectUrls != null && avatarData.svgaRectUrls!.length > 14)
          ? avatarData.svgaRectUrls![14]
          : null,

      // حقول افتراضية أخرى
      banned: null,
      type: null,
      pin: null,
      email: null,
      email_verified_at: null,
      created_at: null,
      updated_at: null,
      idd: null,
      birth: null,
      profile_state: null,
      statuse: null,
      gender: null,
      charger_country: null,
      country: null,
      wallet: null,
      stringid: null,
      friend: null,
      idrelation: null,
      imgrelation: null,
      monLevel: null,
      target: null,
      diamond: null,
      namerelation: null,
      number: null,
      // elementFrame: avatarData.frameId != null
      //     ? ElementEntity(elamentId: avatarData.frameId)
      //     : null,
      idColor: null,
      idColorTwo: null,
      rmonLevelTwo: null,
      display: null,
      giftCount: null,
      giftSend: null,
      giftRecive: null,
      howManyTime: null,
      type1: null,
      newType: null,
      wakalaName: null,
      show_gift: null,
      new_img: null,
      timer: null,
      entrylink: null,
      power: null,
      streamID: streamID,
    );
  }

// دالة مساعدة لتحديث مستخدم موجود ببيانات AvatarData
  UserEntity updateFromAvatarData(String encodedAvatarData) {
    final avatarData = AvatarData.fromEncodedString(encodedAvatarData);

    return copyWith(
      img: avatarData.imageUrl,
      vip: avatarData.vipLevel,
      entryID: avatarData.entryID,
      entryTimer: avatarData.entryTimer,
      ownerIds: avatarData.ownerIds,
      adminRoomIds: avatarData.adminRoomIds,
      totalSocre: avatarData.totalSocre,
      level1: avatarData.level1,
      level2: avatarData.level2,
      // Do not overwrite points; update displayed level only
      newlevel3: avatarData.newlevel3,
      elementFrame: avatarData.frameId != null
          ? ElementEntity(elamentId: avatarData.frameId)
          : elementFrame,
    );
  }
}

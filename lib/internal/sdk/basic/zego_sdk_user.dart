// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';
// import 'dart:convert';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:lklk/features/auth/domain/entities/user_entity.dart';

// import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
// import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';
// import 'package:lklk/features/profile_users/domain/entities/elements_entity.dart';

// class UserEntity {
//   String roomID = '';
//   String? streamID;
//   int viewID = -1;
//   ValueNotifier<Widget?> videoViewNotifier = ValueNotifier(null);
//   ValueNotifier<bool> isCameraOnNotifier = ValueNotifier(false);
//   ValueNotifier<bool> isUsingSpeaker = ValueNotifier(true);
//   ValueNotifier<bool> isMicOnNotifier = ValueNotifier(false);
//   ValueNotifier<bool> isUsingFrontCameraNotifier = ValueNotifier(true);
//   ValueNotifier<String?> avatarUrlNotifier = ValueNotifier(null);
//   ValueNotifier<String?> userImage;

//   UserEntity({
//     required String iduser,
//     required String name,
//     String? email,
//     String? img,
//     String? banned,
//     String? type,
//     String? pin,
//     String? email_verified_at,
//     String? created_at,
//     String? updated_at,
//     String? idd,
//     String? birth,
//     String? profile_state,
//     String? statuse,
//     String? level,
//     String? gender,
//     String? charger_country,
//     String? country,
//     int? wallet,
//     String? stringid,
//     String? friend,
//     String? idrelation,
//     String? imgrelation,
//     String? vip,
//     String? monLevel,
//     String? target,
//     int? diamond,
//     String? namerelation,
//     String? number,
//     String? level2,
//     String? idColor,
//     String? idColorTwo,
//     String? rmonLevelTwo,
//     this.streamID,
//   })  : userImage = ValueNotifier<String?>(img),
//         super(
//           iduser: iduser,
//           name: name,
//           email: email,
//           img: img,
//           banned: banned,
//           type: type,
//           pin: pin,
//           email_verified_at: email_verified_at,
//           created_at: created_at,
//           updated_at: updated_at,
//           idd: idd,
//           birth: birth,
//           profile_state: profile_state,
//           statuse: statuse,
//           level: level,
//           gender: gender,
//           charger_country: charger_country,
//           country: country,
//           wallet: wallet,
//           stringid: stringid,
//           friend: friend,
//           idrelation: idrelation,
//           imgrelation: imgrelation,
//           vip: vip,
//           monLevel: monLevel,
//           target: target,
//           diamond: diamond,
//           namerelation: namerelation,
//           number: number,
//           level2: level2,
//           idColor: idColor,
//           idColorTwo: idColorTwo,
//           rmonLevelTwo: rmonLevelTwo,
//         );

//   @override
//   String toString() {
//     return 'ZegoSDKUser: {id: $iduser, name: $name, roomID: $roomID, streamID: $streamID, viewID: $viewID, userImage: ${userImage.value}}';
//   }
// }

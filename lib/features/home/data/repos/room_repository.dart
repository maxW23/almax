// import 'package:lklk/core/utils/logger.dart';

// import 'package:lklk/features/room_view/domain/entities/room_entity.dart';

// import 'dart:convert';

// abstract class RoomRepository {
//   Future<List<RoomEntity>> getRooms(String token);
//   // Future<void> createRoom(String token);
//   // Future<void> updateMicrophoneNumber(int roomId, int newMicrophoneNumber);

//   // Future<void> updateRoomBackground(
//   //     String token, int roomId, String newBackground);

//   // Future<void> updateRoomImage(String token, int roomId, String newImage);
//   // Future<void> updateRoomName(String token, int roomId, String newName);
// }

// class RoomRepositoryImpl implements RoomRepository {
// // @override
// //  @override
// //   Future<void> createRoom(String token) async {
// //     final url = Uri.parse('https://lklklive.com/api/make/room');
// //     final response = await http.post(
// //       url,
// //       headers: {
// //         'Authorization': 'Bearer $token',
// //         'Content-Type': 'application/json',
// //       },
// //       body: jsonEncode({
// //         'name': 'room', // You can customize these values as needed
// //         'background': 'static.jpg',
// //         'img': 'img.png',
// //         'country': 'sy',
// //         'hello_text': 'hello',
// //         'microphone_number': '15',
// //         'owner': 33,
// //       }),
// //     );

// //     if (response.statusCode == 200) {
// //       AppLogger.debug('Room created successfully');
// //     } else {
// //       throw Exception('Failed to create room: ${response.statusCode}');
// //     }
// //   }
//   final String _baseUrl = 'https://lklklive.com/api';

//   @override
//   Future<List<RoomEntity>> getRooms(String token) async {
//     // //log('//////////////////////////////////getRooms/////////////////////////////////////////');
//     final url = Uri.parse('$_baseUrl/rooms');
//     final response =
//         await http.get(url, headers: {'Authorization': 'Bearer $token'});

//     // //log('RoomRepository Response status: ${response.statusCode}');
//     // //log('|||||||||||||||  RoomRepository Response body: ${response.body} \n |||||||||||||||||||||||||||||||||||||||||||');

//     if (response.statusCode == 200) {
//       final responseData = await jsonDecode(response.body);
//       final List<dynamic> jsonRooms = responseData['rooms'];
//       // //log('//////////////////////////////////end getRooms/////////////////////////////////////////');

//       return jsonRooms.map((json) {
//         // //log('////////////////  RoomRepositoryImpl getRooms json ==== $json \n////////////////////////////////////////////////////////////////////////////');

//         Map<String, dynamic> jsonMap = json;
//         return RoomEntity.fromJson(jsonMap);
//       }).toList();
//     } else {
//       // //log('//////////////////////////////////end getRooms Failed to load rooms/////////////////////////////////////////');

//       throw getRooms('Failed to load rooms');
//     }
//   }
// }
//   // @override
//   // Future<void> updateMicrophoneNumber(
//   //     int roomId, int newMicrophoneNumber) async {
//   //   final url = Uri.parse('https://lklklive.com/api/rooms/$roomId');
//   //   final response = await http.patch(
//   //     url,
//   //     headers: {
//   //       'Content-Type': 'application/json',
//   //     },
//   //     body: jsonEncode({'microphone_number': newMicrophoneNumber}),
//   //   );

//   //   if (response.statusCode != 200) {
//   //     throw Exception('Failed to update microphone number');
//   //   }
//   // }

//   // @override
//   // Future<void> updateRoomBackground(
//   //     String token, int roomId, String newBackground) async {
//   //   final Uri uri = Uri.https('lklklive.com', '/api/edit/room/$roomId', {
//   //     'background': newBackground,
//   //   });

//   //   final response = await http.post(
//   //     uri,
//   //     headers: {
//   //       'Authorization': 'Bearer $token',
//   //     },
//   //   );

//   //   if (response.statusCode == 200) {
//   //     AppLogger.debug('Room background updated successfully');
//   //   } else {
//   //     throw Exception(
//   //         'Failed to update room background: ${response.statusCode}');
//   //   }
//   // }

//   // @override
//   // Future<void> updateRoomImage(
//   //     String token, int roomId, String newImage) async {
//   //   final Uri uri = Uri.https('lklklive.com', '/api/edit/room/$roomId', {
//   //     'img': newImage,
//   //   });

//   //   final response = await http.post(
//   //     uri,
//   //     headers: {
//   //       'Authorization': 'Bearer $token',
//   //     },
//   //   );

//   //   if (response.statusCode == 200) {
//   //     AppLogger.debug('Room image updated successfully');
//   //   } else {
//   //     throw Exception('Failed to update room image: ${response.statusCode}');
//   //   }
//   // }

// //   @override
// //   Future<void> updateRoomName(String token, int roomId, String newName) async {
// //     final Uri uri = Uri.https('lklklive.com', '/api/edit/room/$roomId', {
// //       'name': newName,
// //     });

// //     final response = await http.post(
// //       uri,
// //       headers: {
// //         'Authorization': 'Bearer $token',
// //       },
// //     );

// //     if (response.statusCode == 200) {
// //       AppLogger.debug('Room name updated successfully');
// //     } else {
// //       throw Exception('Failed to update room name: ${response.statusCode}');
// //     }
// //   }
// // }

// //   @override
// //   Future<void> createRoom(String token) async {
// //   final url = Uri.parse('https://lklklive.com/api/make/room');
// //   final response = await http.post(
// //     url,
// //     headers: {
// //       'Authorization': 'Bearer $token',
// //       'Content-Type': 'application/json'
// //     },
// //     // body: jsonEncode(RoomEntity().toJson()), // Pass an instance to toJson
// //   );

// //   //log('RoomRepository Create Room Response status: ${response.statusCode}');
// //   //log('RoomRepository Create Room Response body: ${response.body}');

// //   if (response.statusCode == 200) {
// //     // Room created successfully
// //     // Parse the response if needed
// //     // Return or do anything else as needed
// //     return;
// //   } else if (response.statusCode == 400) {
// //     // Check if the room already exists
// //     final responseBody = await jsonDecode(response.body);
// //     if (responseBody['message'] == 'تم انشاء روم مسبقا') {
// //       // Room already exists, handle accordingly
// //       // You can throw an exception or return or handle however you want
// //       throw Exception('تم انشاء روم مسبقا');
// //     }
// //   }

// //   // Handle other status codes
// //   throw Exception('Failed to create room');
// // }
// //   // Future<void> createRoom(String token) async {
// //   //   final url = Uri.parse('https://lklklive.com/api/make/room');
// //   //   final response = await http.post(
// //   //     url,
// //   //     headers: {
// //   //       'Authorization': 'Bearer $token',
// //   //       'Content-Type': 'application/json'
// //   //     },
// //   //     body: jsonEncode(RoomEntity.toJson()),
// //   //   );

// //   //   //log('RoomRepository Create Room Response status: ${response.statusCode}');
// //   //   //log('RoomRepository Create Room Response body: ${response.body}');

// //   //   if (response.statusCode != 200) {
// //   //     throw Exception('Failed to create room');
// //   //   }
// //   // }

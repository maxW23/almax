// import 'package:lklk/core/utils/logger.dart';

//
// import 'package:equatable/equatable.dart';
// import 'package:lklk/core/services/api_service.dart';
// import 'package:lklk/features/auth/domain/entities/user_entity.dart';
// import 'package:lklk/features/room/domain/entities/room_entity.dart';

// part 'room_updated_state.dart';

// class RoomUpdatedCubit extends Cubit<RoomUpdatedState> {
//   RoomUpdatedCubit() : super(RoomUpdatedInitial());

//   Future<void> fetchUpdatedRoomById(int roomId, String where) async {
//           // log("Roooms fetchUpdatedRoomById $roomId ,$where");

//     try {
//       final response = await ApiService(enableRequestDebounce: true).get(
//         '/room2/$roomId',
//       );
//       // log("RoomUpdatedCubit fetchUpdatedRoomById /room2/ $where ${response.statusCode} ${response.data}");

//       if (response.statusCode == 200) {
//         if (response.data == 'محظور من دخول الغرفة') {
//           emit(RoomUpdatedBanned());
//         } else {
//           final responseData = response.data;

//           if (response.data == 'you need password to enter') {
//             // Handle password required case if needed
//           }

//           final roomData = responseData['room'];
//           final List<dynamic> usersData = responseData['users'];
//           final List<dynamic> bannedUsersData = responseData['banned_user'];
//           final List<dynamic> topUsersData = responseData['top'];

//           final room = RoomEntity.fromJson(roomData);

//           final List<UserEntity> users = usersData
//               .map((userData) => UserEntity.fromJson(userData))
//               .toList();
//           final List<UserEntity> bannedUsers = bannedUsersData
//               .map((userData) => UserEntity.fromJson(userData))
//               .toList();
//           final List<UserEntity> topUsers = topUsersData
//               .map((usersData) => UserEntity.fromJson(usersData))
//               .toList();

//           emit(RoomCubitRoomUpdatedData(room, users, bannedUsers, topUsers));
//         }
//       } else {
//         emit(const RoomCubitRoomError('Failed to load room details'));
//       }
//     } catch (e) {
//       emit(RoomCubitRoomError('Failed to fetch room details: $e'));
//     }
//   }

//   void backInital() {
//     emit(RoomUpdatedInitial());
//   }
// }

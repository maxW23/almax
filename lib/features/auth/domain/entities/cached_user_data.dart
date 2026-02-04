import 'package:hive/hive.dart';

part 'cached_user_data.g.dart'; // يتم إنشاؤه بواسطة build_runner

@HiveType(typeId: 1)
class CachedUserData extends HiveObject {
  @HiveField(0)
  int relationRequest;

  @HiveField(1)
  int friendRequest;

  @HiveField(2)
  int visitorNumber;

  @HiveField(3)
  int friendNumber;

  CachedUserData({
    required this.relationRequest,
    required this.friendRequest,
    required this.visitorNumber,
    required this.friendNumber,
  });
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_user_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedUserDataAdapter extends TypeAdapter<CachedUserData> {
  @override
  final int typeId = 1;

  @override
  CachedUserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedUserData(
      relationRequest: fields[0] as int,
      friendRequest: fields[1] as int,
      visitorNumber: fields[2] as int,
      friendNumber: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CachedUserData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.relationRequest)
      ..writeByte(1)
      ..write(obj.friendRequest)
      ..writeByte(2)
      ..write(obj.visitorNumber)
      ..writeByte(3)
      ..write(obj.friendNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedUserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

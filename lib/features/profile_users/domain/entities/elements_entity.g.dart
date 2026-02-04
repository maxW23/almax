// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elements_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ElementEntityAdapter extends TypeAdapter<ElementEntity> {
  @override
  final int typeId = 0;

  @override
  ElementEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ElementEntity(
      id: fields[0] as int?,
      linkPathLocal: fields[16] as String?,
      userId: fields[1] as String?,
      elementName: fields[2] as String?,
      date: fields[3] as dynamic,
      createdAt: fields[4] as String?,
      updatedAt: fields[5] as String?,
      buy: fields[6] as bool?,
      elamentId: fields[7] as String?,
      type: fields[8] as String?,
      imgElement: fields[9] as String?,
      linkPath: fields[10] as String?,
      price: fields[12] as String?,
      isSale: fields[13] as bool,
      timer: fields[14] as num?,
      vip: fields[15] as dynamic,
      giftCount: fields[11] as String?,
      imgElementLocal: fields[18] as String?,
      still: fields[17] as String?,
      giftPoints: fields[20] as String?,
      userName: fields[19] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ElementEntity obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.elementName)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.buy)
      ..writeByte(7)
      ..write(obj.elamentId)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.imgElement)
      ..writeByte(10)
      ..write(obj.linkPath)
      ..writeByte(11)
      ..write(obj.giftCount)
      ..writeByte(12)
      ..write(obj.price)
      ..writeByte(13)
      ..write(obj.isSale)
      ..writeByte(14)
      ..write(obj.timer)
      ..writeByte(15)
      ..write(obj.vip)
      ..writeByte(16)
      ..write(obj.linkPathLocal)
      ..writeByte(17)
      ..write(obj.still)
      ..writeByte(18)
      ..write(obj.imgElementLocal)
      ..writeByte(19)
      ..write(obj.userName)
      ..writeByte(20)
      ..write(obj.giftPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElementEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

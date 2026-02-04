// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserEntityAdapter extends TypeAdapter<UserEntity> {
  @override
  final int typeId = 2;

  @override
  UserEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserEntity(
      iduser: fields[0] as String,
      id: fields[1] as String?,
      name: fields[2] as String?,
      email: fields[3] as String?,
      img: fields[4] as String?,
      banned: fields[5] as String?,
      type: fields[6] as String?,
      pin: fields[7] as String?,
      email_verified_at: fields[8] as String?,
      created_at: fields[9] as String?,
      updated_at: fields[10] as String?,
      idd: fields[11] as String?,
      birth: fields[12] as String?,
      profile_state: fields[13] as String?,
      statuse: fields[14] as String?,
      level1: fields[15] as String?,
      gender: fields[16] as String?,
      charger_country: fields[17] as String?,
      country: fields[18] as String?,
      wallet: fields[19] as int?,
      stringid: fields[20] as String?,
      friend: fields[21] as String?,
      idrelation: fields[22] as String?,
      imgrelation: fields[23] as String?,
      vip: fields[24] as String?,
      monLevel: fields[25] as String?,
      target: fields[26] as String?,
      diamond: fields[27] as num?,
      namerelation: fields[29] as String?,
      number: fields[30] as String?,
      elementFrame: fields[31] as ElementEntity?,
      level2: fields[32] as String?,
      idColor: fields[33] as String?,
      idColorTwo: fields[34] as String?,
      rmonLevelTwo: fields[35] as String?,
      display: fields[36] as String?,
      giftCount: fields[28] as String?,
      giftSend: fields[38] as String?,
      giftRecive: fields[37] as String?,
      totalSocre: fields[44] as String?,
      newType: fields[47] as String?,
      howManyTime: fields[45] as String?,
      type1: fields[46] as String?,
      wakalaName: fields[39] as String?,
      entryID: fields[40] as String?,
      entryTimer: fields[41] as String?,
      ownerIds: (fields[42] as List?)?.cast<String>(),
      adminRoomIds: (fields[43] as List?)?.cast<String>(),
      show_gift: fields[48] as String?,
      new_img: fields[49] as String?,
      timer: fields[50] as String?,
      entrylink: fields[51] as String?,
      ic1: fields[52] as String?,
      ic2: fields[53] as String?,
      ic3: fields[54] as String?,
      ic4: fields[55] as String?,
      ic5: fields[56] as String?,
      ic6: fields[57] as String?,
      ic7: fields[58] as String?,
      ic8: fields[59] as String?,
      ic9: fields[60] as String?,
      ic10: fields[61] as String?,
      ic11: fields[62] as String?,
      ic12: fields[63] as String?,
      ic13: fields[64] as String?,
      ic14: fields[65] as String?,
      ic15: fields[66] as String?,
      ws1: fields[67] as String?,
      ws2: fields[68] as String?,
      ws3: fields[69] as String?,
      ws4: fields[70] as String?,
      ws5: fields[71] as String?,
      power: fields[72] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserEntity obj) {
    writer
      ..writeByte(73)
      ..writeByte(0)
      ..write(obj.iduser)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.img)
      ..writeByte(5)
      ..write(obj.banned)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.pin)
      ..writeByte(8)
      ..write(obj.email_verified_at)
      ..writeByte(9)
      ..write(obj.created_at)
      ..writeByte(10)
      ..write(obj.updated_at)
      ..writeByte(11)
      ..write(obj.idd)
      ..writeByte(12)
      ..write(obj.birth)
      ..writeByte(13)
      ..write(obj.profile_state)
      ..writeByte(14)
      ..write(obj.statuse)
      ..writeByte(15)
      ..write(obj.level1)
      ..writeByte(16)
      ..write(obj.gender)
      ..writeByte(17)
      ..write(obj.charger_country)
      ..writeByte(18)
      ..write(obj.country)
      ..writeByte(19)
      ..write(obj.wallet)
      ..writeByte(20)
      ..write(obj.stringid)
      ..writeByte(21)
      ..write(obj.friend)
      ..writeByte(22)
      ..write(obj.idrelation)
      ..writeByte(23)
      ..write(obj.imgrelation)
      ..writeByte(24)
      ..write(obj.vip)
      ..writeByte(25)
      ..write(obj.monLevel)
      ..writeByte(26)
      ..write(obj.target)
      ..writeByte(27)
      ..write(obj.diamond)
      ..writeByte(28)
      ..write(obj.giftCount)
      ..writeByte(29)
      ..write(obj.namerelation)
      ..writeByte(30)
      ..write(obj.number)
      ..writeByte(31)
      ..write(obj.elementFrame)
      ..writeByte(32)
      ..write(obj.level2)
      ..writeByte(33)
      ..write(obj.idColor)
      ..writeByte(34)
      ..write(obj.idColorTwo)
      ..writeByte(35)
      ..write(obj.rmonLevelTwo)
      ..writeByte(36)
      ..write(obj.display)
      ..writeByte(37)
      ..write(obj.giftRecive)
      ..writeByte(38)
      ..write(obj.giftSend)
      ..writeByte(39)
      ..write(obj.wakalaName)
      ..writeByte(40)
      ..write(obj.entryID)
      ..writeByte(41)
      ..write(obj.entryTimer)
      ..writeByte(42)
      ..write(obj.ownerIds)
      ..writeByte(43)
      ..write(obj.adminRoomIds)
      ..writeByte(44)
      ..write(obj.totalSocre)
      ..writeByte(45)
      ..write(obj.howManyTime)
      ..writeByte(46)
      ..write(obj.type1)
      ..writeByte(47)
      ..write(obj.newType)
      ..writeByte(48)
      ..write(obj.show_gift)
      ..writeByte(49)
      ..write(obj.new_img)
      ..writeByte(50)
      ..write(obj.timer)
      ..writeByte(51)
      ..write(obj.entrylink)
      ..writeByte(52)
      ..write(obj.ic1)
      ..writeByte(53)
      ..write(obj.ic2)
      ..writeByte(54)
      ..write(obj.ic3)
      ..writeByte(55)
      ..write(obj.ic4)
      ..writeByte(56)
      ..write(obj.ic5)
      ..writeByte(57)
      ..write(obj.ic6)
      ..writeByte(58)
      ..write(obj.ic7)
      ..writeByte(59)
      ..write(obj.ic8)
      ..writeByte(60)
      ..write(obj.ic9)
      ..writeByte(61)
      ..write(obj.ic10)
      ..writeByte(62)
      ..write(obj.ic11)
      ..writeByte(63)
      ..write(obj.ic12)
      ..writeByte(64)
      ..write(obj.ic13)
      ..writeByte(65)
      ..write(obj.ic14)
      ..writeByte(66)
      ..write(obj.ic15)
      ..writeByte(67)
      ..write(obj.ws1)
      ..writeByte(68)
      ..write(obj.ws2)
      ..writeByte(69)
      ..write(obj.ws3)
      ..writeByte(70)
      ..write(obj.ws4)
      ..writeByte(71)
      ..write(obj.ws5)
      ..writeByte(72)
      ..write(obj.power);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

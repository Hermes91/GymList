// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStatusAdapter extends TypeAdapter<UserStatus> {
  @override
  final int typeId = 1;

  @override
  UserStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserStatus.habilitado;
      case 1:
        return UserStatus.vencido;
      case 2:
        return UserStatus.suspendido;
      default:
        return UserStatus.habilitado;
    }
  }

  @override
  void write(BinaryWriter writer, UserStatus obj) {
    switch (obj) {
      case UserStatus.habilitado:
        writer.writeByte(0);
        break;
      case UserStatus.vencido:
        writer.writeByte(1);
        break;
      case UserStatus.suspendido:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

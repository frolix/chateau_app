// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_place_state_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPlaceStateAdapter extends TypeAdapter<UserPlaceState> {
  @override
  final int typeId = 2;

  @override
  UserPlaceState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPlaceState(
      placeId: fields[0] as String,
      isFavorite: fields[1] as bool,
      rating: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserPlaceState obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.placeId)
      ..writeByte(1)
      ..write(obj.isFavorite)
      ..writeByte(2)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPlaceStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

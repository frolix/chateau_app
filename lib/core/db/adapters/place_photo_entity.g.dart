// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_photo_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlacePhotoEntityAdapter extends TypeAdapter<PlacePhotoEntity> {
  @override
  final int typeId = 4;

  @override
  PlacePhotoEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlacePhotoEntity(
      id: fields[0] as String,
      placeId: fields[1] as String,
      path: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlacePhotoEntity obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.placeId)
      ..writeByte(2)
      ..write(obj.path)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlacePhotoEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

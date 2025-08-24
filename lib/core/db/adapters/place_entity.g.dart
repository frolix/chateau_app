// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaceEntityAdapter extends TypeAdapter<PlaceEntity> {
  @override
  final int typeId = 1;

  @override
  PlaceEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaceEntity(
      id: fields[0] as String,
      name: fields[1] as String,
      lat: fields[2] as double,
      lng: fields[3] as double,
      description: fields[4] as String,
      fact: fields[5] as String?,
      image: fields[6] as String?,
      rating: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlaceEntity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.lat)
      ..writeByte(3)
      ..write(obj.lng)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.fact)
      ..writeByte(6)
      ..write(obj.image)
      ..writeByte(7)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

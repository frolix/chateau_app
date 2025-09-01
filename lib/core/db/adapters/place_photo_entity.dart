// lib/shared/db/adapters/place_photo_entity.dart
import 'package:hive/hive.dart';

part 'place_photo_entity.g.dart';

@HiveType(typeId: 4) // обери вільний typeId
class PlacePhotoEntity {
  @HiveField(0)
  final String id; // uuid або timestamp
  @HiveField(1)
  final String placeId; // ід місця
  @HiveField(2)
  final String path; // локальний шлях до файлу
  @HiveField(3)
  final DateTime createdAt;

  PlacePhotoEntity({
    required this.id,
    required this.placeId,
    required this.path,
    required this.createdAt,
  });
}

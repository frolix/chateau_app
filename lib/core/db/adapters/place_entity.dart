import 'package:hive/hive.dart';
import '../boxes.dart';

part 'place_entity.g.dart';

@HiveType(typeId: HiveTypeIds.placeEntity)
class PlaceEntity extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double lat;

  @HiveField(3)
  double lng;

  @HiveField(4)
  String description;

  @HiveField(5)
  String? fact;

  @HiveField(6)
  String? image;

  /// Базовий (редакційний) рейтинг 0..5
  @HiveField(7)
  int rating;

  PlaceEntity({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.description,
    required this.fact,
    this.image,
    this.rating = 0,
  });
}

import 'package:hive/hive.dart';
import '../boxes.dart';

part 'user_place_state_entity.g.dart';

@HiveType(typeId: HiveTypeIds.userPlaceState) // не змінюй після релізу
class UserPlaceState extends HiveObject {
  @HiveField(0)
  String placeId;

  @HiveField(1)
  bool isFavorite;

  @HiveField(2)
  int rating; // 0..5 — локальний рейтинг юзера

  UserPlaceState({
    required this.placeId,
    this.isFavorite = false,
    this.rating = 0,
  });
}

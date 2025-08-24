import 'package:chatau/core/db/adapters/place_entity.dart';
import 'package:chatau/core/db/boxes.dart';
import 'package:hive/hive.dart';
import 'package:chatau/core/di/di.dart';
import 'package:chatau/shared/domain/repositories/places_repository.dart';
import 'package:chatau/features/seed/places_seed.dart';

/// Викликати після setupDI(), щоб заповнити порожню БД стартовим набором.
Future<void> bootstrapPlacesIfEmpty() async {
  final Box<PlaceEntity> placesBox = Hive.box<PlaceEntity>(Boxes.places); // ✅
  if (placesBox.isEmpty) {
    await sl<PlacesRepository>().upsert(placesSeed);
  }
}

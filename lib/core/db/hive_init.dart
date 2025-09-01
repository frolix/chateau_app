import 'package:chatau/core/db/adapters/fact_entity.dart';
import 'package:chatau/core/db/adapters/place_photo_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'boxes.dart';
import 'adapters/place_entity.dart';
import 'adapters/user_place_state_entity.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(HiveTypeIds.placeEntity)) {
    Hive.registerAdapter(PlaceEntityAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveTypeIds.userPlaceState)) {
    Hive.registerAdapter(UserPlaceStateAdapter());
  }

  if (!Hive.isAdapterRegistered(HiveTypeIds.factEntity)) {
    Hive.registerAdapter(FactEntityAdapter());
  }

  if (!Hive.isAdapterRegistered(HiveTypeIds.photosEntity)) {
    Hive.registerAdapter(PlacePhotoEntityAdapter());
  }

  if (!Hive.isBoxOpen(Boxes.places)) {
    await Hive.openBox<PlaceEntity>(Boxes.places);
  }

  if (!Hive.isBoxOpen(Boxes.placeState)) {
    await Hive.openBox<UserPlaceState>(Boxes.placeState);
  }

  if (!Hive.isBoxOpen(Boxes.facts)) {
    await Hive.openBox<FactEntity>(Boxes.facts);
  }

  if (!Hive.isBoxOpen(Boxes.photos)) {
    await Hive.openBox<PlacePhotoEntity>(Boxes.photos);
  }
}

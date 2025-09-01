import 'package:chatau/shared/data/repositories/place_photos_repository_hive.dart';
import 'package:chatau/shared/domain/repositories/photos_repository.dart';
import 'package:chatau/shared/domain/services/place_photos_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

// ⬇️ додай
import 'package:chatau/features/onboarding/domain/onboarding_state.dart';

import '../db/hive_init.dart';
import '../db/boxes.dart';
import '../db/adapters/place_entity.dart';
import '../db/adapters/user_place_state_entity.dart';
import '../db/adapters/fact_entity.dart';

import '../../shared/domain/repositories/places_repository.dart';
import '../../shared/data/repositories/places_repository_hive.dart';
import '../../shared/domain/repositories/facts_repository.dart';
import '../../shared/data/repositories/facts_repository_hive.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  await initHive(); // відкриває бокси та реєструє адаптери

  final placesBox = Hive.box<PlaceEntity>(Boxes.places);
  final stateBox = Hive.box<UserPlaceState>(Boxes.placeState);
  final factsBox = Hive.box<FactEntity>(Boxes.facts);
  // final photosBox = Hive.box<PlacePhotoEntity>(
  //   Boxes.photos,
  // ); // 👈 якщо конструкторам треба

  if (!sl.isRegistered<PlacePhotosService>()) {
    sl.registerLazySingleton<PlacePhotosService>(() => PlacePhotosService());
  }

  // Places
  if (!sl.isRegistered<PlacesRepository>()) {
    sl.registerLazySingleton<PlacesRepository>(
      () => PlacesRepositoryHive(placesBox: placesBox, stateBox: stateBox),
    );
  }

  // Facts
  if (!sl.isRegistered<FactsRepository>()) {
    sl.registerLazySingleton<FactsRepository>(
      () => FactsRepositoryHive(factsBox: factsBox),
    );
  }

  // Photos
  if (!sl.isRegistered<PhotosRepository>()) {
    sl.registerLazySingleton<PhotosRepository>(
      () => PlacePhotosRepositoryHive(),
    );
  }

  // ⬇️ OnboardingState: реєструємо і одразу відновлюємо прапорець
  if (!sl.isRegistered<OnboardingState>()) {
    sl.registerLazySingleton<OnboardingState>(() => OnboardingState());
  }
  await sl<OnboardingState>().restore();
}

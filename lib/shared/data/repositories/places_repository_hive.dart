import 'dart:async';

import 'package:hive/hive.dart';
import 'package:chatau/core/db/adapters/place_entity.dart';
import 'package:chatau/core/db/adapters/user_place_state_entity.dart';

import '../../domain/models/place.dart';
import '../../domain/repositories/places_repository.dart';
import '../mappers/place_mapper.dart';

/// Імплементація репозиторію на Hive:
/// - Box<PlaceEntity> зберігає “каталог/довідник” місць
/// - Box<UserPlaceState> зберігає локальний стан користувача (в обраних, мій рейтинг)
class PlacesRepositoryHive implements PlacesRepository {
  final Box<PlaceEntity> _placesBox;
  final Box<UserPlaceState> _stateBox;

  PlacesRepositoryHive({
    required Box<PlaceEntity> placesBox,
    required Box<UserPlaceState> stateBox,
  }) : _placesBox = placesBox,
       _stateBox = stateBox;

  @override
  Future<List<Place>> fetch() async {
    return _mergeAll();
  }

  @override
  Stream<List<Place>> watch() {
    // Реактивно слухаємо зміни в обох боксах і щоразу віддаємо змерджений список.
    return Stream<List<Place>>.multi((controller) {
      // початкове значення
      () async {
        controller.add(await _mergeAll());
      }();

      final sub1 = _placesBox.watch().listen((_) async {
        controller.add(await _mergeAll());
      });
      final sub2 = _stateBox.watch().listen((_) async {
        controller.add(await _mergeAll());
      });

      controller.onCancel = () {
        sub1.cancel();
        sub2.cancel();
      };
    });
  }

  @override
  Future<void> upsert(List<Place> items) async {
    // оновлюємо тільки каталог місць (user-state не чіпаємо)
    final Map<dynamic, PlaceEntity> batch = {
      for (final p in items) p.id: p.toEntity(),
    };
    await _placesBox.putAll(batch);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final s = _stateBox.get(id) ?? UserPlaceState(placeId: id);
    s.isFavorite = !s.isFavorite;
    await _stateBox.put(id, s);
  }

  @override
  Future<void> setRating(String id, int rating) async {
    final r = rating.clamp(0, 5);
    final s = _stateBox.get(id) ?? UserPlaceState(placeId: id);
    s.rating = r;
    await _stateBox.put(id, s);
  }

  @override
  Future<List<Place>> getByIds(Iterable<String> ids) async {
    final uniq = ids.toSet(); // захист від дублікатів
    final result = <Place>[];

    for (final id in uniq) {
      final e = _placesBox.get(id);
      if (e == null) continue;
      final st = _stateBox.get(id);
      result.add(e.toDomain(st));
    }
    return result;
  }

  // ===== favorites API =====
  @override
  Future<List<Place>> getFavorites() async {
    final ids = _stateBox.values
        .where((s) => s.isFavorite)
        .map((s) => s.placeId);
    return getByIds(ids);
  }

  @override
  Stream<List<Place>> watchFavorites() {
    return Stream<List<Place>>.multi((controller) {
      Future<void> emit() async => controller.add(await getFavorites());

      // початкове значення
      emit();

      // реагуємо на зміни і в стані, і в каталозі
      final sub1 = _stateBox.watch().listen((_) => emit());
      final sub2 = _placesBox.watch().listen((_) => emit());

      controller.onCancel = () {
        sub1.cancel();
        sub2.cancel();
      };
    });
  }

  @override
  bool isSaved(String id) => _stateBox.get(id)?.isFavorite ?? false;

  @override
  Stream<bool> watchIsSaved(String id) {
    return Stream<bool>.multi((controller) {
      void emit() => controller.add(isSaved(id));
      emit();
      final sub = _stateBox.watch(key: id).listen((_) => emit());
      controller.onCancel = () => sub.cancel();
    });
  }

  @override
  Future<Place?> getById(String id) async {
    final e = _placesBox.get(id);
    if (e == null) return null;
    return e.toDomain(_stateBox.get(id));
  }

  // ===== helpers =====

  Future<List<Place>> _mergeAll() async {
    return _placesBox.values
        .map((e) => e.toDomain(_stateBox.get(e.id)))
        .toList();
  }
}

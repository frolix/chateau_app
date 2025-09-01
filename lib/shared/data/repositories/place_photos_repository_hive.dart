import 'dart:async';
import 'package:chatau/core/db/adapters/place_photo_entity.dart';
import 'package:chatau/core/db/boxes.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';

import 'package:chatau/shared/domain/models/place_photo.dart';
import 'package:chatau/shared/domain/repositories/photos_repository.dart';
import 'package:chatau/shared/data/mappers/place_photo_mapper.dart';

class PlacePhotosRepositoryHive implements PhotosRepository {
  Box<PlacePhotoEntity> get _box => Hive.box<PlacePhotoEntity>(Boxes.photos);

  @override
  Future<PlacePhoto> add(PlacePhoto photo) async {
    final entity = photo.toEntity();
    // Кладемо з ключем = id (зручно видаляти)
    await _box.put(entity.id, entity);
    return entity.toDomain();
  }

  @override
  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<PlacePhoto>> listForPlace(String placeId) async {
    return _box.values
        .where((e) => e.placeId == placeId)
        .map((e) => e.toDomain())
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
        .toList();
  }

  @override
  Stream<List<PlacePhoto>> watchForPlace(String placeId) {
    // Початкове значення + реакція на зміни
    final controller = StreamController<List<PlacePhoto>>.broadcast();

    void emit() async {
      controller.add(await listForPlace(placeId));
    }

    // перший викид
    emit();

    // слухаємо будь-які зміни боксу і фільтруємо по placeId
    final sub = _box.watch().listen((_) => emit());

    controller.onCancel = () => sub.cancel();
    return controller.stream;
  }
}

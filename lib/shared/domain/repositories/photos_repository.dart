import 'package:chatau/shared/domain/models/place_photo.dart';

abstract class PhotosRepository {
  /// Додати фото (уже відомий шлях до файлу)
  Future<PlacePhoto> add(PlacePhoto photo);

  /// Видалити фото за id
  Future<void> remove(String id);

  /// Отримати список фото для місця
  Future<List<PlacePhoto>> listForPlace(String placeId);

  /// Стрім із фото для місця (оновлюється при змінах)
  Stream<List<PlacePhoto>> watchForPlace(String placeId);
}

import 'package:chatau/core/db/adapters/place_photo_entity.dart';
import 'package:chatau/shared/domain/models/place_photo.dart';

// Entity -> Domain
extension PlacePhotoEntityX on PlacePhotoEntity {
  PlacePhoto toDomain() =>
      PlacePhoto(id: id, placeId: placeId, path: path, createdAt: createdAt);
}

// Domain -> Entity
extension PlacePhotoX on PlacePhoto {
  PlacePhotoEntity toEntity() => PlacePhotoEntity(
    id: id,
    placeId: placeId,
    path: path,
    createdAt: createdAt,
  );
}

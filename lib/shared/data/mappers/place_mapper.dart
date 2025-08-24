// Маппери Entity <-> Domain (щоб UI не знав про Hive)
import 'package:chatau/core/db/adapters/place_entity.dart';
import 'package:chatau/core/db/adapters/user_place_state_entity.dart';
import '../../domain/models/place.dart';

extension PlaceEntityToDomain on PlaceEntity {
  Place toDomain(UserPlaceState? state) {
    return Place(
      id: id,
      name: name,
      lat: lat,
      lng: lng,
      description: description,
      fact: fact ?? '',
      image: image,
      rating: rating,
      favorite: state?.isFavorite ?? false,
      myRating: state?.rating ?? 0,
    );
  }
}

extension PlaceDomainToEntity on Place {
  PlaceEntity toEntity() {
    return PlaceEntity(
      id: id,
      name: name,
      lat: lat,
      lng: lng,
      description: description,
      fact: fact,
      image: image,
      rating: rating,
    );
  }
}

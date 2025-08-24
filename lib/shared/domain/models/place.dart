import 'package:latlong2/latlong.dart';

class Place {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String description;
  final String? fact;
  final String? image;

  /// Базовий (редакційний) рейтинг із каталогу 0..5
  final int rating;

  /// Локальний рейтинг користувача 0..5 (user-state у Hive)
  final int myRating;

  /// Обране (user-state)
  final bool favorite;

  const Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.description,
    required this.fact,
    this.image,
    this.rating = 0,
    this.myRating = 0,
    this.favorite = false,
  });

  LatLng get ll => LatLng(lat, lng);

  get funFact => null;

  Place copyWith({
    String? id,
    String? name,
    double? lat,
    double? lng,
    String? description,
    String? fact,
    String? image,
    int? rating,
    int? myRating,
    bool? favorite,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      description: description ?? this.description,
      fact: fact ?? this.fact,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      myRating: myRating ?? this.myRating,
      favorite: favorite ?? this.favorite,
    );
  }
}

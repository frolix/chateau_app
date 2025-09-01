class PlacePhoto {
  final String id; // унікальний id (uuid/мікросекунди)
  final String placeId; // до якого місця належить фото
  final String path; // локальний шлях до файлу
  final DateTime createdAt;

  const PlacePhoto({
    required this.id,
    required this.placeId,
    required this.path,
    required this.createdAt,
  });

  PlacePhoto copyWith({
    String? id,
    String? placeId,
    String? path,
    DateTime? createdAt,
  }) {
    return PlacePhoto(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

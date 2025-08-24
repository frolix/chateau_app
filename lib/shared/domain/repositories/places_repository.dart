import '../models/place.dart';

abstract class PlacesRepository {
  /// Разове читання всього списку (мердж каталогу + локального стану користувача)
  Future<List<Place>> fetch();

  /// Реактивні оновлення (зміни як у каталозі, так і в user-state)
  Stream<List<Place>> watch();

  /// Оновити/підсіяти каталог місць (наприклад, із мережі)
  Future<void> upsert(List<Place> items);

  /// Помітити/зняти “в обрані”
  Future<void> toggleFavorite(String id);

  /// Встановити мій рейтинг 0..5 для місця
  Future<void> setRating(String id, int rating);

  /// ✅ Отримати місця за списком ID (мерджиться з локальним UserPlaceState)
  Future<List<Place>> getByIds(Iterable<String> ids);

  /// (опційно) Отримати одне місце за ID. null, якщо в каталозі немає.
  Future<Place?> getById(String id);

  Future<List<Place>> getFavorites();
  Stream<List<Place>> watchFavorites();
  bool isSaved(String id);
  Stream<bool> watchIsSaved(String id);
}

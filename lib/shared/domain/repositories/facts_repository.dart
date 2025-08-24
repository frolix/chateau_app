import 'package:chatau/shared/domain/models/fact.dart';

abstract class FactsRepository {
  /// Одноразово отримати всі факти
  Future<List<Fact>> fetch();

  /// Реактивно спостерігати за фактами
  Stream<List<Fact>> watch();

  /// Масовий апсерт (для сидів або імпорту)
  Future<void> upsertAll(List<Fact> items);

  /// Очистити (корисно для “перезалити сид”)
  Future<void> clear();
}

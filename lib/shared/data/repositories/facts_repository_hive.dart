import 'dart:async';
import 'package:hive/hive.dart';

import '../../../core/db/adapters/fact_entity.dart';
import '../../domain/models/fact.dart';
import '../../domain/repositories/facts_repository.dart';
import '../mappers/fact_mapper.dart';

class FactsRepositoryHive implements FactsRepository {
  final Box<FactEntity> _factsBox;

  FactsRepositoryHive({required Box<FactEntity> factsBox})
    : _factsBox = factsBox;

  @override
  Future<List<Fact>> fetch() async {
    return _factsBox.values.map((e) => e.toDomain()).toList();
  }

  @override
  Stream<List<Fact>> watch() {
    return Stream<List<Fact>>.multi((controller) {
      controller.add(_factsBox.values.map((e) => e.toDomain()).toList());
      final sub = _factsBox.watch().listen((_) {
        controller.add(_factsBox.values.map((e) => e.toDomain()).toList());
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  @override
  Future<void> upsertAll(List<Fact> items) async {
    await _factsBox.putAll({for (final f in items) f.id: f.toEntity()});
  }

  @override
  Future<void> clear() => _factsBox.clear();
}

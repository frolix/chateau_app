import '../../../core/db/adapters/fact_entity.dart';
import '../../domain/models/fact.dart';

extension FactEntityX on FactEntity {
  Fact toDomain() => Fact(id: id, text: text, createdAt: createdAt);
}

extension FactX on Fact {
  FactEntity toEntity() => FactEntity(id: id, text: text, createdAt: createdAt);
}

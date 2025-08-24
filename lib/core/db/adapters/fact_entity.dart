import 'package:chatau/core/db/boxes.dart';
import 'package:hive/hive.dart';

part 'fact_entity.g.dart';

@HiveType(typeId: HiveTypeIds.factEntity) // 👈 див. пункт 2
class FactEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final DateTime createdAt;

  FactEntity({required this.id, required this.text, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();
}

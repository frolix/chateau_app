// lib/core/bootstrap/facts_bootstrap.dart (або ваш поточний шлях)
import 'package:hive/hive.dart';
import 'package:chatau/shared/seed/facts_seed.dart'; // 👈 читаємо доменний сид
import '../db/adapters/fact_entity.dart';
import '../db/boxes.dart';

Future<void> factsBootstrap() async {
  final Box<FactEntity> box = Hive.box<FactEntity>(
    Boxes.facts,
  ); // уже відкритий у initHive
  if (box.isNotEmpty) return;

  // Мапимо доменні факти у Entity і заливаємо гуртом
  final Map<String, FactEntity> entries = {
    for (final f in factsSeed) f.id: FactEntity(id: f.id, text: f.text),
  };

  await box.putAll(entries);
}

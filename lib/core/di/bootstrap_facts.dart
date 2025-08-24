import 'package:hive/hive.dart';
import '../db/adapters/fact_entity.dart';
import '../db/boxes.dart';

Future<void> factsBootstrap() async {
  final box = Hive.box<FactEntity>(Boxes.facts); // уже відкритий у initHive
  if (box.isNotEmpty) return;

  final seed = <FactEntity>[
    FactEntity(
      id: 'f1',
      text:
          "France is one of the world's largest wine producers, producing billions of liters each year.",
    ),
    FactEntity(
      id: 'f2',
      text:
          "Winemaking in France dates back to Roman times, around the 6th century BC.",
    ),
    FactEntity(
      id: 'f3',
      text:
          "Each wine-growing region in France has its own rules for wine production and labeling.",
    ),
    FactEntity(
      id: 'f4',
      text:
          "The AOC (Appellation d'Origine Contrôlée) system defines the quality and origin standards of wine.",
    ),
    FactEntity(
      id: 'f5',
      text:
          "The Bordeaux region is famous for its red wines based on Cabernet Sauvignon and Merlot.",
    ),
    FactEntity(
      id: 'f6',
      text:
          "Burgundy is known for its Pinot Noir and Chardonnay, which are considered the benchmarks in the world.",
    ),
    FactEntity(
      id: 'f7',
      text:
          "Champagne is the only region where a drink can officially be produced under the name \"Champagne\".",
    ),
    FactEntity(
      id: 'f8',
      text:
          "In France, wines are often classified not by grape variety, but by region of production.",
    ),
    FactEntity(
      id: 'f9',
      text:
          "The average French person consumes about 50 liters of wine per year.",
    ),
    FactEntity(
      id: 'f10',
      text:
          "French wine cellars sometimes extend several kilometers underground.",
    ),
    FactEntity(
      id: 'f11',
      text:
          "Wines from the Sauternes region are known for their sweet taste due to the “noble rot” of the grapes.",
    ),
    FactEntity(
      id: 'f12',
      text:
          "In the Middle Ages, wine was safer to drink than water due to the lack of clean sources.",
    ),
    FactEntity(
      id: 'f13',
      text: "French winemakers store bottles in cellars for decades to age.",
    ),
    FactEntity(
      id: 'f14',
      text:
          "The world’s most expensive wines, such as Romanée-Conti, are produced in France.",
    ),
    FactEntity(
      id: 'f15',
      text:
          "Vineyards in Burgundy can be very small, sometimes less than a hectare.",
    ),
    FactEntity(
      id: 'f16',
      text:
          "France has introduced a “terroir” system that takes into account soil, climate, and tradition.",
    ),
    FactEntity(
      id: 'f17',
      text: "Provençal wines are known for their rosy hues and fresh aromas.",
    ),
    FactEntity(
      id: 'f18',
      text:
          "There are over 200 grape varieties used for commercial wine production in France.",
    ),
    FactEntity(
      id: 'f19',
      text:
          "Champagne production involves a second fermentation directly in the bottle.",
    ),
    FactEntity(
      id: 'f20',
      text: "Some French vineyards have been family-owned for over 400 years.",
    ),
    FactEntity(
      id: 'f21',
      text:
          "Bordeaux hosts a huge wine festival every year that attracts tourists from all over the world.",
    ),
    FactEntity(
      id: 'f22',
      text:
          "The oldest vineyard in France is located in Alsace and is over 400 years old.",
    ),
    FactEntity(
      id: 'f23',
      text: "French wines are exported to over 200 countries around the world.",
    ),
    FactEntity(
      id: 'f24',
      text: "The Bordeaux classification system has hardly changed since 1855.",
    ),
    FactEntity(
      id: 'f25',
      text:
          "In Champagne, grapes are harvested exclusively by hand so as not to damage the berries.",
    ),
    FactEntity(
      id: 'f26',
      text:
          "France produces not only still and sparkling wines, but also fortified and dessert wines.",
    ),
    FactEntity(
      id: 'f27',
      text:
          "Some French wines are made from a blend of several grape varieties.",
    ),
    FactEntity(
      id: 'f28',
      text:
          "The vineyards of the Loire Valley are known for their fresh white wines, such as Sauvignon Blanc.",
    ),
    FactEntity(
      id: 'f29',
      text:
          "Wine is often drunk with lunch and dinner in France, even on weekdays.",
    ),
    FactEntity(
      id: 'f30',
      text:
          "Some of France’s wine cellars are listed as UNESCO World Heritage Sites.",
    ),
    FactEntity(
      id: 'f31',
      text:
          "The Alsace region produces mainly white wines from Riesling, Gewürztraminer and Pinot Gris.",
    ),
    FactEntity(
      id: 'f32',
      text:
          "French wines are often served by the glass in restaurants, not just by the bottle.",
    ),
    FactEntity(
      id: 'f33',
      text:
          "Wine bottles can have different shapes depending on the region (Bordeaux, Burgundy, Alsatian).",
    ),
    FactEntity(
      id: 'f34',
      text:
          "Some French vineyards are located on very steep slopes, which makes harvesting difficult.",
    ),
    FactEntity(
      id: 'f35',
      text:
          "There are entire wine tourism routes in France with tastings and guides.",
    ),
    FactEntity(
      id: 'f36',
      text:
          "Red wines lose their color saturation with age, becoming more terracotta.",
    ),
    FactEntity(
      id: 'f37',
      text:
          "The largest wine museum in France is located in Bordeaux — Cité du Vin.",
    ),
    FactEntity(
      id: 'f38',
      text:
          "The French town of Béziers hosts an annual wine and harvest festival.",
    ),
    FactEntity(
      id: 'f39',
      text:
          "Producers often save special harvests for their own collections and do not sell them.",
    ),
    FactEntity(
      id: 'f40',
      text:
          "Wine tasting in France is a ritual that includes evaluating color, aroma, and taste.",
    ),
  ];

  await box.putAll({for (final f in seed) f.id: f});
}

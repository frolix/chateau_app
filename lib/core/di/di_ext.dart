// lib/core/di/di_ext.dart
import 'package:flutter/widgets.dart';
import 'di.dart';
import '../../shared/domain/repositories/places_repository.dart';

extension ReposX on BuildContext {
  PlacesRepository get placesRepo => sl<PlacesRepository>();
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:chatau/core/di/di.dart';
import 'package:chatau/shared/domain/models/place.dart';
import 'package:chatau/shared/domain/repositories/places_repository.dart';

class PlacesMapPage extends StatefulWidget {
  const PlacesMapPage({
    super.key,
    this.initial, // стартово вибране місце
  });

  final Place? initial;

  @override
  State<PlacesMapPage> createState() => _PlacesMapPageState();
}

class _PlacesMapPageState extends State<PlacesMapPage> {
  final _map = MapController();
  LatLngBounds? _lastFittedBounds;

  static const double _frameRadius = 22;
  static const double _frameBorder = 3;
  static const double _frameLeftRight = 0;
  static const EdgeInsets _frameOuterPadding = EdgeInsets.only();

  @override
  Widget build(BuildContext context) {
    final repo = sl<PlacesRepository>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<List<Place>>(
        stream: repo.watch(),
        builder: (context, snap) {
          final places = snap.data ?? const <Place>[];

          const fallbackCenter = LatLng(46.7111, 1.7191);
          const fallbackZoom = 5.5;

          final LatLng? initialPoint =
              (widget.initial != null)
                  ? LatLng(widget.initial!.lat, widget.initial!.lng)
                  : null;

          final bounds = _computeBounds(places);

          // Усе кладемо у Stack, щоб зверху намалювати кнопку закриття
          return Stack(
            children: [
              Padding(
                padding: _frameOuterPadding.copyWith(
                  left: _frameLeftRight,
                  right: _frameLeftRight,
                ),
                child: _frame(
                  child: FlutterMap(
                    mapController: _map,
                    options: MapOptions(
                      initialCenter:
                          initialPoint ?? (bounds?.center ?? fallbackCenter),
                      initialZoom:
                          initialPoint != null
                              ? 14
                              : (bounds != null ? 8 : fallbackZoom),
                      onMapReady: () {
                        if (initialPoint != null) {
                          _map.move(initialPoint, 14);
                        } else if (bounds != null) {
                          _fitOnce(bounds);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        retinaMode: true,
                        userAgentPackageName: 'com.example.chatau',
                      ),
                      MarkerLayer(
                        markers:
                            places.map((pl) {
                              final pt = LatLng(pl.lat, pl.lng);
                              return Marker(
                                point: pt,
                                width: 44,
                                height: 44,
                                alignment: Alignment.bottomCenter,
                                child: GestureDetector(
                                  onTap: () => context.go('details', extra: pl),
                                  child: Image.asset(
                                    'assets/images/map-pin.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      if (initialPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: initialPoint,
                              width: 48,
                              height: 48,
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                'assets/images/map-pin.png',
                                width: 44,
                                height: 44,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Кнопка закриття: по центру знизу
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 16 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: _CloseMapButton(onTap: () => context.pop()),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _frame({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF020B65), Color(0xFF0416CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_frameRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E46FF).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(_frameBorder),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_frameRadius - _frameBorder),
        child: child,
      ),
    );
  }

  LatLngBounds? _computeBounds(List<Place> places) {
    if (places.isEmpty) return null;
    if (places.length == 1) {
      final p = places.first;
      const d = 0.02;
      return LatLngBounds(
        LatLng(p.lat - d, p.lng - d),
        LatLng(p.lat + d, p.lng + d),
      );
    }
    double minLat = double.infinity, minLng = double.infinity;
    double maxLat = -double.infinity, maxLng = -double.infinity;
    for (final p in places) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng > maxLng) maxLng = p.lng;
    }
    const pad = 0.03;
    return LatLngBounds(
      LatLng(minLat - pad, minLng - pad),
      LatLng(maxLat + pad, maxLng + pad),
    );
  }

  void _fitOnce(LatLngBounds bounds) {
    if (_lastFittedBounds != null &&
        _lastFittedBounds!.southWest == bounds.southWest &&
        _lastFittedBounds!.northEast == bounds.northEast) {
      return;
    }
    _lastFittedBounds = bounds;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _map.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
      );
    });
  }
}

/// Жовта квадратна кнопка закриття як на макеті
class _CloseMapButton extends StatelessWidget {
  const _CloseMapButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8C24D),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.close, color: Colors.black, size: 24),
        ),
      ),
    );
  }
}

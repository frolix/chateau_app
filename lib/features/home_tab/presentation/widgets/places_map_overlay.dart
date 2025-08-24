import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:chatau/core/di/di.dart';
import 'package:chatau/shared/domain/models/place.dart';
import 'package:chatau/shared/domain/repositories/places_repository.dart';

/// Публічний спільний фрейм (градієнт, тінь, бордер, радіус) для мапи.
/// enabled=false — тільки ClipRRect (без градієнта/тіні/паддингів), зручно для фулскріну.
class MapFrame extends StatelessWidget {
  const MapFrame({
    super.key,
    required this.child,
    required this.radius,
    this.enabled = true,
    this.border = 3,
    this.leftRightPadding = 0,
    this.outerPadding = EdgeInsets.zero,
    this.shadow = const [
      BoxShadow(
        color: Color(0x592E46FF), // ~0.35 opacity від #2E46FF
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
    ],
  });

  final Widget child;
  final double radius;
  final bool enabled;
  final double border;
  final double leftRightPadding;
  final EdgeInsets outerPadding;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      );
    }
    return Padding(
      padding: outerPadding.copyWith(
        left: leftRightPadding,
        right: leftRightPadding,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF020B65), Color(0xFF0416CB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadow,
        ),
        padding: EdgeInsets.all(border),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - border),
          child: child,
        ),
      ),
    );
  }
}

class PlacesMapOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(Place place) onOpenDetails; // NEW

  const PlacesMapOverlay({
    super.key,
    required this.onClose,
    required this.onOpenDetails,
  });

  @override
  State<PlacesMapOverlay> createState() => _PlacesMapOverlayState();
}

class _PlacesMapOverlayState extends State<PlacesMapOverlay> {
  final _map = MapController();
  bool _mapReady = false;
  bool _didAutoFit = false;
  LatLngBounds? _lastFittedBounds;

  Place? _selected;

  // рамка
  static const double _frameRadius = 22;
  static const double _frameBorder = 3;
  static const double _frameLeftRight = 0;
  static const EdgeInsets _frameOuterPadding = EdgeInsets.only();

  @override
  Widget build(BuildContext context) {
    final repo = sl<PlacesRepository>();
    final safeTop = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // ==== MAP ONLY (у спільній рамці) ====
        StreamBuilder<List<Place>>(
          stream: repo.watch(),
          builder: (context, snap) {
            final places = snap.data ?? const <Place>[];

            const fallbackCenter = LatLng(46.7111, 1.7191);
            const fallbackZoom = 5.5;
            final bounds = _computeBounds(places);

            return MapFrame(
              radius: _frameRadius,
              border: _frameBorder,
              leftRightPadding: _frameLeftRight,
              outerPadding: _frameOuterPadding,
              enabled: true, // у фулскрін-оверлеї рамка лишається як була
              child: _buildMap(places, bounds, fallbackCenter, fallbackZoom),
            );
          },
        ),

        // Верхня міні-картка над мапою (коли щось вибрано)
        Positioned(
          left: _frameLeftRight,
          right: _frameLeftRight,
          top: safeTop + 12,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder:
                (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.08),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
            child:
                (_selected != null)
                    ? _TopPlaceCard(
                      key: ValueKey(_selected!.id),
                      place: _selected!,
                      onClose: () => setState(() => _selected = null),
                      onOpen: () {
                        final p = _selected;
                        if (p == null) return;
                        widget.onOpenDetails(p); // повідомляємо батька
                      },
                    )
                    : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  // === MAP VIEW ===
  Widget _buildMap(
    List<Place> places,
    LatLngBounds? bounds,
    LatLng fallbackCenter,
    double fallbackZoom,
  ) {
    return FlutterMap(
      key: ValueKey(
        bounds == null
            ? 'no-bounds'
            : '${bounds.southWest}-${bounds.northEast}',
      ),
      mapController: _map,
      options: MapOptions(
        backgroundColor: const Color(0xFF0E1330),
        initialCenter: fallbackCenter,
        initialZoom: fallbackZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapReady: () {
          _mapReady = true;
          if (bounds != null && !_didAutoFit) {
            _didAutoFit = true;
            _fitOnce(bounds, force: true);
          }
        },
        initialCameraFit:
            (bounds != null)
                ? CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(48),
                )
                : null,
        onTap: (_, __) {
          if (_selected != null) setState(() => _selected = null);
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          retinaMode: true, // для iPhone гарно
          userAgentPackageName: 'com.example.chatau',
        ),
        MarkerLayer(
          markers:
              places
                  .map(
                    (pl) => Marker(
                      point: LatLng(pl.lat, pl.lng),
                      width: 44,
                      height: 44,
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selected = pl);
                          _focusOn(pl);
                        },
                        child: Image.asset(
                          'assets/images/map-pin.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  // helpers
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

  void _fitOnce(LatLngBounds bounds, {bool force = false}) {
    if (!force &&
        _lastFittedBounds != null &&
        _lastFittedBounds!.southWest == bounds.southWest &&
        _lastFittedBounds!.northEast == bounds.northEast) {
      return;
    }
    _lastFittedBounds = bounds;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _map.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
      );
    });
  }

  void _focusOn(Place pl) {
    const d = 0.01;
    final b = LatLngBounds(
      LatLng(pl.lat - d, pl.lng - d),
      LatLng(pl.lat + d, pl.lng + d),
    );
    _map.fitCamera(
      CameraFit.bounds(
        bounds: b,
        padding: const EdgeInsets.only(
          left: 80,
          right: 80,
          top: 220,
          bottom: 260,
        ),
      ),
    );
  }
}

// ==== картка зверху над мапою (як була) ==============================
class _TopPlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  const _TopPlaceCard({
    super.key,
    required this.place,
    required this.onClose,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 22.0;
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 19),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF121C8E), Color(0xFF2E46FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (place.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  place.image!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(5, (i) {
                          final filled = i < place.rating;
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              filled ? Icons.star : Icons.star_border,
                              color: Colors.amberAccent,
                              size: 22,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onOpen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8C24D),
                    foregroundColor: Colors.black,
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Open',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

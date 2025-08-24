import 'package:chatau/features/places/presentation/pages/places_map_page.dart';
import 'package:chatau/features/places/presentation/widgets/guide_place_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chatau/features/home_tab/presentation/widgets/guide_header_card.dart';
import 'package:chatau/features/places/presentation/widgets/place_card.dart';
import 'package:chatau/shared/domain/models/place.dart';
import 'package:chatau/shared/domain/repositories/places_repository.dart';
import 'package:chatau/core/di/di.dart';

import 'place_details_page.dart'; // твій файл з PlaceDetailsPage (із слайдом і бекдропом)

/// Root віджет вкладки з локальним GoRouter
class PlacesTab extends StatefulWidget {
  const PlacesTab({super.key});

  @override
  State<PlacesTab> createState() => _PlacesTabState();
}

class _PlacesTabState extends State<PlacesTab> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: _PlacesListScreen()),
          routes: [
            GoRoute(
              path: 'details',
              // ВАЖЛИВО: без анімації на роуті, бо всередині PlaceDetailsPage вже є AnimatedSlide
              pageBuilder: (context, state) {
                final place = state.extra as Place?;
                return NoTransitionPage(
                  child:
                      place != null
                          ? PlaceDetailsPage(place: place)
                          : const _DetailsMissingGuard(),
                );
              },
            ),
            GoRoute(
              path: 'map',
              pageBuilder: (context, state) {
                final place = state.extra as Place?;
                return NoTransitionPage(child: PlacesMapPage(initial: place));
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Локальний Router для вкладки
    return Router(
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}

/// Екран зі списком місць
class _PlacesListScreen extends StatelessWidget {
  const _PlacesListScreen();

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final bottomPad = 24 + MediaQuery.of(context).padding.bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Padding(
          padding: EdgeInsets.only(top: safeTop),
          child: const GuidePlacesCard(),
        ),
        const SizedBox(height: 16),
        Text(
          'Recommended places',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Place>>(
            stream: sl<PlacesRepository>().watch(),
            builder: (context, snap) {
              final places = snap.data ?? [];

              return Stack(
                children: [
                  ListView.builder(
                    padding: EdgeInsets.only(bottom: bottomPad),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final p = places[index];
                      return PlaceCard(
                        place: p,
                        onOpen: () => context.go('/details', extra: p),
                        margin: const EdgeInsets.only(bottom: 12),
                      );
                    },
                  ),
                  // Легкий затемнювач внизу (опційно)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 80 + MediaQuery.of(context).padding.bottom,
                    child: const IgnorePointer(
                      ignoring: true,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                              Colors.black87,
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Guard на випадок, якщо хтось зайде на /details без extra
class _DetailsMissingGuard extends StatelessWidget {
  const _DetailsMissingGuard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Text(
          'Place not found',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

import 'package:chatau/features/saved/presentation/widgets/guide_saves_olaces.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chatau/core/di/di.dart';
import 'package:chatau/features/places/presentation/widgets/place_card.dart';
import 'package:chatau/features/places/presentation/pages/place_details_page.dart';
import 'package:chatau/features/places/presentation/pages/places_map_page.dart';
import 'package:chatau/shared/domain/models/place.dart';
import 'package:chatau/shared/domain/repositories/places_repository.dart';

class UserPlacesPage extends StatefulWidget {
  const UserPlacesPage({super.key});

  @override
  State<UserPlacesPage> createState() => _UserPlacesPageState();
}

class _UserPlacesPageState extends State<UserPlacesPage> {
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
                  const NoTransitionPage(child: _UserPlacesListScreen()),
          routes: [
            GoRoute(
              path: 'details',
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
    return Router(
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}

class _UserPlacesListScreen extends StatelessWidget {
  const _UserPlacesListScreen();

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
          child: const GuideSavedPlacesCard(), // твоя картка-хедер для saved
        ),
        const SizedBox(height: 16),
        Text(
          'My saved places',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),

        // 🔥 ТУТ — єдиний стрім зі списком збережених
        Expanded(
          child: StreamBuilder<List<Place>>(
            stream: sl<PlacesRepository>().watchFavorites(),
            builder: (context, snap) {
              final places = snap.data ?? const <Place>[];

              if (places.isEmpty) {
                return const _EmptySavedState();
              }

              return Stack(
                children: [
                  ListView.builder(
                    padding: EdgeInsets.only(bottom: bottomPad),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final p = places[index];
                      return PlaceCard(
                        place: p,
                        onOpen: () => context.push('/details', extra: p),
                        margin: const EdgeInsets.only(bottom: 12),
                      );
                    },
                  ),

                  // градієнт зверху над нижнім інсетом
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

class _EmptySavedState extends StatelessWidget {
  const _EmptySavedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NO SAVED',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

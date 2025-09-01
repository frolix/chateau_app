import 'package:chatau/features/onboarding/presentation/onboarding_page.dart';
import 'package:chatau/features/splash/presentation/splash.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/home/presentation/home_page.dart';

/// Нотіфаєр, щоб примусово оновлювати router при зміні стану (наприклад, коли користувач пройшов онбординг)
class AppRouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerRefresh = AppRouterRefresh();

/// Простий in-memory флаг. Реально — зчитуємо/пишемо у SharedPreferences.
class OnboardingState {
  static bool _seen = false;
  static bool get seen => _seen;
  static set seen(bool v) {
    _seen = v;
    routerRefresh.refresh();
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: routerRefresh,
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (ctx, st) => const NoTransitionPage(child: SplashPage()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder:
          (ctx, st) =>
              _fade(const OnboardingPage(), key: const ValueKey('onboarding')),
    ),
    // GoRoute(
    //   path: '/home',
    //   pageBuilder:
    //       (ctx, st) => _fade(const HomePage(), key: const ValueKey('home')),
    // ),
  ],

  /// Глобальний редірект: якщо онбординг ще не пройдений — ведемо на /onboarding (крім самих /splash та /onboarding)
  redirect: (ctx, state) {
    final loc = state.matchedLocation;
    final seen = OnboardingState.seen;
    if (!seen && loc != '/onboarding' && loc != '/splash') {
      return '/onboarding';
    }
    return null;
  },
  errorPageBuilder:
      (ctx, st) => MaterialPage(
        child: Scaffold(body: Center(child: Text(st.error.toString()))),
      ),
);

CustomTransitionPage _fade(Widget child, {LocalKey? key}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder:
        (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
  );
}

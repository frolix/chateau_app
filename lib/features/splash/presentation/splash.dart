import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatau/app_router.dart';

const _kOnboardingKey = 'onboarding_complete';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // прогріваємо зображення після першого фрейму
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const AssetImage('assets/images/BACKGROUND 1.png'),
        context,
      );
      precacheImage(const AssetImage('assets/images/Frame 4.png'), context);
    });

    _boot();
  }

  Future<void> _boot() async {
    try {
      // коротка пауза для лого (косметика)
      await Future.delayed(const Duration(milliseconds: 600));

      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool(_kOnboardingKey) ?? false;

      // DEBUG: завжди показуємо онбординг, щоб колеги бачили флоу
      final effectiveSeen = kDebugMode ? false : seen;
      OnboardingState.seen =
          effectiveSeen; // тримаємо in‑memory стан в актуальному вигляді

      if (!mounted) return;
      context.go(
        effectiveSeen ? '/home' : '/onboarding',
      ); // ⚠️ використовуй effectiveSeen
    } catch (_) {
      if (!mounted) return;
      // у разі збою — краще показати онбординг, ніж зависнути
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/BACKGROUND 1.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: 200,
                child: Image.asset('assets/images/Frame 4.png', width: 200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

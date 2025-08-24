import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatau/app_router.dart'; // де оголошено OnboardingState

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // коротка пауза для лого (за бажанням залиш)
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_complete') ?? false;

    final effectiveSeen =
        kDebugMode ? false : seen; // для дебагу завжди показуємо онбординг
    OnboardingState.seen = effectiveSeen;

    // оновлюємо in‑memory стан, це триггерне refresh для GoRouter
    // OnboardingState.seen = seen;

    if (!mounted) return;
    context.go(seen ? '/home' : '/onboarding');
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
              // заміни на свій логотип/анімацію
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

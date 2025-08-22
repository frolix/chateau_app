import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // щоб не було білих просвітів
      extendBodyBehindAppBar: true, // на випадок, якщо буде AppBar
      body: Stack(
        children: [
          // ФОН: займає весь екран
          Positioned.fill(
            child: Image.asset(
              'assets/images/BACKGROUND 1.png',
              fit: BoxFit.cover, // розтягнути з обрізанням
              alignment: Alignment.center, // по центру
            ),
          ),

          // Контент поверх фону
          SafeArea(
            child: Center(
              child: Image.asset('assets/images/Frame 4.png', width: 200),
            ),
          ),
        ],
      ),
    );
  }
}

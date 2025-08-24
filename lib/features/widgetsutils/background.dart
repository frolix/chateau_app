import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget? child;
  const AppBackground({super.key, this.child});

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
          if (child != null) SafeArea(child: child!),
        ],
      ),
    );
  }
}

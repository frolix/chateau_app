import 'package:flutter/material.dart';

class GuideWords extends StatelessWidget {
  const GuideWords({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned(top: 8, left: 0, right: 0, child: _WordBox()),
          Positioned.fill(child: Center(child: _WordBox())),
          Positioned(bottom: 8, left: 0, right: 0, child: _WordBox()),
        ],
      ),
    );
  }
}

class _WordBox extends StatelessWidget {
  const _WordBox();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 59,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'YOUR GUIDE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600, // SemiBold
            fontSize: 48,
            height: 1.0,
            color: Colors.white.withOpacity(0.02), // 2%
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

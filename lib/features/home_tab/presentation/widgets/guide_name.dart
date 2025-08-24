import 'package:flutter/material.dart';

class GuideName extends StatelessWidget {
  const GuideName({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: 96, // підкрути за потреби, щоб сіло як у Figma
      child: const _NameText('Annette'),
    );
  }
}

class _NameText extends StatelessWidget {
  final String text;
  const _NameText(this.text);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Annette',
      textAlign: TextAlign.center,
      softWrap: false,
      overflow: TextOverflow.fade,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500, // Medium 500 (з твого скріну)
        fontSize: 24,
        height: 1.0, // 100%
        color: Colors.white,
        letterSpacing: 0,
      ),
    );
  }
}

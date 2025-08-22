import 'package:flutter/material.dart';

class BottomHeroImage extends StatefulWidget {
  final bool visible;
  final String? imagePath;
  final double offsetDy; // 0.1 = 10% екрана знизу
  final Duration duration;
  final Duration delay;

  const BottomHeroImage({
    super.key,
    required this.visible,
    required this.imagePath,
    this.offsetDy = 0.1,
    this.duration = const Duration(milliseconds: 700),
    this.delay = Duration.zero,
  });

  @override
  State<BottomHeroImage> createState() => _BottomHeroImageState();
}

class _BottomHeroImageState extends State<BottomHeroImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween(
    begin: Offset(0, widget.offsetDy),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_c);

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant BottomHeroImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible && !_c.isAnimating && _c.value == 0) {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    } else if (!widget.visible && _c.value > 0) {
      // 🚀 миттєво ховаємо картинку
      _c.stop();
      _c.value = 0.0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePath == null) return const SizedBox.shrink();
    final w = MediaQuery.of(context).size.width;

    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _opacity,
            child: Image.asset(
              widget.imagePath!,
              width: w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

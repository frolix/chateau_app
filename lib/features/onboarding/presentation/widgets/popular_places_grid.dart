import 'dart:math';
import 'package:flutter/material.dart';

class PopularPlacesGrid extends StatelessWidget {
  const PopularPlacesGrid({
    super.key,
    required this.assets,
    this.gap = 12,
    this.borderRadius = 20,
    this.placeholderColor = const Color(0x33FFFFFF),
    this.animate = true,
  });

  final List<String> assets;
  final double gap;
  final double borderRadius;
  final Color placeholderColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    // Гарантуємо ≥ 4 елементи, інакше доб’ємо пустими
    final pool = List<String>.from(assets);
    while (pool.length < 4) {
      pool.add('');
    }
    pool.shuffle(Random());
    final pics = pool.take(4).toList();

    return SizedBox(
      height: 360, // піджени під макет за потреби
      child: LayoutBuilder(
        builder: (ctx, c) {
          final totalH = c.maxHeight;
          final smallH = (totalH - 2 * gap) / 3; // три плитки + два проміжки

          Widget small(String img, int order) => SizedBox(
            height: smallH,
            child: _AnimatedTile(
              image: img.isEmpty ? null : img,
              radius: borderRadius,
              placeholder: placeholderColor,
              beginOffset: const Offset(-1, 0), // зліва
              delay:
                  animate ? Duration(milliseconds: 120 * order) : Duration.zero,
              duration: const Duration(milliseconds: 500),
              enabled: animate,
            ),
          );

          return Row(
            children: [
              // ЛІВА КОЛОНКА: 3 малі (точні висоти) + анімація зліва
              Expanded(
                child: Column(
                  children: [
                    small(pics[0], 0),
                    SizedBox(height: gap),
                    small(pics[1], 1),
                    SizedBox(height: gap),
                    small(pics[2], 2),
                  ],
                ),
              ),
              SizedBox(width: gap),

              // ПРАВА КОЛОНКА: одна ВЕЛИКА на всю висоту + анімація справа
              Expanded(
                child: SizedBox.expand(
                  child: _AnimatedTile(
                    image: pics[3].isEmpty ? null : pics[3],
                    radius: borderRadius,
                    placeholder: placeholderColor,
                    beginOffset: const Offset(1, 0), // справа
                    delay:
                        animate
                            ? const Duration(milliseconds: 240)
                            : Duration.zero,
                    duration: const Duration(milliseconds: 550),
                    enabled: animate,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Плитка з анімацією slide+fade (можна вимкнути через enabled=false)
class _AnimatedTile extends StatefulWidget {
  const _AnimatedTile({
    required this.image,
    required this.radius,
    required this.placeholder,
    this.beginOffset = Offset.zero,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.enabled = true,
  });

  final String? image;
  final double radius;
  final Color placeholder;
  final Offset beginOffset;
  final Duration delay;
  final Duration duration;
  final bool enabled;

  @override
  State<_AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<_AnimatedTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: widget.beginOffset,
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      // без анімації — одразу показати кінцевий стан
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled && _controller.value == 0) {
        Future.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      } else if (!widget.enabled) {
        _controller.value = 1;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.image == null || widget.image!.isEmpty;

    final child = ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child:
          isEmpty
              ? Container(color: widget.placeholder)
              : Image.asset(
                widget.image!,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Colors.red.withValues(alpha: .35),
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: Colors.red),
                    ),
              ),
    );

    if (!widget.enabled) return child;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(opacity: _fade, child: child),
    );
  }
}

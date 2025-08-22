import 'dart:math';
import 'package:flutter/material.dart';

class FavoritePlaceCard extends StatefulWidget {
  const FavoritePlaceCard({super.key, required this.assets});
  final List<String> assets;

  @override
  State<FavoritePlaceCard> createState() => _FavoritePlaceCardState();
}

class _FavoritePlaceCardState extends State<FavoritePlaceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  // фото
  late final Animation<double> _imgFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.00, 0.60, curve: Curves.easeOut),
  );
  late final Animation<Offset> _imgSlide = Tween(
    begin: const Offset(0, .10),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _c,
      curve: const Interval(0.00, 0.60, curve: Curves.easeOutCubic),
    ),
  );

  // зірочки
  late final Animation<double> _starsFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.40, 0.85, curve: Curves.easeOut),
  );
  late final Animation<Offset> _starsSlide = Tween(
    begin: const Offset(-.20, 0),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _c,
      curve: const Interval(0.40, 0.85, curve: Curves.easeOutCubic),
    ),
  );

  // лайк
  late final Animation<double> _likeScale = Tween(begin: .6, end: 1.0).animate(
    CurvedAnimation(
      parent: _c,
      curve: const Interval(0.60, 1.00, curve: Curves.elasticOut),
    ),
  );

  @override
  void initState() {
    super.initState();
    // стартуємо анімацію після побудови
    WidgetsBinding.instance.addPostFrameCallback((_) => _c.forward());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rng = Random();
    final imagePath = widget.assets[rng.nextInt(widget.assets.length)];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF020B65), Color(0xFF0416CB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Фото місця: fade + slideUp
          SlideTransition(
            position: _imgSlide,
            child: FadeTransition(
              opacity: _imgFade,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Зірочки: виїзд зліва + fade
                SlideTransition(
                  position: _starsSlide,
                  child: FadeTransition(
                    opacity: _starsFade,
                    child: const _StarsRow(),
                  ),
                ),
                const Spacer(),

                // Лайк: поп-ап scale
                ScaleTransition(scale: _likeScale, child: const _LikeButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 5 зірок 28.82×28.82 з проміжком 37.29 (зліва “прилипають” до краю)
class _StarsRow extends StatelessWidget {
  const _StarsRow();

  static const double _starSize = 28.82;
  static const double _gap = 10.0; // проміжок між зірками
  static const String _starAsset = 'assets/images/tabler_star-filled.png';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Padding(
          padding: EdgeInsets.only(right: i == 4 ? 0 : _gap),
          child: Image.asset(
            _starAsset,
            width: _starSize,
            height: _starSize,
            fit: BoxFit.contain,
          ),
        );
      }),
    );
  }
}

/// Біла кнопка 60×60 з тінню та іконкою лайку по центру
class _LikeButton extends StatelessWidget {
  const _LikeButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: const [
          BoxShadow(
            color: Color(0x70000000),
            blurRadius: 22.86,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/images/iconamoon_like-light.png',
          width: 30,
          height: 30,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

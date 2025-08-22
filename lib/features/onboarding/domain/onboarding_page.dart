import 'package:chatau/features/onboarding/domain/widgets/favorite_place_card.dart';
import 'package:chatau/features/onboarding/domain/widgets/popular_places_grid.dart';
import 'package:chatau/features/onboarding/domain/widgets/bottom_hero_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// імпорт згенерованих локалізацій (synthetic-package: false)
import 'package:chatau/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  // картинки для ґріда
  static const List<String> _places = [
    'assets/images/places/chateau_cheval_blanc.png',
    'assets/images/places/chateau_mouton_rothschild.png',
    'assets/images/places/champagne_taittinger.png',
    'assets/images/places/chateau_pape_clement.png',
    'assets/images/places/chateau_lafite_rothschild.png',
    'assets/images/places/chateau_d_yquem.png',
    'assets/images/places/maison_veuve_clicquot.png',
    'assets/images/places/domaine_de_la_romanee_conti.png',
    'assets/images/places/chateau_haut_brion.png',
    'assets/images/places/chateau_margaux.png',
  ];

  void _next() {
    final slides = _buildSlides(context);
    if (_index < slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // будуємо локалізовані слайди
  List<_OnboardingSlide> _buildSlides(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return [
      _OnboardingSlide(
        title: t.onb1Title,
        description: t.onb1Desc,
        heroImage: 'assets/images/image 2.png', // або image_2.png
      ),
      _OnboardingSlide(title: t.onb2Title, description: t.onb2Desc),
      _OnboardingSlide(title: t.onb3Title, description: t.onb3Desc),
      _OnboardingSlide(title: t.onb4Title, description: t.onb4Desc),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final slides = _buildSlides(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Фон
          Positioned.fill(
            child: Image.asset(
              'assets/images/BACKGROUND 1.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Герой-картинка знизу (лише для 1-го слайду)
          BottomHeroImage(
            visible: _index == 0 && slides[0].heroImage != null,
            imagePath: slides[0].heroImage,
            offsetDy: 0.10,
            duration: const Duration(milliseconds: 650),
            delay: const Duration(milliseconds: 120),
          ),

          // Контент: PageView (зверху) + нижній блок керування
          SafeArea(
            child: Column(
              children: [
                // верхня область
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: slides.length,
                    itemBuilder: (ctx, i) {
                      final slide = slides[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок + опис
                            Text(
                              slide.title,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              slide.description,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),

                            // 2-й слайд: центрований грід
                            if (i == 1) ...[
                              const Spacer(),
                              PopularPlacesGrid(assets: _places),
                              const Spacer(),
                            ],

                            // 3-й слайд: центрована картинка
                            if (i == 2) ...[
                              const Spacer(),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.asset(
                                  'assets/images/Frame 2.png',
                                  width: double.infinity,
                                  height: 340,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const Spacer(),
                            ],

                            // 4-й слайд: картка обраного місця
                            if (i == 3) ...[
                              const Spacer(),
                              FavoritePlaceCard(assets: _places),
                              const Spacer(),
                            ],

                            if (i != 1 && i != 2) const Spacer(),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // низ: індикатори + кнопка
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          slides.length,
                          (j) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _index == j ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  _index == j ? Colors.white : Colors.white38,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(280, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _next,
                        child: Text(
                          _index == slides.length - 1
                              ? t.btnStart
                              : t.btnContinue, // або t.btnNiceToMeetYou
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String description;
  final String? heroImage;
  const _OnboardingSlide({
    required this.title,
    required this.description,
    this.heroImage,
  });
}

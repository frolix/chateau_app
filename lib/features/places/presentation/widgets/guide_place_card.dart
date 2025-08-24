import 'package:chatau/features/home_tab/presentation/widgets/app_icon.dart';
import 'package:chatau/features/home_tab/presentation/widgets/guide_words.dart';
import 'package:flutter/material.dart';

class GuidePlacesCard extends StatelessWidget {
  const GuidePlacesCard({super.key});

  @override
  Widget build(BuildContext context) {
    const cardW = 355.0;
    const cardH = 209.0;

    return Center(
      child: SizedBox(
        width: cardW,
        height: cardH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1) Фон картки
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF020B65), Color(0xFF0416CB)],
                  ),
                ),
              ),
            ),

            // 2) Три написи "YOUR GUIDE" як фон
            const GuideWords(),

            // 3) Фото зліва
            Positioned(
              left: 14,
              bottom: 0,
              width: 208,
              height: 288,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(-1, 1, 1),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(28),
                  ),
                  child: Image.asset(
                    'assets/images/image 2.png',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => const ColoredBox(
                          color: Colors.black26,
                          child: SizedBox.expand(),
                        ),
                  ),
                ),
              ),
            ),

            // 4) Текст праворуч (замість GuideName)
            Positioned(
              top: 24,
              right: 16,
              child: SizedBox(
                width: 159, // як у макеті
                height: 51, // 3 рядки * 12px line-height
                child: Text(
                  'Here are my favorite locations that you will definitely love.',
                  textAlign: TextAlign.right,
                  softWrap: true,
                  maxLines: 3, // 👈 максимум 3 рядки
                  overflow: TextOverflow.clip, // не переносити на 4-й
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.0, // 100% line-height як у Figma
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // 5) Іконка застосунку в правому нижньому куті
            const Positioned(right: 16, bottom: 16, child: AppIcon(size: 66)),
          ],
        ),
      ),
    );
  }
}

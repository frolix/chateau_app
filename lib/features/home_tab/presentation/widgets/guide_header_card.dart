import 'package:flutter/material.dart';
import 'guide_words.dart';
import 'guide_name.dart';
import 'app_icon.dart';

class GuideHeaderCard extends StatelessWidget {
  const GuideHeaderCard({super.key});

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

            // 2) Три написи "YOUR GUIDE"
            const GuideWords(),

            // 3) Фото зліва (дзеркало по X, торкається низу, “вилазить” вгору)
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

            // 4) Ім'я праворуч
            const GuideName(),

            // 5) Іконка застосунку в правому нижньому куті
            const Positioned(right: 16, bottom: 16, child: AppIcon(size: 66)),
          ],
        ),
      ),
    );
  }
}

import 'package:chatau/features/home_tab/presentation/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// Вища картка для вкладки Invite:
/// — збільшена висота фону
/// — більша іконка застосунку
/// — текст зверху праворуч
class GuideHeaderCardInvite extends StatelessWidget {
  const GuideHeaderCardInvite({
    super.key,
    this.title =
        'I, Annette, invite you to the world of French wine and unforgettable moments. Here you will find the best places, stories and secrets that will make your trip special.',
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    const cardW = 355.0;
    const cardH = 330.0; // було 209 → робимо фон вищим
    const radius = 22.0;

    // розміри/позиції елементів
    const imgLeft = 14.0;
    const imgWidth = 213.0;
    const imgHeight = 313.0; // з запасом, “вилазить” нагору
    const textTop = 18.0;
    const hPad = 16.0;
    const double textW = 207;
    const double textH = 89;

    return Center(
      child: SizedBox(
        width: cardW,
        height: cardH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1) Фон
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(radius)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF020B65), Color(0xFF0416CB)],
                  ),
                ),
              ),
            ),

            // 5) Велика іконка застосунку внизу праворуч
            const Positioned(
              right: 12,
              bottom: 12,
              child: AppIcon(size: 164), // було ~66 → зробили більше
            ),
            // 2) Фото зліва (дзеркалимо, торкається низу, виступає нагору)
            Positioned(
              left: imgLeft,
              bottom: 0,
              width: imgWidth,
              height: imgHeight,
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

            // 3) Текст зверху праворуч
            // 3) Текст зверху праворуч
            Positioned(
              top: textTop,
              right: hPad,
              child: SizedBox(
                width: textW,
                height: textH,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler:
                        TextScaler.noScaling, // вимкнути масштабування системи
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    softWrap: true,
                    maxLines: 6,
                    overflow:
                        TextOverflow.clip, // або ellipsis якщо хочеш обрізати
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600, // SemiBold
                      fontSize: 13, // як у фігмі
                      height: 1.0, // 100% line-height
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

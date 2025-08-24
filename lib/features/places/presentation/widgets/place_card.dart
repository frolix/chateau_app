import 'package:flutter/material.dart';
import 'package:chatau/shared/domain/models/place.dart';
// sl<...>()

/// Універсальна картка місця для списку/оверлеїв.
/// - Favorite через DI
/// - Зірки тільки для відображення (не клікабельні)
/// - Кнопка Open через onOpen
class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onOpen,
    this.showClose = false,
    this.onClose,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  final Place place;
  final VoidCallback onOpen;

  /// Опційно: показати кнопку закриття у лівому верхньому куті (для міні-картки над мапою)
  final bool showClose;
  final VoidCallback? onClose;

  /// Відступ картки (для списку трохи інший, ніж над мапою)
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    const radius = 22.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF121C8E), Color(0xFF2E46FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (place.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Фото
                    Image.asset(
                      place.image!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    // Close (опційно)
                    if (showClose && onClose != null)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black38,
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(40, 40),
                          ),
                          tooltip: 'Close',
                        ),
                      ),

                    // // Favorite
                    // Positioned(
                    //   right: 8,
                    //   top: 8,
                    //   child: IconButton(
                    //     onPressed:
                    //         () =>
                    //             sl<PlacesRepository>().toggleFavorite(place.id),
                    //     icon: Icon(
                    //       (place.isFavorite ?? false)
                    //           ? Icons.favorite
                    //           : Icons.favorite_border,
                    //     ),
                    //     color: Colors.redAccent,
                    //     style: IconButton.styleFrom(
                    //       backgroundColor: Colors.black38,
                    //       padding: const EdgeInsets.all(8),
                    //       minimumSize: const Size(40, 40),
                    //     ),
                    //     tooltip: 'Favorite',
                    //   ),
                    // ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // Назва + рейтинг + кнопка Open
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Назва + рейтинг
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _RatingRow(value: place.rating),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Open
                ElevatedButton(
                  onPressed: onOpen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8C24D),
                    foregroundColor: Colors.black,
                    elevation: 10,
                    shadowColor: Colors.black..withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Open',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.value});

  final int value; // 0..5

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < value;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            filled ? Icons.star : Icons.star_border,
            color: Colors.amberAccent,
            size: 22,
          ),
        );
      }),
    );
  }
}

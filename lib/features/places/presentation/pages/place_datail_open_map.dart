import 'package:chatau/core/di/di.dart';
import 'package:chatau/shared/domain/models/place.dart';
import 'package:chatau/shared/domain/repositories/places_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 👈 додано

/// Повноекранний екран деталей, використовує публічну картку DetailsCard.
class DetailsFullScreenMap extends StatelessWidget {
  final Place place;
  const DetailsFullScreenMap({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DetailsCard(
        place: place,
        onToggleFavorite: () => sl<PlacesRepository>().toggleFavorite(place.id),
        onShare: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Share tapped')));
        },
      ),
    );
  }
}

class DetailsCard extends StatelessWidget {
  final Place place;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onShare;

  const DetailsCard({
    super.key,
    required this.place,
    required this.onToggleFavorite,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final hasFact = (place.fact?.isNotEmpty ?? false);

    const cardRadius = 22.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF020B65), Color(0xFF0416CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max, // займати всю доступну висоту
        children: [
          if (place.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                place.image!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 18),

          // Заголовок + рейтинг
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  place.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  final filled = i < place.rating;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      filled ? Icons.star : Icons.star_border,
                      color: const Color(0xFFE8C24D),
                      size: 22,
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${place.lat.toStringAsFixed(4)}, ${place.lng.toStringAsFixed(4)}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // ===== Центр картки (ГНУЧКИЙ, без скролу) =====
          Expanded(
            child:
                hasFact
                    ? DefaultTabController(
                      length: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            isScrollable: true,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white70,
                            dividerColor: Colors.transparent,
                            indicator: const UnderlineTabIndicator(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              insets: EdgeInsets.only(right: 12, bottom: 4),
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            tabs: const [
                              Tab(text: 'Description'),
                              Tab(text: 'Interesting fact'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                ClipRect(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      place.description,
                                      softWrap: true,
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ),
                                ClipRect(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      place.fact ?? '',
                                      softWrap: true,
                                      overflow: TextOverflow.fade,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ClipRect(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          place.description,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
          ),

          const SizedBox(height: 12),

          // ===== Кнопки дій (притиснуті до низу картки)
          Row(
            children: [
              // велика ліва кнопка
              Expanded(
                child: _YellowPrimaryButton(
                  label: 'Open on map',
                  onTap: () => context.push('/map', extra: place),
                ),
              ),
              const SizedBox(width: 12),

              // квадратна "лайк"

              // 👍 реактивна кнопка лайка
              StreamBuilder<bool>(
                stream: sl<PlacesRepository>().watchIsSaved(place.id),
                builder: (context, snap) {
                  final active =
                      snap.data ?? sl<PlacesRepository>().isSaved(place.id);
                  return _YellowIconButton(
                    icon: Icons.thumb_up_alt_rounded,
                    isActive: active,
                    onTap:
                        onToggleFavorite, // toggleFavorite оновить stream і кнопка перемалюється
                  );
                },
              ),
              const SizedBox(width: 12),

              // квадратна "шер"
              _YellowIconButton(icon: Icons.share_rounded, onTap: onShare),
            ],
          ),
        ],
      ),
    );
  }
}

class _YellowPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _YellowPrimaryButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    const radius = 22.0;
    final enabled = onTap != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1 : .6,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            height: 47, // ~як на макеті
            decoration: BoxDecoration(
              color: const Color(0xFFE0BC46),
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _YellowIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive; // 👈 додали прапорець

  const _YellowIconButton({
    required this.icon,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    const side = 50.0;
    const radius = 15.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          width: side,
          height: 47,
          decoration: BoxDecoration(
            color:
                isActive
                    ? Colors
                        .white // 👈 якщо збережено → біла
                    : const Color(0xFFE0BC46), // інакше жовта
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.44),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Center(child: Icon(icon, color: Colors.black87, size: 22)),
        ),
      ),
    );
  }
}

class _YellowActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _YellowActionButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0BC46),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Icon(
            Icons.circle, // це значення замінюється через IconTheme нижче
            color: Colors.transparent,
            size: 0,
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:chatau/core/di/di.dart';
import 'package:chatau/shared/domain/models/place.dart';
import 'package:chatau/shared/domain/repositories/places_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsFullScreen extends StatelessWidget {
  final Place place;
  const DetailsFullScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: DetailsCard(
        place: place,
        onToggleFavorite: () => sl<PlacesRepository>().toggleFavorite(place.id),
        onShare: () async {
          final text = _buildShareText(place).trim();
          if (text.isEmpty) return;

          if (Platform.isAndroid) {
            // ANDROID: кастомний лист — оминаємо системний Chooser
            final handled = await _shareTextAndroidCustomSheet(
              context,
              subject: place.name,
              body: text,
            );

            if (!handled) {
              // fallback — скопіюємо текст, щоб юзер не втратив
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Немає доступних застосунків. Текст скопійовано.',
                    ),
                  ),
                );
              }
            }
          } else {
            // iOS: нативний шерінг OK
            final subject =
                place.name.length > 120
                    ? place.name.substring(0, 120)
                    : place.name;
            await Share.share(text, subject: subject);
          }
        },
      ),
    );
  }
}

String _buildShareText(Place p) {
  final latOk = p.lat.isFinite;
  final lngOk = p.lng.isFinite;
  final mapUrl =
      (latOk && lngOk) ? 'https://maps.google.com/?q=${p.lat},${p.lng}' : '';
  final fact =
      (p.fact == null || p.fact!.trim().isEmpty) ? '' : '\n\nFact: ${p.fact}';
  final mapLine = mapUrl.isEmpty ? '' : '\n\nLocation: $mapUrl';
  return '${p.name}\n\n${p.description}$fact$mapLine';
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
        mainAxisSize: MainAxisSize.max,
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

          // ===== Центр картки (без скролу) =====
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
                            tabAlignment: TabAlignment.start,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicator: const UnderlineTabIndicator(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            labelPadding: EdgeInsets.zero,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white70,
                            dividerColor: Colors.transparent,
                            labelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            tabs: const [
                              Tab(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('Description'),
                                ),
                              ),
                              Tab(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('Interesting fact'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                // Description
                                ClipRect(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        place.description,
                                        softWrap: true,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Interesting fact
                                ClipRect(
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        place.fact ?? '',
                                        softWrap: true,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          height: 1.35,
                                        ),
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

          // ===== Тільки кнопки лайка і шер =====
          Row(
            children: [
              StreamBuilder<bool>(
                stream: sl<PlacesRepository>().watchIsSaved(place.id),
                builder: (context, snap) {
                  final active =
                      snap.data ?? sl<PlacesRepository>().isSaved(place.id);
                  return _YellowIconButton(
                    icon: Icons.thumb_up_alt_rounded,
                    isActive: active,
                    onTap: onToggleFavorite,
                  );
                },
              ),
              const SizedBox(width: 12),
              _YellowIconButton(icon: Icons.share_rounded, onTap: onShare),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class _YellowIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isActive;

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
            color: isActive ? Colors.white : const Color(0xFFE0BC46),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Center(child: Icon(icon, color: Colors.black87, size: 22)),
        ),
      ),
    );
  }
}

/// ===== КАСТОМНИЙ ШЕРИНГ ДЛЯ ANDROID (оминаємо системний Chooser) =====

class _ShareTarget {
  final String name;
  final IconData icon;
  final Uri Function() uriBuilder;
  const _ShareTarget({
    required this.name,
    required this.icon,
    required this.uriBuilder,
  });
}

Future<bool> _shareTextAndroidCustomSheet(
  BuildContext context, {
  required String subject,
  required String body,
}) async {
  if (!Platform.isAndroid) return false;

  final List<_ShareTarget> targets = [
    _ShareTarget(
      name: 'Telegram',
      icon: Icons.telegram,
      uriBuilder: () => Uri.parse('tg://msg?text=${Uri.encodeComponent(body)}'),
    ),
    _ShareTarget(
      name: 'WhatsApp',
      icon: Icons.chat,
      uriBuilder:
          () => Uri.parse('whatsapp://send?text=${Uri.encodeComponent(body)}'),
    ),
    _ShareTarget(
      name: 'Viber',
      icon: Icons.sms, // можна підібрати іншу іконку
      uriBuilder:
          () => Uri.parse('viber://forward?text=${Uri.encodeComponent(body)}'),
    ),
    _ShareTarget(
      name: 'Gmail',
      icon: Icons.email,
      uriBuilder:
          () => Uri.parse(
            'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
          ),
    ),
    _ShareTarget(
      name: 'SMS',
      icon: Icons.sms_outlined,
      uriBuilder: () => Uri.parse('sms:?body=${Uri.encodeComponent(body)}'),
    ),
  ];

  final available = <_ShareTarget>[];
  for (final t in targets) {
    if (await canLaunchUrl(t.uriBuilder())) {
      available.add(t);
    }
  }
  if (available.isEmpty) return false;

  // ignore: use_build_context_synchronously
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black87,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Поділитися через',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in available)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await launchUrl(
                          t.uriBuilder(),
                          mode: LaunchMode.externalApplication,
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.of(ctx).maybePop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(t.icon),
                      label: Text(t.name),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );

  return true;
}

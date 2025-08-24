import 'package:flutter/material.dart';
import 'package:chatau/shared/domain/models/place.dart';
import 'package:chatau/core/di/di.dart';
import 'package:chatau/shared/domain/repositories/places_repository.dart';

class PlaceDetailsSheet extends StatelessWidget {
  final Place place;
  const PlaceDetailsSheet({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    // відступ зверху/знизу, щоб не перекривати твою нижню панель
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 12),
        child: _Card(place: place),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  final Place place;
  const _Card({required this.place});

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> with SingleTickerProviderStateMixin {
  late final tabs = <_TabSpec>[
    _TabSpec('Description', widget.place.description),
    // if ((widget.place.funFact ?? '').isNotEmpty)
    // _TabSpec('Interesting fact', widget.place.funFact!),
  ];
  late final controller = TabController(length: tabs.length, vsync: this);

  @override
  Widget build(BuildContext context) {
    const radius = 28.0;

    return Material(
      color: Colors.transparent,
      child: Container(
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Верхній рядок: back/close
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Spacer(),
              ],
            ),

            // Фото
            if (widget.place.image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  widget.place.image!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Назва + зірки
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.place.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(5, (i) {
                    final filled = i < widget.place.rating;
                    return Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        filled ? Icons.star : Icons.star_border,
                        color: Colors.amberAccent,
                        size: 18,
                      ),
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Координати
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.place.lat.toStringAsFixed(4)}, ${widget.place.lng.toStringAsFixed(4)}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 12),

            // Tabs
            if (tabs.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: controller,
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: tabs.map((t) => Tab(text: t.title)).toList(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 160, // фіксована висота під текст
                child: TabBarView(
                  controller: controller,
                  children:
                      tabs.map((t) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            t.body,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1.35,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Дії: у вибране / поділитись
            Row(
              children: [
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE8C24D),
                  ),
                  onPressed: () {
                    sl<PlacesRepository>().toggleFavorite(widget.place.id);
                    setState(() {}); // оновимо іконку
                  },
                  icon: Icon(
                    widget.place.favorite
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: Colors.black,
                  ),
                  tooltip: 'Save',
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE8C24D),
                  ),
                  onPressed: () {
                    // TODO: інтегруй share_plus за бажанням
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share tapped')),
                    );
                  },
                  icon: const Icon(Icons.share, color: Colors.black),
                  tooltip: 'Share',
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabSpec {
  final String title;
  final String body;
  const _TabSpec(this.title, this.body);
}

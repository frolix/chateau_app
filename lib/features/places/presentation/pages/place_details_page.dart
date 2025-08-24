// lib/features/places/presentation/pages/place_details_page.dart
import 'package:chatau/features/places/presentation/pages/place_datail_open_map.dart';
import 'package:flutter/material.dart';
import 'package:chatau/shared/domain/models/place.dart';

class PlaceDetailsPage extends StatefulWidget {
  const PlaceDetailsPage({super.key, required this.place});
  final Place place;

  @override
  State<PlaceDetailsPage> createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    // Тригерим появу слайду після побудови
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _show = true);
    });
  }

  void _pop() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final padTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor:
          Colors.transparent, // дозволяє побачити slide-in без білого фону
      body: Stack(
        children: [
          // легкий бекдроп
          Positioned.fill(
            child: GestureDetector(
              onTap: _pop,
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),

          // сам слайд із деталями (аналог твого _DetailsSlide)
          AnimatedSlide(
            offset: _show ? Offset.zero : const Offset(1, 0),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  // трохи опустимо, щоб не перекривати кнопку Back
                  Positioned.fill(
                    top: 68,
                    child: DetailsFullScreenMap(place: widget.place),
                  ),

                  // Back
                  Positioned(
                    left: 12,
                    top: 12 + padTop / 2,
                    child: IconButton(
                      onPressed: _pop,
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black26,
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(48, 48),
                      ),
                      tooltip: 'Back',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapCard extends StatelessWidget {
  /// Якщо хочеш зробити карту не інтерактивною – постав false
  final bool interactive;

  /// Центр карти
  final LatLng center;

  /// Початковий zoom
  final double zoom;

  /// Маркери (необов’язково)
  final List<LatLng> points;

  /// Тап по картці → відкрити повноекранну мапу
  final VoidCallback? onOpenFull;

  const MapCard({
    super.key,
    this.interactive = true,
    this.center = const LatLng(48.8566, 2.3522),
    this.zoom = 12,
    this.points = const [
      LatLng(48.853, 2.349),
      LatLng(48.861, 2.335),
      LatLng(48.866, 2.312),
      LatLng(48.855, 2.371),
      LatLng(48.845, 2.325),
      LatLng(48.872, 2.345),
      LatLng(48.858, 2.303),
    ],
    this.onOpenFull,
  });

  static const double _w = 355;
  static const double _h = 320;
  static const double _radius = 28;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: _w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E46FF).withOpacity(0.4),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFF2E46FF), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: SizedBox(
            height: _h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ---- OpenStreetMap через flutter_map ----
                FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: zoom,
                    interactionOptions:
                        interactive
                            ? const InteractionOptions(
                              // фіксуємо горизонт (без обертання)
                              flags:
                                  InteractiveFlag.all & ~InteractiveFlag.rotate,
                            )
                            : const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.example.chatau',
                    ),
                    MarkerLayer(
                      markers:
                          points
                              .map(
                                (p) => Marker(
                                  point: p,
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/images/map-pin.png',
                                    width: 24,
                                    height: 38,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),

                // Легка затемнююча вуаль
                IgnorePointer(
                  child: Container(color: Colors.black.withOpacity(0.25)),
                ),

                // Прозорий шар для кліку по всій картці
                if (onOpenFull != null)
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(onTap: onOpenFull),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





/*

import 'package:chatau/features/home_tab/presentation/widgets/detail_full_screen.dart';
import 'package:flutter/material.dart';

import 'package:chatau/features/home_tab/presentation/widgets/guide_header_card.dart';
import 'package:chatau/features/home_tab/presentation/widgets/map_card.dart';
import 'package:chatau/features/home_tab/presentation/widgets/places_map_overlay.dart';
import 'package:chatau/shared/domain/models/place.dart';

enum _OverlayStage { map, details }

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _overlayVisible = false;
  _OverlayStage _stage = _OverlayStage.map;
  Place? _selected;

  void _openOverlayWithMap() {
    setState(() {
      _overlayVisible = true;
      _stage = _OverlayStage.map;
      _selected = null;
    });
  }

  void _closeOverlay() {
    setState(() {
      _overlayVisible = false;
      _selected = null;
      _stage = _OverlayStage.map;
    });
  }

  void _openDetails(Place p) {
    setState(() {
      _selected = p;
      _stage = _OverlayStage.details;
    });
  }

  void _backFromDetails() {
    setState(() {
      _stage = _OverlayStage.map; // 👈 не чіпаємо _selected тут
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    const targetTop = 59.0;
    final extraTop = (targetTop - safeTop).clamp(0.0, double.infinity);

    return Stack(
      children: [
        // ---- Контент вкладки ----
        ListView(
          padding: EdgeInsets.only(top: extraTop, bottom: 12),
          children: [
            if (!_overlayVisible) ...[
              const GuideHeaderCard(),
              const SizedBox(height: 16),
              MapCard(interactive: false, onOpenFull: _openOverlayWithMap),
            ],
            const SizedBox(height: 16),
          ],
        ),

        // ---- Повноекранний шар ----
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          left: 0,
          right: 0,
          top: _overlayVisible ? 0 : MediaQuery.of(context).size.height,
          bottom: 0,
          child: IgnorePointer(
            ignoring: !_overlayVisible,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _overlayVisible ? 1 : 0,
              child: Material(
                color: Colors.transparent, // фон під вмістом
                child: SafeArea(
                  child: Stack(
                    children: [
                      // ==================== 1) КОНТЕНТ ПІД НИЗОМ ====================
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: ClipRect(
                          // обрізає все, що виїхало
                          child: Stack(
                            clipBehavior: Clip.hardEdge,
                            children: [
                              // MAP
                              IgnorePointer(
                                ignoring: _stage != _OverlayStage.map,
                                child: AnimatedSlide(
                                  offset:
                                      _stage == _OverlayStage.map
                                          ? Offset.zero
                                          : const Offset(-1, 0),
                                  duration: const Duration(milliseconds: 380),
                                  curve: Curves.easeOutCubic,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: PlacesMapOverlay(
                                      key: const ValueKey('overlay-map'),
                                      onClose: _closeOverlay,
                                      onOpenDetails: _openDetails,
                                    ),
                                  ),
                                ),
                              ),

                              // DETAILS (починається НИЖЧЕ кнопки "назад")
                              IgnorePointer(
                                ignoring: _stage != _OverlayStage.details,
                                child: AnimatedSlide(
                                  offset:
                                      _stage == _OverlayStage.details
                                          ? Offset.zero
                                          : const Offset(1, 0),
                                  duration: const Duration(milliseconds: 380),
                                  curve: Curves.easeOutCubic,
                                  onEnd: () {
                                    if (!mounted) return;
                                    if (_stage != _OverlayStage.details &&
                                        _selected != null) {
                                      setState(() => _selected = null);
                                    }
                                  },
                                  child: Material(
                                    color: Colors.transparent,
                                    child:
                                        (_selected != null)
                                            ? Padding(
                                              // >>> цим відсуваємо картку нижче кнопки
                                              padding: const EdgeInsets.only(
                                                top:
                                                    68, // 12 (відступ зверху) + ~48 (розмір кнопки) + 8 запас
                                              ),
                                              child: DetailsFullScreen(
                                                key: const ValueKey(
                                                  'overlay-details',
                                                ),
                                                place: _selected!,
                                              ),
                                            )
                                            : const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ==================== 2) КНОПКИ НАД КОНТЕНТОМ ====================
                      if (_stage == _OverlayStage.details)
                        Positioned(
                          left: 12,
                          top: 12,
                          child: IconButton(
                            onPressed: _backFromDetails,
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.transparent, // без підкладки
                              foregroundColor: Colors.white,
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
            ),
          ),
        ),
      ],
    );
  }
}

*/

/*
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:chatau/features/home_tab/presentation/widgets/guide_header_card.dart';
import 'package:chatau/features/home_tab/presentation/widgets/places_map_overlay.dart';
import 'package:chatau/features/home_tab/presentation/widgets/detail_full_screen.dart';
import 'package:chatau/shared/domain/models/place.dart';

enum _OverlayStage { map, details }

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // ---- стани ----
  bool _expanded = false; // карта розгорнута на весь екран?
  _OverlayStage _stage = _OverlayStage.map;
  Place? _selected;

  // ---- вимірювання позиції “дірки” під маленьку карту ----
  final _listCtrl = ScrollController();
  final _holeKey = GlobalKey();
  Rect? _holeRect; // глобальні координати “дірки”

  // Розміри маленької картки (як у макеті)
  static const double _cardW = 355;
  static const double _cardH = 320;
  static const double _cardRadius = 28;

  @override
  void initState() {
    super.initState();
    _listCtrl.addListener(_updateHoleRectThrottled);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHoleRect());
  }

  @override
  void dispose() {
    _listCtrl.removeListener(_updateHoleRectThrottled);
    _listCtrl.dispose();
    super.dispose();
  }

  // Трохи “дебаунсимо” оновлення під час скролу
  bool _pending = false;
  void _updateHoleRectThrottled() {
    if (_expanded) return; // коли фулскрін — не треба
    if (_pending) return;
    _pending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHoleRect();
      _pending = false;
    });
  }

  void _updateHoleRect() {
    if (!mounted) return;
    final ctx = _holeKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final topLeft = box.localToGlobal(Offset.zero);
    final size = box.size;
    setState(() {
      _holeRect = Rect.fromLTWH(
        topLeft.dx,
        topLeft.dy,
        size.width,
        size.height,
      );
    });
  }

  // ---- дії ----
  void _onTapSmallMap() {
    setState(() {
      _expanded = true; // розгортаємось
      _stage = _OverlayStage.map; // стартуємо зі стану “мапа”
    });
  }

  void _closeFull() {
    setState(() {
      _expanded = false; // згортаємось назад
      _stage = _OverlayStage.map;
      _selected = null;
      // після згортування переміряємо “дірку”
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateHoleRect());
    });
  }

  void _openDetails(Place p) {
    setState(() {
      _selected = p;
      _stage = _OverlayStage.details;
    });
  }

  void _backFromDetails() {
    setState(() => _stage = _OverlayStage.map);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final fullW = mq.size.width;
    final fullH = mq.size.height;

    // Позиція для згорнутого стану: беремо з виміряної “дірки”
    final collapsedTop = _holeRect?.top ?? math.max(mq.padding.top + 100, 140);
    final collapsedLeft = _holeRect?.left ?? (fullW - _cardW) / 2;
    final collapsedW = _holeRect?.width ?? _cardW;
    final collapsedH = _holeRect?.height ?? _cardH;

    return Stack(
      children: [
        // ================== 1) ЗВИЧАЙНИЙ СКРОЛ-КОНТЕНТ ==================
        ListView(
          controller: _listCtrl,
          padding: const EdgeInsets.only(top: 59, bottom: 24),
          children: [
            // Ховаємо хедер, коли карта фулскрін
            if (!_expanded) ...[
              const GuideHeaderCard(),
              const SizedBox(height: 16),
            ],

            // “Дірка” під маленьку карту (самої карти тут нема!)
            // Висота/ширина як у картки, щоб макет лишався
            Center(
              child: SizedBox(
                key: _holeKey,
                width: _cardW,
                height: _cardH,
                // якщо бажаєш клік по “дірці” також відкривав — додай GestureDetector
                child: const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 600), // інший демо-контент
          ],
        ),

        // ================== 2) ЄДИНА КАРТА ЗВЕРХУ ==================
        AnimatedPositioned(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          top: _expanded ? 0 : collapsedTop,
          left: _expanded ? 0 : collapsedLeft,
          width: _expanded ? fullW : collapsedW,
          height: _expanded ? fullH : collapsedH,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_expanded ? 0 : _cardRadius),
              // рамка+тінь у згорнутому стані (як картка)
              boxShadow:
                  _expanded
                      ? const []
                      : [
                        BoxShadow(
                          color: const Color(0xFF2E46FF).withOpacity(0.4),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
              border:
                  _expanded
                      ? null
                      : Border.all(color: const Color(0xFF2E46FF), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // ---- ТУТ ЖИВЕ ЄДИНА КАРТА ----
                PlacesMapOverlay(
                  key: const ValueKey('home-map-one-and-only'),
                  onClose: _closeFull, // закрити фулскрін
                  onOpenDetails: _openDetails, // відкрити деталі
                  // всередині самого overlay ти вже керуєш вибором + міні-карткою
                ),

                // Легка вуаль + блокування взаємодій у згорнутому стані
                if (!_expanded)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(color: Colors.black.withOpacity(0.25)),
                    ),
                  ),
                if (!_expanded)
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(onTap: _onTapSmallMap),
                    ),
                  ),

                // ---- КНОПКИ ЛИШЕ У ФУЛСКРІНІ ----
                if (_expanded) ...[
                  // Закрити фулскрін
                  Positioned(
                    right: 12,
                    top: 12 + mq.padding.top,
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.35),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _closeFull,
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ),

                  // Назад з details у map (кнопка над деталями)
                  if (_stage == _OverlayStage.details)
                    Positioned(
                      left: 12,
                      top: 12 + mq.padding.top,
                      child: IconButton(
                        onPressed: _backFromDetails,
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(48, 48),
                        ),
                        tooltip: 'Back',
                      ),
                    ),

                  // Зсув деталей нижче кнопки "Back" (якщо вони відкриті)
                  if (_stage == _OverlayStage.details && _selected != null)
                    Positioned.fill(
                      top: 68, // 12 паддінг + ~48 кнопка + запас
                      child: DetailsFullScreen(place: _selected!),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
*/



/*

@override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // ---- Список місць ----
        StreamBuilder<List<Place>>(
          stream: sl<PlacesRepository>().watch(),
          builder: (context, snap) {
            final places = snap.data ?? [];

            return ListView(
              padding: EdgeInsets.only(
                top: (59.0 - safeTop).clamp(0.0, double.infinity),
                bottom: 24 + MediaQuery.of(context).padding.bottom,
              ),
              children: [
                const GuideHeaderCard(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Recommended places',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                for (final p in places)
                  PlaceCard(
                    place: p,
                    onOpen: () => _openDetails(p),
                    margin: const EdgeInsets.only(bottom: 12),
                  ),
              ],
            );
          },
        ),

        // ---- Деталі ----
        IgnorePointer(
          ignoring: _stage != _Stage.details,
          child: _DetailsSlide(selected: _selected, onBack: _back),
        ),
      ],
    );
  }

*/
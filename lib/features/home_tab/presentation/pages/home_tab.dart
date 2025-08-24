import 'package:flutter/material.dart';
import 'package:chatau/features/home_tab/presentation/widgets/guide_header_card.dart';
import 'package:chatau/features/home_tab/presentation/widgets/places_map_overlay.dart'
    show PlacesMapOverlay, MapFrame; // беремо і карту, і рамку
import 'package:chatau/features/home_tab/presentation/widgets/detail_full_screen.dart';
import 'package:chatau/shared/domain/models/place.dart';

enum _OverlayStage { map, details }

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _stackKey = GlobalKey();
  final _miniKey = GlobalKey();
  final _scroll = ScrollController();

  bool _overlayVisible = false;
  _OverlayStage _stage = _OverlayStage.map;
  Place? _selected;

  Rect? _miniRectLocal; // координати малого слоту відносно Stack

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_recalcMiniRect);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recalcMiniRect());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recalcMiniRect());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

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

  void _backFromDetails() => setState(() => _stage = _OverlayStage.map);
  bool get _isExpandedMap => _overlayVisible && _stage == _OverlayStage.map;

  void _recalcMiniRect() {
    final miniCtx = _miniKey.currentContext;
    final stackCtx = _stackKey.currentContext;
    if (miniCtx == null || stackCtx == null) return;

    final miniBox = miniCtx.findRenderObject() as RenderBox?;
    final stackBox = stackCtx.findRenderObject() as RenderBox?;
    if (miniBox == null || stackBox == null) return;

    final miniGlobal = miniBox.localToGlobal(Offset.zero);
    final stackGlobal = stackBox.localToGlobal(Offset.zero);
    final localTopLeft = miniGlobal - stackGlobal;
    final rect = localTopLeft & miniBox.size;

    if (_miniRectLocal != rect) {
      setState(() => _miniRectLocal = rect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    const targetTop = 32.0;
    final extraTop = (targetTop - safeTop).clamp(0.0, double.infinity);
    final size = MediaQuery.of(context).size;

    // куди анімувати карту (з малого слоту у весь екран)
    final bool haveMini = _miniRectLocal != null;
    final left = 0.0;
    final top = _overlayVisible || !haveMini ? 0.0 : _miniRectLocal!.top;
    final right =
        0.0; // _overlayVisible || !haveMini ? 0.0 : size.width - (_miniRectLocal!.left + _miniRectLocal!.width);

    final bottom = 28.0; // відступ знизу, щоб не було впритул до низу

    final double collapsedRadius = 28.0;
    final double radius = _overlayVisible ? 0.0 : collapsedRadius;

    return Stack(
      key: _stackKey,
      children: [
        // ---- Контент під картою ----
        ListView(
          controller: _scroll,
          padding: EdgeInsets.only(top: extraTop, bottom: 12),
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _overlayVisible ? 0 : 1,
              child: const GuideHeaderCard(),
            ),
            const SizedBox(height: 16),

            // Прозорий слот (без декору) — саме в це вікно «стає» карта.
            _MiniMapSlot(
              key: _miniKey,
              height: MediaQuery.of(context).size.height * 0.42,
              padding: const EdgeInsets.symmetric(horizontal: 0), // або 16/19
            ),
          ],
        ),

        // ---- ЄДИНА КАРТА (анімуємо її позицію/радіус; рамка лише у згорнутому стані) ----
        if (haveMini || _overlayVisible)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            left: left,
            top: top,
            right: right,
            bottom: bottom,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: radius, end: radius),
              duration: const Duration(milliseconds: 320),
              builder: (_, r, child) {
                return MapFrame(
                  radius: r,
                  enabled: !_overlayVisible, // у фулскріні без градієнта/тіні
                  child: child!,
                );
              },
              child: Stack(
                fit: StackFit.expand, // <-- важливо: заповнюй весь прямокутник

                children: [
                  // ===== КАРТА: зсуваємо вліво коли відкриті деталі =====
                  IgnorePointer(
                    // карта інтерактивна лише коли розгорніута і в режимі map
                    ignoring:
                        (!_overlayVisible) || (_stage != _OverlayStage.map),
                    child: AnimatedSlide(
                      offset:
                          _stage == _OverlayStage.map
                              ? Offset.zero
                              : const Offset(-1, 0),
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                      child: Material(
                        color: Colors.transparent,
                        child: SizedBox.expand(
                          child: PlacesMapOverlay(
                            key: const ValueKey('single-map'),
                            onClose: _closeOverlay,
                            onOpenDetails: _openDetails,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // --- КНОПКА "ВІДКРИТИ" у згорнутому стані ---
                  if (!_overlayVisible)
                    Positioned(
                      right: 16,
                      bottom: 16 + MediaQuery.of(context).padding.bottom,
                      child: _ExpandCollapseFab(
                        expanded: false,
                        onTap: _openOverlayWithMap,
                      ),
                    ),

                  // --- КНОПКА "ЗГОРНУТИ" у розгорнутому стані ---
                  if (_isExpandedMap)
                    Positioned(
                      right: 16,
                      top: 16 + MediaQuery.of(context).padding.top,
                      child: _ExpandCollapseFab(
                        expanded: true,
                        onTap: _closeOverlay,
                      ),
                    ),

                  // Легкий затемнювач + "тап — розгорнути" у згорнутому стані
                  if (!_overlayVisible)
                    Positioned.fill(
                      child: InkWell(
                        onTap: _openOverlayWithMap,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.05),
                                Colors.black.withOpacity(0.12),
                              ],
                            ),
                          ),
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),

                  // ===== ДЕТАЛІ: заїжджають справа та перекривають карту =====
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
                                  // трохи нижче, щоб не перекривати кнопку "назад"
                                  padding: const EdgeInsets.only(top: 68),
                                  child: DetailsFullScreen(place: _selected!),
                                )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  ),

                  // ---- Кнопка Back поверх details ----
                  if (_stage == _OverlayStage.details)
                    Positioned(
                      left: 12,
                      top: 12 + MediaQuery.of(context).padding.top / 2,
                      child: IconButton(
                        onPressed: _backFromDetails,
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
    );
  }
}

/// ✅ Слот, що тягнеться на всю ширину ListView (з опціональними відступами)
class _MiniMapSlot extends StatelessWidget {
  const _MiniMapSlot({
    super.key,
    required this.height,
    this.padding = EdgeInsets.zero,
  });
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        width: double.infinity, // повна ширина
        height: height,
      ),
    );
  }
}

class _ExpandCollapseFab extends StatelessWidget {
  const _ExpandCollapseFab({
    super.key,
    required this.expanded,
    required this.onTap,
  });
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder:
          (child, anim) => ScaleTransition(scale: anim, child: child),
      child: FloatingActionButton.small(
        key: ValueKey(expanded), // щоб анімація перемикалась
        onPressed: onTap,
        heroTag: expanded ? 'fab-collapse' : 'fab-expand',
        child: Icon(expanded ? Icons.unfold_less : Icons.unfold_more),
      ),
    );
  }
}

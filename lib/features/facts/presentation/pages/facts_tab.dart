import 'package:chatau/features/facts/presentation/widgets/guide_facts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:chatau/core/di/di.dart';
import 'package:chatau/features/home_tab/presentation/widgets/guide_header_card.dart';
import 'package:chatau/shared/domain/models/fact.dart';
import 'package:chatau/shared/domain/repositories/facts_repository.dart';

class FactsTab extends StatefulWidget {
  const FactsTab({super.key});

  @override
  State<FactsTab> createState() => _FactsTabState();
}

class _FactsTabState extends State<FactsTab> with TickerProviderStateMixin {
  List<Fact> _facts = const [];
  int _cursor = -1; // ще нічого не показували
  bool _cardVisible = false;

  @override
  void initState() {
    super.initState();
    // підпишемось на факти
    sl<FactsRepository>().watch().listen((items) {
      if (!mounted) return;
      setState(() {
        _facts = [...items]..sort((a, b) => a.id.compareTo(b.id));
      });
    });
  }

  void _nextFact() {
    if (_facts.isEmpty) return;
    setState(() {
      // пройдемось по колу, але без повторів поки не вичерпались
      _cursor = (_cursor + 1) % _facts.length;
      _cardVisible = true;
    });
  }

  Fact? get _current =>
      (_cursor >= 0 && _cursor < _facts.length) ? _facts[_cursor] : null;

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final bottomPad = 24 + MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // твій фон/градієнт/фото, якщо є
        // const _Background(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.only(top: safeTop),
              child: const GuideFactsCard(),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Stack(
                children: [
                  // картка факта
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child:
                        !_cardVisible || _current == null
                            ? const SizedBox.shrink(key: ValueKey('empty'))
                            : _FactCard(
                              key: ValueKey(_current!.id),
                              fact: _current!,
                              index:
                                  _cursor, // заголовок "#N Fact" всередині картки
                              onNext: _nextFact,
                            ),
                  ),

                  // ⬇️ 2) Кнопка "Get a new story" тільки ДО першої картки
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: bottomPad,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child:
                          !_cardVisible
                              ? _PrimaryButton(
                                key: const ValueKey('cta'),
                                label: 'Get a new story',
                                onPressed: _facts.isEmpty ? null : _nextFact,
                              )
                              : const SizedBox.shrink(key: ValueKey('no-cta')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ],
    );
  }
}

class _FactCard extends StatelessWidget {
  final Fact fact;
  final int index; // 0-based
  final VoidCallback onNext;

  const _FactCard({
    super.key,
    required this.fact,
    required this.index,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 32.0;
    final bottomInset = 16.0 + MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity, // заповнюємо всю доступну висоту
          margin: const EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.fromLTRB(20, 24, 20, bottomInset),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: const LinearGradient(
              begin:
                  Alignment
                      .topCenter, // або topLeft → bottomRight, якщо так у макеті
              end: Alignment.bottomCenter,
              colors: [Color(0xFF020B65), Color(0xFF0416CB)],
            ),
            border: Border.all(color: Colors.white12, width: 1),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF0416CB).withOpacity(0.35),
                blurRadius: 28,
                offset: Offset(0, 18),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.max, // ⬅️ тягнемося на всю висоту
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===== Верх: номер факту
              const SizedBox(height: 8),

              Text(
                '#${index + 1} Fact',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 12),

              // ===== Центр: сам факт (центрований по вертикалі)
              Expanded(
                child: Center(
                  child: Text(
                    fact.text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.92),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // ===== Низ: кнопки, «приклеєні» до низу
              Row(
                children: [
                  Expanded(
                    child: _YellowCTA(label: 'New fact', onPressed: onNext),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _YellowCTA(
                      label: 'Share',
                      onPressed: () => Share.share(fact.text),
                      onLongPress: () async {
                        await Clipboard.setData(ClipboardData(text: fact.text));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _YellowCTA extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  const _YellowCTA({
    super.key,
    required this.label,
    this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: ElevatedButton.styleFrom(
        elevation: 10,
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: const Color(0xFFF0C74B),
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        shadowColor: Colors.black.withOpacity(0.35),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Просте сповіщення, щоб дістатись до _nextFact із дочірнього віджета
class _RequestNextFactNotification extends Notification {}

/// Базова кнопка як на макеті (жовта)
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _PrimaryButton({required this.label, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        backgroundColor: const Color(0xFFF0C74B),
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );

    // Щоб _FactCard могла викликати наступний факт
    return NotificationListener<_RequestNextFactNotification>(
      onNotification: (_) {
        onPressed?.call();
        return true;
      },
      child: btn,
    );
  }
}

/// Сіра вторинна кнопка
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  const _SecondaryButton({
    required this.label,
    this.onPressed,
    this.onLongPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

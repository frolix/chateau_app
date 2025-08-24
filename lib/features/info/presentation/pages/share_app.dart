import 'package:chatau/features/info/presentation/widgets/guide_header_card_invite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

/// Екран-запрошення з двома кнопками в картці:
/// Share app / Rate app
class InviteTab extends StatelessWidget {
  const InviteTab({super.key});

  // TODO: заміни на свій ідентифікатор застосунку в App Store
  static const String _appStoreId = '0000000000';
  // TODO: за бажанням — посилання на сайт/маркет для шерингу
  static const String _shareLink = 'https://www.google.com';

  Future<void> _share() async {
    await Share.share(
      'Try CHÂTEAU — stories, places & wine guide! $_shareLink',
    );
  }

  Future<void> _rate() async {
    final inAppReview = InAppReview.instance;

    try {
      // Спроба нативного in-app промпта
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        return;
      }
    } catch (_) {
      // ігноруємо — підемо у стор
    }

    // Якщо in-app недоступний — відкриємо стор
    try {
      await inAppReview.openStoreListing(appStoreId: _appStoreId);
    } catch (_) {
      // запасний варіант — пряме посилання (наприклад, на сайт)
      final uri = Uri.parse(_shareLink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.only(top: safeTop),
              child: const GuideHeaderCardInvite(),
            ),
            const SizedBox(height: 24),

            // Картка з двома кнопками
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: _ShareRateCard(
                bottomInset:
                    20, // або 16–20; не обов'язково тягнути safe-bottom сюди
                onShare: _share,
                onRate: _rate,
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ],
    );
  }
}

class _ShareRateCard extends StatelessWidget {
  final double bottomInset;
  final VoidCallback onShare;
  final VoidCallback onRate;

  const _ShareRateCard({
    required this.bottomInset,
    required this.onShare,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 32.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.fromLTRB(20, 24, 20, bottomInset),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF020B65), Color(0xFF0416CB)],
          ),
          border: Border.all(color: Colors.white12, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0416CB).withValues(alpha: 0.35),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _YellowCTA(
                    label: 'Share app',
                    onPressed: onShare,
                    onLongPress: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: InviteTab._shareLink),
                      );
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _YellowCTA(label: 'Rate app', onPressed: onRate),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

/// Жовта кнопка як у FactsTab
class _YellowCTA extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  const _YellowCTA({required this.label, this.onPressed, this.onLongPress});

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
        shadowColor: Colors.black.withValues(alpha: 0.35),
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

import 'package:flutter/material.dart';

class BottomTabsBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const BottomTabsBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  // ⚠️ Імена файлів чутливі до регістру
  static const String _p = 'assets/images/menu_btns';
  static const String _home = '$_p/HOME.png';
  static const String _places = '$_p/subway_location.png';
  static const String _facts = '$_p/iconoir_light-bulb.png';
  static const String _saved = '$_p/iconamoon_like-light.png';
  static const String _info = '$_p/fluent_settings-28-regular.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1C5C), Color(0xFF2D1B73)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _AssetNavItem(
            path: _home,
            selected: currentIndex == 0,
            onTap: () => onChanged(0),
          ),
          _AssetNavItem(
            path: _places,
            selected: currentIndex == 1,
            onTap: () => onChanged(1),
          ),
          _AssetNavItem(
            path: _facts,
            selected: currentIndex == 2,
            onTap: () => onChanged(2),
          ),
          _AssetNavItem(
            path: _saved,
            selected: currentIndex == 3,
            onTap: () => onChanged(3),
          ),
          _AssetNavItem(
            path: _info,
            selected: currentIndex == 4,
            onTap: () => onChanged(4),
          ),
        ],
      ),
    );
  }
}

class _AssetNavItem extends StatelessWidget {
  final String path;
  final bool selected;
  final VoidCallback onTap;

  const _AssetNavItem({
    required this.path,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (selected) {
      // Активна кнопка — жовта "піллюля" з чорним значком
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC736),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFC736).withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: ImageIcon(
              AssetImage(path),
              size: 35,
              color: Colors.black, // тінт у чорний
            ),
          ),
        ),
      );
    }

    // Неактивна — просто біла іконка
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: ImageIcon(
            AssetImage(path),
            size: 35,
            color: Colors.white, // тінт у білий
          ),
        ),
      ),
    );
  }
}

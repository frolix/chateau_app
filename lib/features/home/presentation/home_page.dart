import 'package:chatau/features/facts/presentation/pages/facts_tab.dart';
import 'package:chatau/features/home_tab/presentation/pages/home_tab.dart';
import 'package:chatau/features/info/presentation/pages/share_app.dart';
import 'package:chatau/features/places/presentation/pages/places_tab_page.dart';
import 'package:chatau/features/saved/presentation/pages/user_places_page.dart';
import 'package:chatau/features/splash/domain/widgets/bottom_tabs_bar.dart';
import 'package:chatau/features/widgetsutils/background.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Stack(
        children: [
          // Контент вкладок
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                120,
              ), // місце під бар
              child: IndexedStack(
                index: _index,
                children: const [
                  HomeTab(),
                  PlacesTab(),
                  FactsTab(),
                  UserPlacesPage(),
                  InviteTab(),
                ],
              ),
            ),
          ),

          // Нижній навбар як на макеті
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: BottomTabsBar(
              currentIndex: _index,
              onChanged: (i) => setState(() => _index = i),
            ),
          ),
        ],
      ),
    );
  }
}

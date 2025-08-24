import 'package:chatau/core/di/bootstrap.dart';
import 'package:chatau/core/di/bootstrap_facts.dart';
import 'package:chatau/core/di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chatau/l10n/app_localizations.dart'; // згенерований файл (synthetic-package: false)
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDI();
  await bootstrapPlacesIfEmpty(); //додаємо місця, якщо порожньо
  await factsBootstrap(); // додаємо факти, якщо порожньо

  runApp(const ChatauApp());
}

class ChatauApp extends StatelessWidget {
  const ChatauApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'chatau',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Montserrat'),
      routerConfig: appRouter,

      // 🔽 локалізація
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

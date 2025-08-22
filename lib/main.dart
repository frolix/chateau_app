import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chatau/l10n/app_localizations.dart'; // згенерований файл (synthetic-package: false)
import 'app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChatauApp());
}

class ChatauApp extends StatelessWidget {
  const ChatauApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'chatau',
      theme: ThemeData(useMaterial3: true),
      routerConfig: appRouter,

      // 🔽 локалізація
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // locale: const Locale('uk'), // ← розкоментуй, щоб примусово увімкнути укр.
    );
  }
}

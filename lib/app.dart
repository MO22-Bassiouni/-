import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';

class ClinicApp extends StatelessWidget {
  const ClinicApp({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (_, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'صحتك',
          locale: const Locale('ar', 'EG'),
          supportedLocales: const [Locale('ar', 'EG')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: app.mode,
          theme: mk(Brightness.light),
          darkTheme: mk(Brightness.dark),
          home: const SplashScreen(),
        ),
      );
}

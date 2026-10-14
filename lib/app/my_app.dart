import 'package:flutter/material.dart';
import 'app_shell.dart';
import 'routes.dart';
import '../models/campus_event.dart';
import '../screens/detail/event_detail_screen.dart';
import '../screens/form/event_form_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF456B9A),
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Connect',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: _themeMode,
      routes: {
        Routes.home: (_) => AppShell(
              onThemeChanged: _setThemeMode,
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Routes.detail &&
            settings.arguments is DetailArgs) {
          return MaterialPageRoute<void>(
            builder: (_) => EventDetailScreen(
              args: settings.arguments! as DetailArgs,
            ),
          );
        }

        if (settings.name == Routes.form && settings.arguments is FormArgs) {
          return MaterialPageRoute<CampusEventResult>(
            builder: (_) => EventFormScreen(
              args: settings.arguments! as FormArgs,
            ),
          );
        }

        return null;
      },
      onUnknownRoute: (_) => MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Not found')),
          body: const Center(
            child: Text('This page was not found.'),
          ),
        ),
      ),
    );
  }
}

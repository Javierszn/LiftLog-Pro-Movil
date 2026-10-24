import 'package:flutter/material.dart';

import 'features/liftlog/screens/access_screen.dart';
import 'features/liftlog/services/local_database.dart';

void main() {
  runApp(const LiftLogProApp());
}

class LiftLogProApp extends StatefulWidget {
  const LiftLogProApp({super.key});

  @override
  State<LiftLogProApp> createState() => _LiftLogProAppState();
}

class _LiftLogProAppState extends State<LiftLogProApp> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final darkMode = await LocalDatabase.instance.isDarkMode();
    if (mounted) setState(() => _darkMode = darkMode);
  }

  void _changeTheme(bool darkMode) {
    setState(() => _darkMode = darkMode);
    LocalDatabase.instance.setDarkMode(darkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiftLog Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B21A8)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B21A8),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: AccessScreen(onThemeChanged: _changeTheme),
    );
  }
}

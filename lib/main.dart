import 'package:flutter/material.dart';
import 'features/liftlog/screens/access_screen.dart';

void main() {
  runApp(const LiftLogProApp());
}

class LiftLogProApp extends StatelessWidget {
  const LiftLogProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiftLog Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B4D)),
        useMaterial3: true,
      ),
      home: const AccessScreen(),
    );
  }
}
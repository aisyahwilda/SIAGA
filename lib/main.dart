import 'package:flutter/material.dart';

import 'services/earthquake_service.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.earthquakeService = const EarthquakeService()});

  final EarthquakeService earthquakeService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIAGA',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFB6C00),
          secondary: Color(0xFFF9B637),
          error: Color(0xFFE73F1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFB6C00),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: LoginScreen(earthquakeService: earthquakeService),
    );
  }
}

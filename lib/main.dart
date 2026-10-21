import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan tulisan "DEBUG"
      title: 'SIAGA',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(
          0xFFFFFFFF,
        ), // Neutral (Background)
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFB6C00), // Primary (Oranye)
          secondary: Color(0xFFF9B637), // Secondary (Kuning Emas)
          error: Color(0xFFE73F1E), // Dark/Strong (Merah-Oranye)
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFB6C00), // Warna AppBar
          foregroundColor: Colors.white, // Warna teks di AppBar
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

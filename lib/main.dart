import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/earthquake_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cupzstzndgdvgsadzgle.supabase.co',
    publishableKey: 'sb_publishable_-e6bP1WqiVANpyAvkpn1sA_9gMqlJc9',
  );

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
        scaffoldBackgroundColor: Colors.white,
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
      home: AuthGate(
        earthquakeService: earthquakeService,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.earthquakeService});

  final EarthquakeService earthquakeService;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        supabase.auth.currentSession,
      ),
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (session != null) {
          return MainScreen(
            earthquakeService: earthquakeService,
          );
        }

        return LoginScreen(
          earthquakeService: earthquakeService,
        );
      },
    );
  }
}
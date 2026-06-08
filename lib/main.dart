import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

// Diisi otomatis saat build oleh Codemagic
// Jangan isi manual di sini kalau mau upload ke GitHub
const String supabaseUrl = 'https://jyfonqzxjsigucjdlrah.supabase.co';
const String supabaseAnonKey = 'sb_publishable_EdpsxvNCQjXVxHKuvV7yLA_tGrj5iuX';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const TaniCikeasApp());
}

class TaniCikeasApp extends StatelessWidget {
  const TaniCikeasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaniCikeas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A5FC8),
          primary: const Color(0xFF1A5FC8),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

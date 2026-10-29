import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configured = _supabaseUrl.startsWith('https://') &&
      _supabaseAnonKey.isNotEmpty &&
      !_supabaseUrl.contains('YOUR_PROJECT');
  if (configured) {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  }
  runApp(LuxeChatApp(backendConfigured: configured));
}

class LuxeChatApp extends StatelessWidget {
  const LuxeChatApp({super.key, required this.backendConfigured});
  final bool backendConfigured;

  static const ink = Color(0xFF151226);
  static const violet = Color(0xFF8057F5);
  static const pink = Color(0xFFFF6FAE);
  static const mint = Color(0xFF57E6C1);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuxeChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F5FC),
        colorScheme: ColorScheme.fromSeed(seedColor: violet, brightness: Brightness.light),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF7F5FC), foregroundColor: ink, elevation: 0),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: !backendConfigured
          ? const SetupRequiredScreen()
          : StreamBuilder<AuthState>(
              stream: Supabase.instance.client.auth.onAuthStateChange,
              builder: (context, snapshot) {
                final session = Supabase.instance.client.auth.currentSession;
                return session == null ? const AuthScreen() : const ChatScreen();
              },
            ),
    );
  }
}

class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(colors: [LuxeChatApp.violet, LuxeChatApp.pink]),
                    ),
                    child: const Icon(Icons.forum_rounded, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 24),
                  const Text('LuxeChat', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: LuxeChatApp.ink)),
                  const SizedBox(height: 8),
                  const Text('Beautiful conversations. Built with care.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 28),
                  const Text('One setup step left', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Connect a Supabase project using the setup guide, then run the app with SUPABASE_URL and SUPABASE_ANON_KEY. No secret service-role key belongs in the app.'),
                  const SizedBox(height: 18),
                  const Text('The app intentionally shows this screen until backend settings are supplied. It does not pretend to be connected.', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

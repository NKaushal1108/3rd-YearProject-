import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

import 'screens/auth/registration_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_page.dart';
import 'screens/welcome_screen.dart';
import 'services/auth_service.dart';
import 'screens/profile/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider(
        'RECAPTCHA_V3_SITE_KEY', // TODO: replace with your web reCAPTCHA key
      ),
    );
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  }
  await FirebaseAuth.instance.setLanguageCode('en');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HarvestGenius',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF36883B)),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: const AuthWrapper(),
      routes: {
        '/register': (context) => const RegistrationScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

/// Wrapper widget that handles authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is authenticated, navigate to home
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }

        // If user is not authenticated, show welcome screen
        return const WelcomePage();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("First page"),
        backgroundColor: const Color.fromARGB(20, 9, 36, 11),
      ),
      backgroundColor: const Color.fromARGB(255, 47, 127, 52),
    );
  }
}

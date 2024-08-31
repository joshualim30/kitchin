// main.dart
// Main entry point of the app

// Imports
import 'package:flutter/material.dart';
import 'package:kitchin/navigation.dart';
import 'package:kitchin/onboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// MARK: Main Function
Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Run the app
  runApp(const MainApp());
}

// MARK: MainApp Class
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // MARK: Get Screen
  Widget _getScreen() {

    // Get the current user
    final user = FirebaseAuth.instance.currentUser;

    // If user is signed in, return Home screen
    if (user != null) {
      return const Navigation();
    }

    // Otherwise, return Onboard screen
    return Onboard();

  }

  // MARK: Build the app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData.from(
        colorScheme: lightColorScheme,
      ),
      darkTheme: ThemeData.from(
        colorScheme: darkColorScheme,
      ),
      home: Scaffold(
        body: Center(
          // If user is signed in, show Home screen
          // Otherwise, show Onboard screen
          child: _getScreen(),
        ),
      ),
    );
  }
}

// MARK: Color Schemes
const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color.fromARGB(255, 0, 128, 0),
  onPrimary: Color.fromARGB(255, 255, 255, 255),
  primaryContainer: Color.fromARGB(255, 230, 230, 230),
  onPrimaryContainer: Color.fromARGB(255, 0, 0, 0),
  secondary: Color.fromARGB(255, 0, 100, 0),
  onSecondary: Color.fromARGB(255, 255, 255, 255),
  secondaryContainer: Color.fromARGB(255, 240, 240, 240),
  onSecondaryContainer: Color.fromARGB(255, 0, 0, 0),
  error: Color.fromARGB(255, 176, 0, 32),
  onError: Color.fromARGB(255, 255, 255, 255),
  surface: Color.fromARGB(255, 255, 255, 255),
  onSurface: Color.fromARGB(255, 0, 0, 0),
  surfaceTint: Color.fromARGB(255, 240, 240, 240),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color.fromARGB(255, 0, 128, 0),
  onPrimary: Color.fromARGB(255, 255, 255, 255),
  primaryContainer: Color.fromARGB(255, 20, 20, 20),
  onPrimaryContainer: Color.fromARGB(255, 255, 255, 255),
  secondary: Color.fromARGB(255, 0, 100, 0),
  onSecondary: Color.fromARGB(255, 255, 255, 255),
  secondaryContainer: Color.fromARGB(255, 40, 40, 40),
  onSecondaryContainer: Color.fromARGB(255, 255, 255, 255),
  error: Color.fromARGB(255, 176, 0, 32),
  onError: Color.fromARGB(255, 255, 255, 255),
  surface: Color.fromARGB(255, 0, 0, 0),
  onSurface: Color.fromARGB(255, 255, 255, 255),
);
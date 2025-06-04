import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Make sure this import matches your project's package name from pubspec.yaml
import 'package:e_library/services/api_service.dart';
import 'package:e_library/screens/auth/login_screen.dart'; // We'll create this next!
import 'package:e_library/screens/home_screen.dart'; // And this one later

// This is the main function where your Flutter app starts execution.
void main() async {
  // Ensures that Flutter's binding to the platform is initialized.
  // This is needed before using SharedPreferences (or any platform channels).
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences early. This is crucial for checking login state.
  await SharedPreferences.getInstance();

  // Run the main application widget.
  runApp(const MyApp());
}

// MyApp is the root widget of your application.
// It sets up the basic material design theme and defines the app's structure.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Library App', // Title of your application
      debugShowCheckedModeBanner: false, // Set to false to remove the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue, // Sets the primary color for the app
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey, // Customize app bar color
          foregroundColor: Colors.white, // Customize app bar text/icon color
        ),
      ),
      home: AuthChecker(), // Our starting point that decides between login or home
    );
  }
}

// This widget checks the user's authentication status and directs them
// to either the LoginScreen or the HomeScreen.
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  late final ApiService _apiService; // Declare as late final

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(); // Initialize ApiService here
    _checkLoginStatus();
  }

  // Checks if a JWT token exists in SharedPreferences
  Future<void> _checkLoginStatus() async {
    final token = _apiService.getToken(); // Use ApiService to get token

    setState(() {
      _isLoggedIn = token != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading spinner while checking login status
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // If logged in, go to HomeScreen; otherwise, go to LoginScreen
      return _isLoggedIn ? const HomeScreen() : const LoginScreen();
    }
  }
}
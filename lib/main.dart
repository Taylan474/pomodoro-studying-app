import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures proper initialization before any Flutter operations
  final prefs =
  await SharedPreferences.getInstance(); // Get SharedPreferences instance

  // Check if the preference for dark mode exists
  final hasSavedTheme = prefs.containsKey('isDarkMode');

  bool isDark;
  if (hasSavedTheme) {
    // If saved theme exists, use it
    isDark = prefs.getBool('isDarkMode') ?? false;
  } else {
    // If no saved theme, auto-detect based on system/browser brightness
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    isDark = brightness == Brightness.dark;
    prefs.setBool(
        'isDarkMode', isDark); // Save the detected theme for future use
  }

  // Run the app with the initial theme (either light or dark)
  runApp(MyApp(initialIsDark: isDark));
}

class MyApp extends StatefulWidget {
  final bool initialIsDark; // The initial theme mode (light/dark)
  const MyApp({Key? key, required this.initialIsDark}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark; // A local variable to store the theme mode

  @override
  void initState() {
    super.initState();
    _isDark =
        widget.initialIsDark; // Set the initial theme based on passed parameter
  }

  // A method to toggle between light and dark mode
  void _toggleTheme() async {
    setState(() => _isDark = !_isDark); // Toggle theme
    final prefs =
    await SharedPreferences.getInstance(); // Get SharedPreferences instance
    prefs.setBool(
        'isDarkMode', _isDark); // Save the current theme mode for future use
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disables the debug banner
      title: 'Pomodoro Study Timer',

      // Light theme settings
      theme: ThemeData(
        useMaterial3: true, // Use Material 3 design system
        textTheme:
        GoogleFonts.poppinsTextTheme(), // Use Poppins font for the text
        colorScheme: ColorScheme.fromSeed(
            seedColor:
            Colors.indigo), // Generate color scheme using indigo as base
      ),

      // Dark theme settings
      darkTheme: ThemeData(
        useMaterial3: true, // Use Material 3 design system
        textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark().textTheme), // Use Poppins font with dark theme
        colorScheme: ColorScheme.fromSeed(
          seedColor:
          Colors.indigo, // Generate color scheme using indigo for dark mode
          brightness: Brightness.dark,
        ),
      ),

      // Select theme based on the saved preference
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,

      // Start screen with a toggle button for theme and the current theme status
      home: HomePage(onToggleTheme: _toggleTheme, isDark: _isDark),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pomodoro/pages/settings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Main HomePage widget with dark mode toggle
class HomePage extends StatefulWidget {
  final void Function() onToggleTheme;
  final bool isDark;

  const HomePage({Key? key, required this.onToggleTheme, required this.isDark}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _secondsStudy = 1500; // Current timer seconds
  late Timer _timer; // Timer instance
  bool _isRunning = false; // Whether the timer is running
  String _bodyText = "Study"; // Display text ("Study" or "Break")
  int _initialStudySeconds = 1500; // Initial study duration
  int _initialBreakSeconds = 300; // Initial break duration
  Color _studyColor = Colors.indigo; // Study session color
  Color _breakColor = Colors.red; // Break session color
  bool _isStudyTime = true; // Whether it is currently study time

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load saved user preferences
  }

  // Load user settings from SharedPreferences
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _initialStudySeconds = (prefs.getInt('studyTime') ?? 25) * 60;
      _initialBreakSeconds = (prefs.getInt('breakTime') ?? 5) * 60;
      _studyColor = _parseColor(prefs.getString('studyColor') ?? "Indigo");
      _breakColor = _parseColor(prefs.getString('breakColor') ?? "Red");
      _secondsStudy = _initialStudySeconds;
    });
  }

  // Start the countdown timer
  void _startTimer() {
    if (_isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsStudy <= 0) {
        _switchTimer(); // Switch between study and break
      } else {
        setState(() => _secondsStudy--);
      }
    });
    setState(() => _isRunning = true);
  }

  // Stop the timer
  void _stopTimer() {
    _timer.cancel();
    setState(() => _isRunning = false);
  }

  // Reset the timer to initial values
  void _resetTimer() {
    if (_isRunning) _timer.cancel();
    setState(() {
      _secondsStudy = _isStudyTime ? _initialStudySeconds : _initialBreakSeconds;
      _isRunning = false;
    });
  }

  // Switch between study and break timers
  void _switchTimer() {
    if (_isRunning) _timer.cancel();
    setState(() {
      _isStudyTime = !_isStudyTime;
      _secondsStudy = _isStudyTime ? _initialStudySeconds : _initialBreakSeconds;
      _bodyText = _isStudyTime ? "Study" : "Break";
      _isRunning = false;
    });
  }

  // Convert color name string to actual Color object
  Color _parseColor(String color) {
    final map = {
      "Blue": Colors.blue,
      "Green": Colors.green,
      "Yellow": Colors.yellow,
      "Purple": Colors.purple,
      "Orange": Colors.orange,
      "Pink": Colors.pink,
      "Cyan": Colors.cyan,
      "Teal": Colors.teal,
      "Indigo": Colors.indigo,
      "Brown": Colors.brown,
      "Red": Colors.red,
    };
    return map[color] ?? Colors.indigo;
  }

  // Format seconds into MM:SS string
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    if (_isRunning) _timer.cancel(); // Cancel timer on widget dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _isStudyTime ? _studyColor : _breakColor;
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 14.0, top: 9.0, bottom: 9.0),
          child: Image.asset(
            'assets/logo.png', // App logo
            height: 30,
            width: 30,
          ),
        ),
        title: Text(
          "Pomodoro Timer",
          style: GoogleFonts.poppins(),
        ),
        centerTitle: true,
        actions: [
          // White and Dark mode button
          IconButton(
            icon: Icon(widget.isDark ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              // Navigate to settings page
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
              // Apply updated settings
              if (result != null) {
                setState(() {
                  _initialStudySeconds = (result['studyTime'] ?? 25) * 60;
                  _initialBreakSeconds = (result['breakTime'] ?? 5) * 60;
                  _studyColor = _parseColor(result['studyColor']);
                  _breakColor = _parseColor(result['breakColor']);
                  _secondsStudy = _isStudyTime ? _initialStudySeconds : _initialBreakSeconds;
                });
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Info text about the pomodoro technique
                Text(
                  "The Pomodoro Technique boosts focus with 25-minute work sessions followed by short breaks.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 1),
                Column(
                  children: [
                    // Circular timer widget
                    _buildTimerCircle(color, isWide),
                    const SizedBox(height: 24),
                    // "Study" or "Break" label
                    Text(
                      _bodyText,
                      style: GoogleFonts.poppins(
                        fontSize: isWide ? 28 : 24,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Timer control buttons
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _isRunning ? _stopTimer : _startTimer,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: EdgeInsets.all(isWide ? 16 : 20),
                          ),
                          child: Icon(
                            _isRunning ? Icons.pause : Icons.play_arrow,
                            size: isWide ? 28 : 32,
                          ),
                        ),
                        _buildControlButton(Icons.replay, _resetTimer, isWide),
                        _buildControlButton(Icons.swap_horiz, _switchTimer, isWide),
                      ],
                    ),
                  ],
                ),
                // Footer quote
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Small steps every day lead to big change 💡",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable button builder
  Widget _buildControlButton(IconData icon, VoidCallback onPressed, bool isWide) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: EdgeInsets.all(isWide ? 16 : 20),
      ),
      child: Icon(icon, size: isWide ? 28 : 32),
    );
  }

  // Circular timer display with progress
  Widget _buildTimerCircle(Color color, bool isWide) {
    double progress = _isStudyTime
        ? _secondsStudy / _initialStudySeconds
        : _secondsStudy / _initialBreakSeconds;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle
        Container(
          width: isWide ? 280 : 260,
          height: isWide ? 280 : 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        // Progress indicator
        SizedBox(
          width: isWide ? 280 : 260,
          height: isWide ? 280 : 260,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        // Remaining time
        Text(
          _formatTime(_secondsStudy),
          style: GoogleFonts.poppins(
            fontSize: isWide ? 48 : 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

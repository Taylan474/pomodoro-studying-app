import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Map for the color options
final Map<String, Color> colorMap = {
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Default values for study and break times, and colors
  double studyTime = 25.0;
  double breakTime = 5.0;
  String selectedStudyColor = 'Indigo';
  String selectedBreakColor = 'Red';

  @override
  void initState() {
    super.initState();
    _loadSavedSettings(); // Load saved settings from SharedPreferences
  }

  // Loads saved settings from SharedPreferences when the page is loaded
  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      studyTime = prefs.getInt('studyTime')?.toDouble() ?? 25.0; // Load study time, default to 25
      breakTime = prefs.getInt('breakTime')?.toDouble() ?? 5.0; // Load break time, default to 5
      selectedStudyColor = prefs.getString('studyColor') ?? 'Indigo'; // Load study color, default to Indigo
      selectedBreakColor = prefs.getString('breakColor') ?? 'Red'; // Load break color, default to Red
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label for study duration slider
            _sectionLabel("Study Duration (${studyTime.toInt()} min)"),
            // Slider to adjust study time between 10 and 60 minutes
            Slider(
              value: studyTime,
              min: 10,
              max: 60,
              divisions: 10,
              label: studyTime.toInt().toString(),
              onChanged: (val) => setState(() => studyTime = val),
            ),
            // Label for break duration slider
            _sectionLabel("Break Duration (${breakTime.toInt()} min)"),
            // Slider to adjust break time between 1 and 30 minutes
            Slider(
              value: breakTime,
              min: 1,
              max: 30,
              divisions: 10,
              label: breakTime.toInt().toString(),
              onChanged: (val) => setState(() => breakTime = val),
            ),
            const SizedBox(height: 24),
            // Label for study color selector
            _sectionLabel("Study Color"),
            // Color display button for study color
            _colorDisplayButton(selectedStudyColor, () => _selectColor(true)),
            const SizedBox(height: 16),
            // Label for break color selector
            _sectionLabel("Break Color"),
            // Color display button for break color
            _colorDisplayButton(selectedBreakColor, () => _selectColor(false)),
            const Spacer(),
            // Save button to save all settings
            Center(
              child: FilledButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text("Save Settings"),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Creates a section label with bold text
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
  );

  // Creates a display button that shows the selected color
  Widget _colorDisplayButton(String label, VoidCallback onTap) {
    return ListTile(
      onTap: onTap, // When tapped, it opens the color selection
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: colorMap[label]?.withOpacity(0.1),
      leading: CircleAvatar(backgroundColor: colorMap[label]),
      title: Text(label),
      trailing: const Icon(Icons.palette_outlined),
    );
  }

  // Opens a bottom sheet to select a color for either study or break
  void _selectColor(bool isStudy) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          runSpacing: 12,
          spacing: 12,
          children: colorMap.entries.map((entry) {
            return GestureDetector(
              onTap: () => Navigator.pop(context, entry.key), // Return the selected color
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isStudy ? selectedStudyColor : selectedBreakColor) == entry.key
                        ? Colors.white
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    // If a color is selected, update the state
    if (result != null) {
      setState(() {
        if (isStudy) {
          selectedStudyColor = result; // Update study color
        } else {
          selectedBreakColor = result; // Update break color
        }
      });
    }
  }

  // Saves all the settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('studyTime', studyTime.toInt()); // Save study time
    await prefs.setInt('breakTime', breakTime.toInt()); // Save break time
    await prefs.setString('studyColor', selectedStudyColor); // Save selected study color
    await prefs.setString('breakColor', selectedBreakColor); // Save selected break color

    Navigator.pop(context, {
      'studyTime': studyTime.toInt(),
      'breakTime': breakTime.toInt(),
      'studyColor': selectedStudyColor,
      'breakColor': selectedBreakColor,
    });
  }
}

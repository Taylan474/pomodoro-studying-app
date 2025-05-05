import 'package:flutter/material.dart';

// A reusable slider widget used for picking time values (like study/break duration)
class TimerSlider extends StatelessWidget {
  final String label; // The label that describes what the slider controls (e.g., "Study Time")
  final double value; // The current value of the slider (e.g., 25.0 for study time)
  final ValueChanged<double> onChanged; // Callback function to update the value when the user changes the slider
  final int min; // Minimum value allowed for the slider
  final int max; // Maximum value allowed for the slider

  const TimerSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1, // Default minimum value is 1
    this.max = 60, // Default maximum value is 60
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
      children: [
        // Displays the label and the current selected value (e.g., "Study Time: 25 minutes")
        Text(
          "$label: ${value.toInt()} minutes",
          style: const TextStyle(fontSize: 16), // Styling the text
        ),
        // The actual slider widget
        Slider(
          value: value, // The current value of the slider
          min: min.toDouble(), // Minimum value for the slider (converted to double)
          max: max.toDouble(), // Maximum value for the slider (converted to double)
          divisions: max - min, // Defines how many divisions there are between the minimum and maximum
          label: value.toInt().toString(), // Displays the label on the slider thumb
          onChanged: onChanged, // Updates the value when the user drags the slider
        ),
      ],
    );
  }
}

// A custom dropdown widget that shows color names with colored backgrounds
class ColorDropdown extends StatelessWidget {
  final String label; // The label for the dropdown (e.g., "Study Color")
  final String selectedColor; // The currently selected color's name
  final ValueChanged<String?> onChanged; // Callback function when a new color is selected
  final Map<String, Color> colors; // A map of available color names and their respective color values

  const ColorDropdown({
    super.key,
    required this.label,
    required this.selectedColor,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedColor, // The currently selected color
      decoration: InputDecoration(
        labelText: label, // The label displayed above the dropdown
        border: OutlineInputBorder(), // Adds a border to the dropdown field
      ),
      items: colors.entries.map((entry) {
        return DropdownMenuItem(
          value: entry.key, // The color name
          child: SizedBox(
            width: 150, // Defines the width of each item in the dropdown
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Padding for text inside the dropdown item
              decoration: BoxDecoration(
                color: entry.value, // Background color is the actual color
                borderRadius: BorderRadius.circular(8), // Rounded corners for the item
              ),
              child: Text(
                entry.key, // The color name text
                style: TextStyle(
                  // Adjusts text color based on the luminance of the background color
                  color: entry.value.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged, // Executes the callback when a new color is selected
    );
  }
}

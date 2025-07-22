import 'package:flutter/material.dart';

class DriveModeButtons extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onModeSelected;

  const DriveModeButtons({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> modes = ['Track', 'Sport', 'Custom', 'Default'];

    return Container(
      color: Colors.red[900],
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: modes.map((mode) {
          final isSelected = selectedMode == mode;
          return GestureDetector(
            onTap: () => onModeSelected(mode),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.red[900],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.white,
                  width: 2,
                ),
              ),
              child: Text(
                mode,
                style: TextStyle(
                  color: isSelected ? Colors.red[900] : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

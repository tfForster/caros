import 'package:flutter/material.dart';
import '/config/app.dart';

class DriveModeButtons extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onModeSelected;

  const DriveModeButtons({super.key, required this.selectedMode, required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    const modes = ['Komfort', 'Sport', 'Sport+', 'Custom'];

    return Container(
      color: App.bg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: modes.map((mode) {
          final isSelected = selectedMode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onModeSelected(mode),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? App.accent.withValues(alpha: 0.12) : App.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? App.accent : App.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    mode.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? App.accent : Colors.white54,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

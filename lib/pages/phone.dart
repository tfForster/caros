import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';
import '/ui/togglebutton.dart'; // Import your ToggleButton widget

class PhonePage extends StatelessWidget {
  const PhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone'),
        backgroundColor: Colors.red[900], // Matches the design
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Controls Page Content',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          ToggleButton(
            label: 'Toggle Me',
            onToggle: (isOn) {
              // Handle toggle state here
              print('Toggle is now: $isOn');
            },
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'Phone'),
    );
  }
}

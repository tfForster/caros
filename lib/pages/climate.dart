import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';

class ClimatePage extends StatefulWidget {
  const ClimatePage({super.key});

  @override
  State<ClimatePage> createState() => _ClimatePageState();
}

class _ClimatePageState extends State<ClimatePage> {
  int _selectedIndex = 0; // Tracks the active button
  int _selectedBarButtonIndex = 0; // Tracks the active button in the bar
  bool _leftToggle = false; // Tracks the state of the left toggle
  bool _rightToggle = false; // Tracks the state of the right toggle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Climate'),
        backgroundColor: Colors.red[900], // Matches the design
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(0, Icons.ac_unit, Colors.blue),
              const SizedBox(width: 20),
              _buildIconButton(1, Icons.wb_sunny, Colors.orange),
              const SizedBox(width: 20),
              _buildIconButton(2, Icons.cloud, Colors.grey),
              const SizedBox(width: 20),
              _buildIconButton(3, Icons.thermostat, Colors.red),
            ],
          ),
          const SizedBox(height: 30), // Spacing between the rows
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left Toggle Button
              _buildToggleButton(
                isActive: _leftToggle,
                onToggle: (value) {
                  setState(() {
                    _leftToggle = value;
                  });
                },
                label: 'Left',
              ),
              const SizedBox(width: 20), // Space between toggle and bar
              // Button Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 59, 59, 59),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildBar(),
              ),
              const SizedBox(width: 20), // Space between bar and toggle
              // Right Toggle Button
              _buildToggleButton(
                isActive: _rightToggle,
                onToggle: (value) {
                  setState(() {
                    _rightToggle = value;
                  });
                },
                label: 'Right',
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'Climate'),
    );
  }

  Widget _buildIconButton(int index, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index; // Set the active button
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _selectedIndex == index ? color.withOpacity(0.2) : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 40,
          color: _selectedIndex == index ? color : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedBarButtonIndex = index; // Set the active button
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: _selectedBarButtonIndex == index
                  ? const Color.fromARGB(255, 120, 120, 120)
                  : const Color.fromARGB(255, 59, 59, 59),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'B${index + 1}', // Button labels: B1, B2, ...
              style: TextStyle(
                color: _selectedBarButtonIndex == index
                    ? Colors.red
                    : const Color.fromARGB(255, 209, 209, 209),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildToggleButton({
    required bool isActive,
    required void Function(bool) onToggle,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        onToggle(!isActive); // Toggle the state
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isActive ? Colors.red[900] : const Color.fromARGB(255, 59, 59, 59),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color.fromARGB(255, 209, 209, 209),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';
import '/ui/togglebutton.dart';

class ControlsPage extends StatelessWidget {
  const ControlsPage({super.key});

  void _onToggleChanged(bool value) {
    debugPrint('Toggle button is now: ${value ? "ON" : "OFF"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Controls'),
        backgroundColor: Colors.red[900],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Left container
            _buildCard([
              const Text(
                'Driver',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 20),
              ToggleButton(
                label: 'Vented Seat',
                onToggle: (isOn) {
                  print('Toggle is now: $isOn');
                },
              ),
              const SizedBox(height: 40),
              ToggleButton(
                label: 'Heated Seat',
                onToggle: (isOn) {
                  print('Toggle is now: $isOn');
                },
              ),
              const SizedBox(height: 40),
              ToggleButton(
                label: 'Heated Wheel',
                onToggle: (isOn) {
                  print('Toggle is now: $isOn');
                },
              ),
            ]),

            // Middle container
            _buildCard([
              const SizedBox(height: 40),
              ToggleButton(
                label: 'Mirror Dimmer',
                onToggle: (isOn) {
                  print('Toggle is now: $isOn');
                },
              ),
              const SizedBox(height: 100),
              _buildButton('Settings'),
              const SizedBox(height: 40),
            ]),

            // Right container
            _buildCard([
              const Text(
                'Passenger',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 20),
              ToggleButton(
                label: 'Heated Seat',
                onToggle: (isOn) {
                  print('Toggle is now: $isOn');
                },
              ),
              const SizedBox(height: 80),
              ToggleButton(
                label: 'Vented Seat',
                onToggle: (isOn) {
                  print('Toggle is now: $isOn');
                },
              ),
            ]),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'Controls'),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 400, // Set the minimum height for the container
        maxWidth: 250,  // Optional: Set a max width for uniformity
      ),
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return ElevatedButton(
      onPressed: () {
        print('$text pressed');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        minimumSize: const Size(200, 60), // Button size
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Add border radius here
        ),
      ),
      child: Text(text),
    );
  }
}

import 'package:flutter/material.dart';
import '/config/app.dart';
import '/widgets/drive_mode_buttons.dart';
import '/widgets/main_content.dart';
import '/widgets/bottom_navigation.dart';


class SrtPage extends StatefulWidget {
  const SrtPage({super.key});

  @override
  State<SrtPage> createState() => _SrtPageState();
}

class _SrtPageState extends State<SrtPage> {
  String selectedMode = 'Track'; // Default selected mode

  final Map<String, Map<String, String>> driveModeSettings = {
    'Track': {
      'Horsepower': '700+',
      'Transmission': 'Track',
      'Paddle Shift': 'On',
      'Traction': 'Track',
      'Suspension': 'Track',
    },
    'Sport': {
      'Horsepower': '700+',
      'Transmission': 'Sport',
      'Paddle Shift': 'On',
      'Traction': 'Sport',
      'Suspension': 'Sport',
    },
    'Custom': {
      'Horsepower': 'Varies',
      'Transmission': 'Custom',
      'Paddle Shift': 'On/Off',
      'Traction': 'Custom',
      'Suspension': 'Custom',
    },
    'Default': {
      'Horsepower': '700+',
      'Transmission': 'Street',
      'Paddle Shift': 'On',
      'Traction': 'Street',
      'Suspension': 'Street',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(App.title),
        centerTitle: true,
        backgroundColor: Colors.red[900],
      ),
      body: Column(
        children: [
          DriveModeButtons(
            selectedMode: selectedMode,
            onModeSelected: (mode) {
              setState(() {
                selectedMode = mode;
              });
            },
          ),
          Expanded(
            child: MainContent(settings: driveModeSettings[selectedMode]!),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'SRT Page'),

    );
  }
}

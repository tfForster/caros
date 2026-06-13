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
  String selectedMode = 'Komfort';

  final Map<String, Map<String, String>> driveModeSettings = {
    'Komfort': {
      'Fahrwerk':         'Komfort',
      'Lenkung':          'Leicht',
      'Traktion':         'Standard',
      'Getriebe':         'Automatik',
      'Gasannahme':       'Sanft',
    },
    'Sport': {
      'Fahrwerk':         'Straff',
      'Lenkung':          'Direkt',
      'Traktion':         'Sport',
      'Getriebe':         'Manuell',
      'Gasannahme':       'Sportlich',
    },
    'Sport+': {
      'Fahrwerk':         'Sehr straff',
      'Lenkung':          'Sehr direkt',
      'Traktion':         'Aus',
      'Getriebe':         'Manuell',
      'Gasannahme':       'Direkt',
    },
    'Custom': {
      'Fahrwerk':         'Individuell',
      'Lenkung':          'Individuell',
      'Traktion':         'Individuell',
      'Getriebe':         'Individuell',
      'Gasannahme':       'Individuell',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: App.bg,
      appBar: AppBar(
        backgroundColor: App.bg,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Fahrmodus', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
            Text('5:00', style: TextStyle(color: Colors.white54, fontSize: 15)),
          ],
        ),
      ),
      body: Column(
        children: [
          DriveModeButtons(
            selectedMode: selectedMode,
            onModeSelected: (mode) => setState(() => selectedMode = mode),
          ),
          Expanded(
            child: MainContent(settings: driveModeSettings[selectedMode]!),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'Fahrmodus'),
    );
  }
}

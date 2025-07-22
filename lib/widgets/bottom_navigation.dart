import 'package:flutter/material.dart';
import 'package:test_app/pages/phone.dart';
import '../pages/apps.dart';
import '../pages/srtpage.dart';
import '/pages/media.dart';
import '/pages/controls.dart';
import '/pages/climate.dart';
import '/pages/settings.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final String currentPage;

  const BottomNavigationBarWidget({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.red[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomButton(context, Icons.music_note, 'Media', const MediaPage()),
          _buildBottomButton(context, Icons.thermostat, 'Climate', const ClimatePage()),
          _buildBottomButton(context, Icons.tune, 'Controls', const ControlsPage()),
          _buildBottomButton(context, Icons.apps, 'Apps', const AppsPage()),
          _buildBottomButton(context, Icons.radio, 'SRT Page', const SrtPage()),
          _buildBottomButton(context, Icons.phone, 'Phone', const PhonePage()),
          _buildBottomButton(context, Icons.settings, 'Settings', const SettingsPage()),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, IconData icon, String label, Widget targetPage) {
    final isSelected = label == currentPage;

    return IconButton(
      onPressed: () {
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        }
      },
      icon: Icon(
        icon,
        size: 30,
        color: isSelected ? Colors.white : Colors.grey[400],
      ),
      tooltip: label,
    );
  }
}

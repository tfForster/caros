import 'package:flutter/material.dart';
import '../pages/apps.dart';
import '/pages/media.dart';
import '/pages/nav.dart';
import '/pages/phone.dart';
import '/pages/settings.dart';
import '/config/app.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final String currentPage;

  const BottomNavigationBarWidget({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    const items = [
      {'icon': Icons.apps,       'label': 'Apps'},
      {'icon': Icons.music_note, 'label': 'Media'},
      {'icon': Icons.phone,      'label': 'Phone'},
      {'icon': Icons.map,        'label': 'Nav'},
      {'icon': Icons.settings,   'label': 'Settings'},
    ];

    final pages = {
      'Apps':     const AppsPage(),
      'Media':    const MediaPage(),
      'Phone':    const PhonePage(),
      'Nav':      const NavPage(),
      'Settings': const SettingsPage(),
    };

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        border: Border(top: BorderSide(color: Color(0xFF1E1E1E))),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              final label = item['label'] as String;
              final icon  = item['icon']  as IconData;
              final isSelected = label == currentPage;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (!isSelected && pages.containsKey(label)) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => pages[label]!),
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 22, color: isSelected ? App.accent : Colors.white38),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? App.accent : Colors.white38,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

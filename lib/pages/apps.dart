import 'package:flutter/material.dart';
import '/config/app.dart';
import '/widgets/bottom_navigation.dart';
import 'media.dart';
import 'nav.dart';
import 'phone.dart';
import 'settings.dart';

class AppsPage extends StatelessWidget {
  const AppsPage({super.key});

  static const _apps = [
    {'icon': Icons.music_note,     'label': 'Media',       'route': 'Media'},
    {'icon': Icons.phone,          'label': 'Phone',       'route': 'Phone'},
    {'icon': Icons.map,            'label': 'Navigation',  'route': 'Nav'},
    {'icon': Icons.settings,       'label': 'Settings',    'route': 'Settings'},
    {'icon': Icons.directions_car, 'label': 'Travel Link', 'route': null},
    {'icon': Icons.insights,       'label': 'Performance', 'route': null},
    {'icon': Icons.notifications,  'label': 'Alerts',      'route': null},
    {'icon': Icons.camera_alt,     'label': 'Kamera',      'route': null},
    {'icon': Icons.wb_sunny,       'label': 'Wetter',      'route': null},
    {'icon': Icons.local_gas_station, 'label': 'Tankstellen', 'route': null},
    {'icon': Icons.restaurant,     'label': 'POI',         'route': null},
    {'icon': Icons.battery_charging_full, 'label': 'Fahrzeug', 'route': null},
  ];

  static final _pages = <String, Widget>{
    'Media':    const MediaPage(),
    'Phone':    const PhonePage(),
    'Nav':      const NavPage(),
    'Settings': const SettingsPage(),
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
            Text('Apps', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
            Text('5:00', style: TextStyle(color: Colors.white54, fontSize: 15)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _apps.length,
          itemBuilder: (context, index) => _buildAppTile(context, _apps[index]),
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'Apps'),
    );
  }

  Widget _buildAppTile(BuildContext context, Map<String, dynamic> app) {
    final hasPage = app['route'] != null;

    return GestureDetector(
      onTap: () {
        final route = app['route'] as String?;
        if (route != null && _pages.containsKey(route)) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => _pages[route]!));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${app['label']} — demnächst verfügbar'),
              backgroundColor: App.surface,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: App.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: App.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(app['icon'] as IconData, size: 28, color: hasPage ? App.accent : Colors.white38),
            const SizedBox(height: 8),
            Text(
              app['label'] as String,
              style: TextStyle(
                color: hasPage ? Colors.white : Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

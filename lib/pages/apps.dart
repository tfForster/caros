import 'package:flutter/material.dart';
import 'package:test_app/pages/climate.dart';
import 'package:test_app/pages/controls.dart';
import 'package:test_app/pages/nav.dart';
import 'package:test_app/pages/phone.dart';
import 'package:test_app/pages/settings.dart';
import '/widgets/bottom_navigation.dart';
import 'srtpage.dart'; // Example page import
import '/pages/media.dart'; // Another example page

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  _AppsPageState createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  // Define app-specific pages
  final Map<String, Widget> appPages = {
    'SRT page': SrtPage(), // Replace with your page widget
    'Media': MediaPage(),         // Replace with your page widget
    'Climate': ClimatePage(),     // Replace with actual pages
    'Controls': ControlsPage(),
    'Nav': NavPage(),
    'Phone': PhonePage(),
    'Settings': SettingsPage(),
    // Add additional apps here
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps'),
        backgroundColor: Colors.red[900],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildAppGrid(context, 1), // First page of apps
                _buildAppGrid(context, 2), // Second page of apps
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: _currentPage > 0 ? Colors.white : Colors.grey,
                ),
                onPressed: _currentPage > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
              Text(
                'Page ${_currentPage + 1} of 2',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward,
                  color: _currentPage < 1 ? Colors.white : Colors.grey,
                ),
                onPressed: _currentPage < 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'Apps'),
    );
  }

  Widget _buildAppGrid(BuildContext context, int page) {
    final List<List<Map<String, dynamic>>> pages = [
      [
        {'icon': Icons.directions_car, 'label': 'Travel Link'},
        {'icon': Icons.speed, 'label': 'SRT Mode'},
        {'icon': Icons.dashboard, 'label': 'Dashboard'},
        {'icon': Icons.music_note, 'label': 'Media'},
        {'icon': Icons.thermostat, 'label': 'Climate'},
        {'icon': Icons.control_camera, 'label': 'Controls'},
        {'icon': Icons.navigation, 'label': 'Nav'},
        {'icon': Icons.phone, 'label': 'Phone'},
        {'icon': Icons.settings, 'label': 'Settings'},
      ],
      [
        {'icon': Icons.notifications, 'label': 'Notifications'},
        {'icon': Icons.insights, 'label': 'Performance Pages'},
        {'icon': Icons.apps, 'label': 'App Manager'},
        {'icon': Icons.wheelchair_pickup, 'label': 'Heated Wheel'},
        {'icon': Icons.auto_awesome, 'label': 'Mirror Dimmer'},
        {'icon': Icons.music_note, 'label': 'Media'},
        {'icon': Icons.thermostat, 'label': 'Climate'},
        {'icon': Icons.control_camera, 'label': 'Controls'},
        {'icon': Icons.navigation, 'label': 'Nav'},
        {'icon': Icons.phone, 'label': 'Phone'},
        {'icon': Icons.settings, 'label': 'Settings'},
        {'icon': Icons.volume_up, 'label': 'Audio Settings'},
      ],
    ];

    final apps = pages[page - 1];

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 5,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return GestureDetector(
          onTap: () {
            if (appPages.containsKey(app['label'])) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => appPages[app['label']]!),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${app['label']} page is not available yet!'),
                ),
              );
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[800],
                child: Icon(
                  app['icon'],
                  size: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                app['label'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

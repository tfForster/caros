import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  // Current selected content for the main display
  String currentContent = 'FM Radio';
  String currentSubtitle = '88.9 MHz';
  IconData currentIcon = Icons.radio;

  // Function to update content based on sidebar button pressed
  void updateContent(String content, String subtitle, IconData icon) {
    setState(() {
      currentContent = content;
      currentSubtitle = subtitle;
      currentIcon = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('5:00', style: TextStyle(color: Colors.white, fontSize: 18)),
            Text('77° out.', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      body: Row(
        children: [
          // Left Sidebar
          Container(
            color: Colors.black,
            width: 100, // Sidebar width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSidebarButton(
                  Icons.waves,
                  'AM',
                  '540 kHz - 1600 kHz',
                  Icons.waves,
                  currentContent == 'AM',
                ),
                const SizedBox(height: 20),
                _buildSidebarButton(
                  Icons.radio,
                  'FM',
                  '88.9 MHz - 107.9 MHz',
                  Icons.radio,
                  currentContent == 'FM',
                ),
                const SizedBox(height: 20),
                _buildSidebarButton(
                  Icons.album,
                  'Radio',
                  'Streaming Channels',
                  Icons.album,
                  currentContent == 'Radio',
                ),
                const SizedBox(height: 20),
                _buildSidebarButton(
                  Icons.input,
                  'Source Select',
                  'Select Audio Source',
                  Icons.input,
                  currentContent == 'Source Select',
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    currentIcon,
                    size: 100,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentContent,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currentSubtitle,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar:
          const BottomNavigationBarWidget(currentPage: 'Media'),
    );
  }

  Widget _buildSidebarButton(IconData icon, String label, String subtitle,
      IconData displayIcon, bool isSelected) {
    return GestureDetector(
      onTap: () => updateContent(label, subtitle, displayIcon),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: isSelected ? Colors.orange : Colors.white,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';

class NavPage extends StatelessWidget {
  const NavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nav'),
        backgroundColor: Colors.red[900], // Matches the design
      ),
      body: const Center(
        child: Text(
          'Nav Page Content',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'settings'),
    );
  }
}

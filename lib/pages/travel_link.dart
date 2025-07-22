import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';

class Travel_linkPage extends StatelessWidget {
  const Travel_linkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel_link'),
        backgroundColor: Colors.red[900], // Matches the design
      ),
      body: const Center(
        child: Text(
          'Travel Link Page Content',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'settings'),
    );
  }
}

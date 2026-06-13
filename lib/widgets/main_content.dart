import 'package:flutter/material.dart';
import '/config/app.dart';

class MainContent extends StatelessWidget {
  final Map<String, String> settings;

  const MainContent({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: settings.entries.map((e) => _buildStatCard(e.key, e.value)).toList(),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: App.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: App.border),
              ),
              child: const Center(
                child: Icon(Icons.directions_car, size: 100, color: Color(0xFF2A2A2A)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: App.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: App.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

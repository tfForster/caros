import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';

class ClimatePage extends StatefulWidget {
  const ClimatePage({super.key});

  @override
  State<ClimatePage> createState() => _ClimatePageState();
}

class _ClimatePageState extends State<ClimatePage> {
  double _driverTemp = 22.0;
  double _passengerTemp = 21.0;
  int _fanSpeed = 2;
  String _mode = 'Auto';
  bool _rearDefrost = false;
  bool _sync = false;

  final List<Map<String, dynamic>> _modes = [
    {'label': 'Auto', 'icon': Icons.auto_mode},
    {'label': 'AC', 'icon': Icons.ac_unit},
    {'label': 'Heat', 'icon': Icons.whatshot},
    {'label': 'Defrost', 'icon': Icons.blur_on},
  ];

  void _changeDriverTemp(double delta) {
    setState(() {
      _driverTemp = (_driverTemp + delta).clamp(16.0, 30.0);
      if (_sync) _passengerTemp = _driverTemp;
    });
  }

  void _changePassengerTemp(double delta) {
    setState(() {
      _passengerTemp = (_passengerTemp + delta).clamp(16.0, 30.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Climate', style: TextStyle(color: Colors.white, fontSize: 18)),
            Text('5:00', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            _buildTempCard('Fahrer', _driverTemp, _changeDriverTemp),
            const SizedBox(width: 24),
            Expanded(child: _buildCenter()),
            const SizedBox(width: 24),
            _buildTempCard('Beifahrer', _passengerTemp, _changePassengerTemp),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'Climate'),
    );
  }

  Widget _buildTempCard(String label, double temp, void Function(double) onChange) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => onChange(0.5),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${temp.toStringAsFixed(1)}°',
            style: TextStyle(color: Colors.red[900], fontSize: 38, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => onChange(-0.5),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: const Icon(Icons.remove, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeRow(),
        const SizedBox(height: 24),
        _buildFanSpeed(),
        const SizedBox(height: 24),
        _buildToggles(),
      ],
    );
  }

  Widget _buildModeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _modes.map((m) {
        final isSelected = m['label'] == _mode;
        return GestureDetector(
          onTap: () => setState(() => _mode = m['label']),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.red[900] : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.red[900]! : const Color(0xFF2A2A2A),
              ),
            ),
            child: Column(
              children: [
                Icon(m['icon'] as IconData, color: Colors.white, size: 22),
                const SizedBox(height: 4),
                Text(m['label'], style: const TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFanSpeed() {
    return Column(
      children: [
        const Text('Lüfter', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.air, color: Colors.white38, size: 18),
            const SizedBox(width: 8),
            ...List.generate(5, (i) {
              final level = i + 1;
              final isActive = level <= _fanSpeed;
              return GestureDetector(
                onTap: () => setState(() => _fanSpeed = level),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.red[900] : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isActive ? Colors.red[900]! : const Color(0xFF2A2A2A)),
                  ),
                  child: Center(
                    child: Text('$level', style: TextStyle(color: isActive ? Colors.white : Colors.white38, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            }),
            const SizedBox(width: 8),
            const Icon(Icons.air, color: Colors.white70, size: 26),
          ],
        ),
      ],
    );
  }

  Widget _buildToggles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggle('Heckscheibe', Icons.blur_on, _rearDefrost, () => setState(() => _rearDefrost = !_rearDefrost)),
        const SizedBox(width: 16),
        _buildToggle('Sync', Icons.sync, _sync, () => setState(() {
          _sync = !_sync;
          if (_sync) _passengerTemp = _driverTemp;
        })),
      ],
    );
  }

  Widget _buildToggle(String label, IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.red[900] : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? Colors.red[900]! : const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

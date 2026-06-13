import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';

class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  int _driverHeat = 0;
  int _driverVent = 0;
  int _passengerHeat = 0;
  int _passengerVent = 0;
  bool _wheelHeat = false;
  bool _mirrorDimmer = false;

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
            Text('Controls', style: TextStyle(color: Colors.white, fontSize: 18)),
            Text('5:00', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildSeatCard('Fahrer', _driverHeat, _driverVent,
              onHeat: (v) => setState(() => _driverHeat = v),
              onVent: (v) => setState(() => _driverVent = v),
            )),
            const SizedBox(width: 20),
            SizedBox(width: 180, child: _buildCenterCard()),
            const SizedBox(width: 20),
            Expanded(child: _buildSeatCard('Beifahrer', _passengerHeat, _passengerVent,
              onHeat: (v) => setState(() => _passengerHeat = v),
              onVent: (v) => setState(() => _passengerVent = v),
            )),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'Controls'),
    );
  }

  Widget _buildSeatCard(String label, int heat, int vent, {
    required void Function(int) onHeat,
    required void Function(int) onVent,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          _buildLevelControl(Icons.local_fire_department, 'Sitzheizung', heat, onHeat),
          const SizedBox(height: 20),
          _buildLevelControl(Icons.air, 'Sitzbelüftung', vent, onVent),
        ],
      ),
    );
  }

  Widget _buildLevelControl(IconData icon, String label, int level, void Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white54, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (i) {
            final isActive = i < level;
            return GestureDetector(
              onTap: () => onChanged(i == 0 && level == 1 ? 0 : i + 1 > level ? i + 1 : i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: i == 0
                      ? (level == 0 ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A))
                      : (isActive ? Colors.red[900] : const Color(0xFF1A1A1A)),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: i == 0 && level == 0
                        ? Colors.white38
                        : isActive ? Colors.red[900]! : const Color(0xFF2A2A2A),
                  ),
                ),
                child: Text(
                  i == 0 ? 'Off' : '$i',
                  style: TextStyle(
                    color: i == 0 && level == 0 ? Colors.white : isActive ? Colors.white : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCenterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToggleTile(Icons.trip_origin, 'Lenkradheizung', _wheelHeat,
            () => setState(() => _wheelHeat = !_wheelHeat)),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF2A2A2A)),
          const SizedBox(height: 20),
          _buildToggleTile(Icons.remove_red_eye, 'Spiegeldimmer', _mirrorDimmer,
            () => setState(() => _mirrorDimmer = !_mirrorDimmer)),
        ],
      ),
    );
  }

  Widget _buildToggleTile(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.red[900]!.withValues(alpha: 0.15) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? Colors.red[900]! : const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.red[900] : Colors.white54, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? Colors.red[900] : const Color(0xFF2A2A2A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

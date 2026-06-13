import 'package:flutter/material.dart';
import '/widgets/bottom_navigation.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedCategory = 'Display';

  double _brightness = 0.7;
  double _volume = 0.5;
  double _bass = 0.5;
  double _treble = 0.6;
  bool _bluetooth = true;
  bool _autoConnect = true;
  bool _wifi = false;
  bool _pushNotifications = true;
  bool _autoUpdate = false;
  final String _language = 'Deutsch';
  final String _units = 'Metric';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Display', 'icon': Icons.brightness_6},
    {'label': 'Sound', 'icon': Icons.volume_up},
    {'label': 'Bluetooth', 'icon': Icons.bluetooth},
    {'label': 'Verbindung', 'icon': Icons.wifi},
    {'label': 'System', 'icon': Icons.settings},
  ];

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
            Text('Einstellungen', style: TextStyle(color: Colors.white, fontSize: 18)),
            Text('5:00', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
      body: Row(
        children: [
          _buildSidebar(),
          const VerticalDivider(color: Color(0xFF2A2A2A), width: 1),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentPage: 'Settings'),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 120,
      color: const Color(0xFF0D0D0D),
      child: Column(
        children: _categories.map((cat) {
          final isSelected = cat['label'] == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['label']),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red[900]!.withValues(alpha: 0.15) : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected ? Colors.red[900]! : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Icon(cat['icon'] as IconData, color: isSelected ? Colors.red[900] : Colors.white54, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    cat['label'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedCategory) {
      case 'Display': return _buildDisplay();
      case 'Sound': return _buildSound();
      case 'Bluetooth': return _buildBluetooth();
      case 'Verbindung': return _buildVerbindung();
      case 'System': return _buildSystem();
      default: return const SizedBox();
    }
  }

  Widget _buildDisplay() {
    return _buildSection([
      _buildSectionHeader('Helligkeit'),
      _buildSliderRow(Icons.brightness_low, Icons.brightness_high, _brightness, (v) => setState(() => _brightness = v)),
      const Divider(color: Color(0xFF2A2A2A)),
      _buildSectionHeader('Darstellung'),
      _buildOptionRow('Farbschema', 'Dunkel'),
      _buildOptionRow('Schriftgröße', 'Mittel'),
      _buildOptionRow('Animationen', 'An'),
    ]);
  }

  Widget _buildSound() {
    return _buildSection([
      _buildSectionHeader('Lautstärke'),
      _buildSliderRow(Icons.volume_mute, Icons.volume_up, _volume, (v) => setState(() => _volume = v)),
      const Divider(color: Color(0xFF2A2A2A)),
      _buildSectionHeader('Equalizer'),
      _buildLabeledSlider('Bass', _bass, (v) => setState(() => _bass = v)),
      _buildLabeledSlider('Treble', _treble, (v) => setState(() => _treble = v)),
      const Divider(color: Color(0xFF2A2A2A)),
      _buildOptionRow('Sound-Profil', 'Sport'),
      _buildOptionRow('Surround', 'Aus'),
    ]);
  }

  Widget _buildBluetooth() {
    return _buildSection([
      _buildSectionHeader('Bluetooth'),
      _buildToggleRow('Bluetooth', _bluetooth, (v) => setState(() => _bluetooth = v)),
      _buildToggleRow('Auto-Verbinden', _autoConnect, (v) => setState(() => _autoConnect = v)),
      const Divider(color: Color(0xFF2A2A2A)),
      _buildSectionHeader('Verbundene Geräte'),
      if (_bluetooth)
        _buildDeviceRow('iPhone', 'Verbunden', Icons.phone_iphone, true)
      else
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text('Bluetooth deaktiviert', style: TextStyle(color: Colors.white38, fontSize: 13)),
        ),
    ]);
  }

  Widget _buildVerbindung() {
    return _buildSection([
      _buildSectionHeader('WLAN'),
      _buildToggleRow('WLAN', _wifi, (v) => setState(() => _wifi = v)),
      if (_wifi) _buildOptionRow('Netzwerk', 'HomeNetwork_5G'),
      const Divider(color: Color(0xFF2A2A2A)),
      _buildSectionHeader('Benachrichtigungen'),
      _buildToggleRow('Push-Nachrichten', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
    ]);
  }

  Widget _buildSystem() {
    return _buildSection([
      _buildSectionHeader('Sprache & Region'),
      _buildOptionRow('Sprache', _language),
      _buildOptionRow('Einheiten', _units),
      const Divider(color: Color(0xFF2A2A2A)),
      _buildSectionHeader('Software'),
      _buildToggleRow('Auto-Update', _autoUpdate, (v) => setState(() => _autoUpdate = v)),
      _buildOptionRow('Version', 'UConnect 5.0.3'),
      _buildOptionRow('Fahrzeug-VIN', '2C3CDZFJ4MH123456'),
      const Divider(color: Color(0xFF2A2A2A)),
      _buildSectionHeader('Datenschutz'),
      _buildOptionRow('Diagnosedaten', 'Anonym'),
      _buildActionRow('Werkseinstellungen', Icons.restart_alt, Colors.red[900]!),
    ]);
  }

  Widget _buildSection(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1)),
    );
  }

  Widget _buildSliderRow(IconData iconMin, IconData iconMax, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(iconMin, color: Colors.white38, size: 18),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.red[900],
                inactiveTrackColor: const Color(0xFF2A2A2A),
                thumbColor: Colors.white,
                overlayColor: Colors.red[900]!.withValues(alpha: 0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
          Icon(iconMax, color: Colors.white54, size: 18),
        ],
      ),
    );
  }

  Widget _buildLabeledSlider(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13))),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.red[900],
                inactiveTrackColor: const Color(0xFF2A2A2A),
                thumbColor: Colors.white,
                overlayColor: Colors.red[900]!.withValues(alpha: 0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.red[900],
            inactiveTrackColor: const Color(0xFF2A2A2A),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDeviceRow(String name, String status, IconData icon, bool connected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: connected ? Colors.blue[300] : Colors.white38, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text(status, style: TextStyle(color: connected ? Colors.blue[300] : Colors.white38, fontSize: 11)),
            ],
          ),
          const Spacer(),
          if (connected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[900]!.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[900]!, width: 1),
              ),
              child: Text('Trennen', style: TextStyle(color: Colors.red[900], fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: color, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

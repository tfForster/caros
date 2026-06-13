import 'dart:async';
import 'package:flutter/material.dart';
import '/config/app.dart';
import '/widgets/bottom_navigation.dart';

enum _CallState { idle, calling, active, incoming }

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  String _selectedTab  = 'Recent';
  bool   _showDialPad  = false;
  _CallState _callState = _CallState.idle;

  String _callerName   = '';
  String _callerNumber = '';

  int     _callSeconds = 0;
  Timer?  _callTimer;
  bool    _muted       = false;
  bool    _speaker     = false;

  final TextEditingController _dialController = TextEditingController();

  final List<Map<String, dynamic>> _recentCalls = [
    {'name': 'Sarah M.',        'number': '+49 170 1234567', 'type': 'incoming', 'time': '10:42'},
    {'name': 'Jake R.',         'number': '+49 151 9876543', 'type': 'outgoing', 'time': 'Gestern'},
    {'name': 'Mama',            'number': '+49 172 5551090', 'type': 'incoming', 'time': 'Gestern'},
    {'name': '+49 160 2771234', 'number': '+49 160 2771234', 'type': 'missed',   'time': 'Mo'},
    {'name': 'Werkstatt',       'number': '+49 89 1234560',  'type': 'outgoing', 'time': 'Mo'},
  ];

  final List<Map<String, String>> _contacts = [
    {'name': 'Jake R.',   'number': '+49 151 9876543'},
    {'name': 'Mama',      'number': '+49 172 5551090'},
    {'name': 'Papa',      'number': '+49 173 1010101'},
    {'name': 'Sarah M.',  'number': '+49 170 1234567'},
    {'name': 'Werkstatt', 'number': '+49 89 1234560'},
    {'name': 'Zuhause',   'number': '+49 89 9988776'},
  ];

  @override
  void dispose() {
    _callTimer?.cancel();
    _dialController.dispose();
    super.dispose();
  }

  void _startCall(String name, String number) {
    setState(() {
      _callerName   = name.isNotEmpty ? name : number;
      _callerNumber = number;
      _callState    = _CallState.calling;
      _callSeconds  = 0;
    });
    // simulate pickup after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || _callState != _CallState.calling) return;
      setState(() => _callState = _CallState.active);
      _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _callSeconds++);
      });
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    setState(() {
      _callState   = _CallState.idle;
      _callSeconds = 0;
      _muted       = false;
      _speaker     = false;
    });
  }

  void _answerCall() {
    setState(() => _callState = _CallState.active);
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _callSeconds++);
    });
  }

  void _simulateIncoming() {
    if (_callState != _CallState.idle) return;
    setState(() {
      _callerName   = 'Sarah M.';
      _callerNumber = '+49 170 1234567';
      _callState    = _CallState.incoming;
      _callSeconds  = 0;
    });
  }

  String get _formattedTime {
    final m = (_callSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_callSeconds  % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: App.bg,
      appBar: AppBar(
        backgroundColor: App.bg,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.bluetooth_connected, color: App.accent, size: 18),
                const SizedBox(width: 6),
                Text('Telefon verbunden', style: TextStyle(color: App.accent, fontSize: 14)),
              ],
            ),
            Row(
              children: [
                // demo button for incoming call
                if (_callState == _CallState.idle)
                  GestureDetector(
                    onTap: _simulateIncoming,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: App.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: App.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.call_received, color: Colors.white38, size: 14),
                          SizedBox(width: 4),
                          Text('Demo: Anruf', style: TextStyle(color: Colors.white38, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                const Text('5:00', style: TextStyle(color: Colors.white54, fontSize: 15)),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Row(
            children: [
              _buildSidebar(),
              Container(width: 1, color: App.border),
              Expanded(child: _showDialPad ? _buildDialPad() : _buildContent()),
            ],
          ),
          if (_callState != _CallState.idle)
            _buildCallOverlay(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoNote('Demo-UI  ·  Echte Anrufsteuerung via Bluetooth HFP — geplant für Linux-Deployment (BlueZ)'),
          const BottomNavigationBarWidget(currentPage: 'Phone'),
        ],
      ),
    );
  }

  Widget _buildInfoNote(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: App.surface,
        border: Border(top: BorderSide(color: App.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 12, color: Colors.white24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white24, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ── Sidebar ────────────────────────────────────────────────────────────────

  Widget _buildSidebar() {
    return Container(
      width: 100,
      color: App.bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSidebarTab(Icons.history,  'Recent'),
          const SizedBox(height: 24),
          _buildSidebarTab(Icons.contacts, 'Contacts'),
          const SizedBox(height: 24),
          _buildSidebarTab(Icons.dialpad,  'Dial Pad'),
        ],
      ),
    );
  }

  Widget _buildSidebarTab(IconData icon, String label) {
    final isSelected = label == (_showDialPad ? 'Dial Pad' : _selectedTab);
    return GestureDetector(
      onTap: () => setState(() {
        _showDialPad = label == 'Dial Pad';
        if (!_showDialPad) _selectedTab = label;
      }),
      child: Column(
        children: [
          Icon(icon, size: 28, color: isSelected ? App.accent : Colors.white38),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:      isSelected ? App.accent : Colors.white38,
              fontSize:   11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ── Content area ───────────────────────────────────────────────────────────

  Widget _buildContent() {
    if (_selectedTab == 'Recent') return _buildRecentCalls();
    return _buildContacts();
  }

  Widget _buildRecentCalls() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _recentCalls.length,
      separatorBuilder: (_, __) => Divider(color: App.border, height: 1),
      itemBuilder: (context, i) {
        final call      = _recentCalls[i];
        final isMissed  = call['type'] == 'missed';
        final isOutgoing = call['type'] == 'outgoing';
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: App.surface,
            child: Icon(
              isOutgoing ? Icons.call_made : Icons.call_received,
              color: isMissed ? Colors.red[400] : Colors.white54,
              size: 18,
            ),
          ),
          title: Text(
            call['name'],
            style: TextStyle(
              color:      isMissed ? Colors.red[400] : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(call['number'], style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(call['time'], style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _startCall(call['name'], call['number']),
                child: Icon(Icons.call, color: App.accent, size: 20),
              ),
            ],
          ),
          onTap: () => _startCall(call['name'], call['number']),
        );
      },
    );
  }

  Widget _buildContacts() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _contacts.length,
      separatorBuilder: (_, __) => Divider(color: App.border, height: 1),
      itemBuilder: (context, i) {
        final c = _contacts[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: App.accent.withValues(alpha: 0.2),
            child: Text(c['name']![0], style: TextStyle(color: App.accent, fontWeight: FontWeight.bold)),
          ),
          title:    Text(c['name']!,   style: const TextStyle(color: Colors.white)),
          subtitle: Text(c['number']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: Icon(Icons.call, color: App.accent, size: 20),
          onTap:    () => _startCall(c['name']!, c['number']!),
        );
      },
    );
  }

  // ── Dial Pad ───────────────────────────────────────────────────────────────

  Widget _buildDialPad() {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color:  App.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: App.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dialController,
                  autofocus: false,
                  style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2),
                  decoration: const InputDecoration(
                    hintText: 'Nummer eingeben',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 16, letterSpacing: 0),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final text = _dialController.text;
                  if (text.isNotEmpty) {
                    _dialController.text = text.substring(0, text.length - 1);
                    _dialController.selection = TextSelection.collapsed(offset: _dialController.text.length);
                    setState(() {});
                  }
                },
                child: const Icon(Icons.backspace_outlined, color: Colors.white38, size: 20),
              ),
            ],
          ),
        ),
        // keys
        ...rows.map((row) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) => _buildDialKey(key)).toList(),
          ),
        )),
        const SizedBox(height: 16),
        // call button
        GestureDetector(
          onTap: () {
            final number = _dialController.text.trim();
            if (number.isNotEmpty) _startCall('', number);
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
            child: const Icon(Icons.call, color: Colors.white, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildDialKey(String key) {
    return GestureDetector(
      onTap: () {
        _dialController.text += key;
        _dialController.selection = TextSelection.collapsed(offset: _dialController.text.length);
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color:  App.surface,
          shape:  BoxShape.circle,
          border: Border.all(color: App.border),
        ),
        child: Center(
          child: Text(key, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400)),
        ),
      ),
    );
  }

  // ── Call overlay ───────────────────────────────────────────────────────────

  Widget _buildCallOverlay() {
    return Positioned.fill(
      child: Container(
        color: App.bg.withValues(alpha: 0.97),
        child: _callState == _CallState.incoming
            ? _buildIncomingScreen()
            : _buildActiveCallScreen(),
      ),
    );
  }

  Widget _buildIncomingScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCallerAvatar(size: 72),
        const SizedBox(height: 20),
        Text(_callerName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(_callerNumber, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 8),
        const Text('Eingehender Anruf', style: TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // decline
            _buildCallButton(
              icon: Icons.call_end,
              color: Colors.red[700]!,
              label: 'Ablehnen',
              onTap: _endCall,
            ),
            const SizedBox(width: 60),
            // answer
            _buildCallButton(
              icon: Icons.call,
              color: const Color(0xFF2E7D32),
              label: 'Annehmen',
              onTap: _answerCall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveCallScreen() {
    final isConnecting = _callState == _CallState.calling;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCallerAvatar(size: 72),
        const SizedBox(height: 20),
        Text(_callerName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(_callerNumber, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 8),
        Text(
          isConnecting ? 'Verbinde...' : _formattedTime,
          style: TextStyle(
            color:    isConnecting ? App.accent : Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: isConnecting ? 0 : 2,
          ),
        ),
        const SizedBox(height: 40),
        // secondary controls
        if (!isConnecting)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSecondaryButton(
                icon:    _muted ? Icons.mic_off : Icons.mic,
                label:   _muted ? 'Stumm' : 'Mikrofon',
                active:  _muted,
                onTap: () => setState(() => _muted = !_muted),
              ),
              const SizedBox(width: 32),
              _buildSecondaryButton(
                icon:   _speaker ? Icons.volume_up : Icons.volume_down,
                label:  'Lautsprecher',
                active: _speaker,
                onTap: () => setState(() => _speaker = !_speaker),
              ),
              const SizedBox(width: 32),
              _buildSecondaryButton(
                icon:  Icons.dialpad,
                label: 'Tastatur',
                active: false,
                onTap: () {},
              ),
            ],
          ),
        const SizedBox(height: 36),
        _buildCallButton(
          icon:  Icons.call_end,
          color: Colors.red[700]!,
          label: 'Auflegen',
          onTap: _endCall,
        ),
      ],
    );
  }

  Widget _buildCallerAvatar({required double size}) {
    final initial = _callerName.isNotEmpty ? _callerName[0].toUpperCase() : '#';
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        color:  App.accent.withValues(alpha: 0.15),
        shape:  BoxShape.circle,
        border: Border.all(color: App.accent.withValues(alpha: 0.4), width: 2),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(color: App.accent, fontSize: size * 0.44, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color    color,
    required String   label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String   label,
    required bool     active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:  active ? App.accent.withValues(alpha: 0.2) : App.surface,
              shape:  BoxShape.circle,
              border: Border.all(color: active ? App.accent : App.border),
            ),
            child: Icon(icon, color: active ? App.accent : Colors.white54, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

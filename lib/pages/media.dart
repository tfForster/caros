import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import '/widgets/bottom_navigation.dart';
import '/config/app.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  final AudioPlayer _player = AudioPlayer();
  String _source = 'USB';

  List<Map<String, String>> _playlist = [];
  List<Source> _audioSources = [];
  int _currentIndex = -1;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.8;
  bool _showPlaylist = false;

  StreamSubscription? _stateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;

  @override
  void initState() {
    super.initState();
    _player.setVolume(_volume);
    _stateSub    = _player.onPlayerStateChanged.listen((s) => setState(() => _playerState = s));
    _positionSub = _player.onPositionChanged.listen((p)     => setState(() => _position = p));
    _durationSub = _player.onDurationChanged.listen((d)     => setState(() => _duration = d));
    _player.onPlayerComplete.listen((_) => _next());
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.audio,
      withData: kIsWeb,
    );
    if (result == null) return;

    final newTracks = <Map<String, String>>[];
    final newSources = <Source>[];

    for (final f in result.files) {
      final name = f.name.replaceAll(
          RegExp(r'\.(mp3|wav|aac|m4a|ogg|flac)$', caseSensitive: false), '');
      final parts = name.split(' - ');
      newTracks.add({
        'title':  parts.length > 1 ? parts.sublist(1).join(' - ').trim() : name,
        'artist': parts.length > 1 ? parts[0].trim() : 'Unbekannt',
      });
      if (kIsWeb) {
        newSources.add(BytesSource(f.bytes!));
      } else {
        newSources.add(DeviceFileSource(f.path!));
      }
    }

    setState(() {
      _playlist = [..._playlist, ...newTracks];
      _audioSources = [..._audioSources, ...newSources];
    });
  }

  Future<void> _clearPlaylist() async {
    await _player.stop();
    setState(() {
      _playlist = [];
      _audioSources = [];
      _currentIndex = -1;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
  }

  Future<void> _playAt(int index) async {
    if (index < 0 || index >= _audioSources.length) return;
    setState(() {
      _currentIndex = index;
      _position = Duration.zero;
    });
    await _player.play(_audioSources[index]);
  }

  Future<void> _togglePlay() async {
    if (_playerState == PlayerState.playing) {
      await _player.pause();
    } else if (_playerState == PlayerState.paused) {
      await _player.resume();
    } else if (_playlist.isNotEmpty) {
      await _playAt(_currentIndex < 0 ? 0 : _currentIndex);
    }
  }

  void _next() {
    if (_playlist.isEmpty) return;
    _playAt((_currentIndex + 1) % _playlist.length);
  }

  void _prev() {
    if (_playlist.isEmpty) return;
    if (_position.inSeconds > 3) {
      _player.seek(Duration.zero);
    } else {
      _playAt((_currentIndex - 1 + _playlist.length) % _playlist.length);
    }
  }

  Future<void> _setVolume(double v) async {
    setState(() => _volume = v);
    await _player.setVolume(v);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

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
            Text('Media', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
            Text('5:00', style: TextStyle(color: Colors.white54, fontSize: 15)),
          ],
        ),
      ),
      body: Row(
        children: [
          _buildSourceBar(),
          const VerticalDivider(color: Color(0xFF1E1E1E), width: 1),
          Expanded(child: _source == 'USB' ? _buildUsbView() : _buildBtView()),
          const VerticalDivider(color: Color(0xFF1E1E1E), width: 1),
          _buildVolumePanel(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoNote(
            _source == 'USB'
                ? 'Demo: lokale Dateien per Datei-Picker  ·  Im Fahrzeug: Telefon via USB/MTP direkt einbindbar'
                : 'Demo-Ansicht  ·  Echte Wiedergabe via Bluetooth A2DP + AVRCP — geplant für Linux-Deployment (BlueZ)',
          ),
          const BottomNavigationBarWidget(currentPage: 'Media'),
        ],
      ),
    );
  }

  Widget _buildSourceBar() {
    final sources = [
      {'label': 'USB', 'icon': Icons.usb},
      {'label': 'BT',  'icon': Icons.bluetooth_audio},
    ];

    return Container(
      width: 80,
      color: App.bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: sources.map((s) {
          final isSelected = s['label'] == _source;
          return GestureDetector(
            onTap: () => setState(() => _source = s['label'] as String),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? App.accent.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? App.accent : Colors.transparent),
              ),
              child: Column(
                children: [
                  Icon(s['icon'] as IconData, color: isSelected ? App.accent : Colors.white38, size: 24),
                  const SizedBox(height: 4),
                  Text(s['label'] as String, style: TextStyle(color: isSelected ? App.accent : Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUsbView() {
    final hasTrack = _currentIndex >= 0 && _playlist.isNotEmpty;
    final track = hasTrack ? _playlist[_currentIndex] : null;
    final isPlaying = _playerState == PlayerState.playing;
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;

    return Row(
      children: [
        // Main player — always full height
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Album art
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: App.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: App.border),
                ),
                child: Icon(
                  Icons.music_note,
                  size: 54,
                  color: hasTrack ? App.accent.withValues(alpha: 0.4) : const Color(0xFF2A2A2A),
                ),
              ),
              const SizedBox(height: 16),
              // Title + artist
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      track?['title'] ?? 'Keine Datei geladen',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track?['artist'] ?? '',
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: App.accent,
                        inactiveTrackColor: App.border,
                        thumbColor: Colors.white,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: hasTrack
                            ? (v) => _player.seek(Duration(milliseconds: (v * _duration.inMilliseconds).round()))
                            : null,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(_position), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        Text(_fmt(_duration), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Playback controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ctrlBtn(Icons.skip_previous, _prev),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(color: App.accent, shape: BoxShape.circle),
                      child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(width: 20),
                  _ctrlBtn(Icons.skip_next, _next),
                ],
              ),
              const SizedBox(height: 20),
              // Bottom row: load + queue toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _textBtn(Icons.folder_open, 'Laden', _pickFiles),
                  if (_playlist.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    _textBtn(
                      Icons.queue_music,
                      _showPlaylist ? 'Liste schließen' : 'Playlist (${_playlist.length})',
                      () => setState(() => _showPlaylist = !_showPlaylist),
                      active: _showPlaylist,
                    ),
                    const SizedBox(width: 12),
                    _textBtn(Icons.delete_outline, 'Leeren', _clearPlaylist),
                  ],
                ],
              ),
            ],
          ),
        ),
        // Sliding playlist sidebar
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: _showPlaylist ? 260 : 0,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: 0,
              maxWidth: 260,
              child: Container(
                width: 260,
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0xFF1E1E1E))),
                ),
                child: ListView.builder(
                  itemCount: _playlist.length,
                  itemBuilder: (context, i) {
                    final isActive = i == _currentIndex;
                    return InkWell(
                      onTap: () => _playAt(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        color: isActive ? App.accent.withValues(alpha: 0.08) : Colors.transparent,
                        child: Row(
                          children: [
                            Icon(
                              isActive && isPlaying ? Icons.equalizer : Icons.music_note,
                              color: isActive ? App.accent : Colors.white38,
                              size: 15,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _playlist[i]['title']!,
                                    style: TextStyle(
                                      color: isActive ? Colors.white : Colors.white70,
                                      fontSize: 12,
                                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _playlist[i]['artist']!,
                                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textBtn(IconData icon, String label, VoidCallback onTap, {bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? App.accent.withValues(alpha: 0.12) : App.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? App.accent : App.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? App.accent : Colors.white54, size: 15),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: active ? App.accent : Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBtView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Device status bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          color: App.surface,
          child: Row(
            children: [
              const Icon(Icons.bluetooth_connected, color: App.accent, size: 16),
              const SizedBox(width: 8),
              const Text('Samsung Galaxy S24  —  A2DP verbunden',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: App.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: App.accent.withValues(alpha: 0.3)),
                ),
                child: const Text('AVRCP', style: TextStyle(color: App.accent, fontSize: 10)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Album art
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: App.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: App.border),
          ),
          child: Icon(Icons.music_note, size: 54, color: App.accent.withValues(alpha: 0.3)),
        ),
        const SizedBox(height: 16),
        const Text('Blinding Lights',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('The Weeknd',
            style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 20),
        // Progress (static demo)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: App.accent,
                  inactiveTrackColor: App.border,
                  thumbColor: Colors.white,
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: const Slider(value: 0.38, onChanged: null),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1:22', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    Text('3:38', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ctrlBtn(Icons.skip_previous, () {}),
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: App.accent, shape: BoxShape.circle),
              child: const Icon(Icons.pause, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            _ctrlBtn(Icons.skip_next, () {}),
          ],
        ),
      ],
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

  Widget _buildVolumePanel() {
    return Container(
      width: 64,
      color: App.bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('VOL', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
          const SizedBox(height: 12),
          _ctrlBtn(Icons.add, () => _setVolume((_volume + 0.05).clamp(0, 1))),
          const SizedBox(height: 12),
          RotatedBox(
            quarterTurns: 3,
            child: SizedBox(
              width: 100,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: App.accent,
                  inactiveTrackColor: App.border,
                  thumbColor: Colors.white,
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(value: _volume, onChanged: _setVolume),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ctrlBtn(Icons.remove, () => _setVolume((_volume - 0.05).clamp(0, 1))),
          const SizedBox(height: 8),
          Text('${(_volume * 100).round()}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _ctrlBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: App.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: App.border),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

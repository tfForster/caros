import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '/config/app.dart';
import '/widgets/bottom_navigation.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> with SingleTickerProviderStateMixin {
  final MapController         _mapController    = MapController();
  final TextEditingController _searchController = TextEditingController();

  // pulsing animation for my-location dot
  late AnimationController _pulseController;
  late Animation<double>   _pulseAnim;

  LatLng _myLocation = const LatLng(48.1351, 11.5820);

  bool   _isNavigating    = false;
  bool   _loadingRoute    = false;
  String _destination     = '';
  bool   _showSuggestions = false;

  List<LatLng> _routePoints = [];
  int    _etaSeconds  = 0;
  double _remainingKm = 0;
  int    _turnIndex   = 0;
  Timer? _navTimer;

  final List<Map<String, dynamic>> _savedPlaces = [
    {'label': 'Zuhause',   'address': 'Maxvorstadt',   'icon': 'home',   'lat': 48.1486, 'lng': 11.5726},
    {'label': 'Arbeit',    'address': 'Olympiapark',    'icon': 'work',   'lat': 48.1754, 'lng': 11.5502},
    {'label': 'Werkstatt', 'address': 'BMW Welt',       'icon': 'dealer', 'lat': 48.1770, 'lng': 11.5565},
    {'label': 'Tanken',    'address': 'Autobahn A9',    'icon': 'fuel',   'lat': 48.1200, 'lng': 11.5950},
  ];

  final List<Map<String, dynamic>> _extraPlaces = [
    {'label': 'Hauptbahnhof',      'address': 'München Hbf',           'lat': 48.1402, 'lng': 11.5603},
    {'label': 'Marienplatz',       'address': 'München Zentrum',        'lat': 48.1371, 'lng': 11.5754},
    {'label': 'Englischer Garten', 'address': 'Nördlicher Teil',        'lat': 48.1640, 'lng': 11.6050},
    {'label': 'Allianz Arena',     'address': 'Werner-Heisenberg-Al.',  'lat': 48.2188, 'lng': 11.6247},
    {'label': 'Flughafen',         'address': 'MUC Terminal 1',         'lat': 48.3538, 'lng': 11.7750},
  ];

  final List<Map<String, dynamic>> _turns = [
    {'icon': Icons.turn_right,   'dist': '500 m',  'text': 'Rechts abbiegen',        'road': 'Hauptstraße'},
    {'icon': Icons.straight,      'dist': '2,1 km', 'text': 'Geradeaus weiter',       'road': 'Leopoldstraße'},
    {'icon': Icons.turn_left,     'dist': '800 m',  'text': 'Links abbiegen',          'road': 'Schleißheimer Str.'},
    {'icon': Icons.turn_right,    'dist': '300 m',  'text': 'Rechts — Ziel erreicht', 'road': ''},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _navTimer?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ── Snap tap to nearest road ───────────────────────────────────────────────

  Future<LatLng> _snapToRoad(LatLng point) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/nearest/v1/driving/'
      '${point.longitude},${point.latitude}?number=1',
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final loc  = ((data['waypoints'] as List).first)['location'] as List;
        return LatLng((loc[1] as num).toDouble(), (loc[0] as num).toDouble());
      }
    } catch (_) {}
    return point;
  }

  void _onMapTap(LatLng point) {
    if (_isNavigating || _loadingRoute) return;
    // optimistic: set immediately so marker moves right away
    setState(() {
      _myLocation  = point;
      _routePoints = [];
    });
    // then quietly snap to nearest road
    _snapToRoad(point).then((snapped) {
      if (!mounted) return;
      setState(() => _myLocation = snapped);
    });
  }

  // ── Route via OSRM ─────────────────────────────────────────────────────────

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    setState(() => _loadingRoute = true);

    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data   = jsonDecode(res.body) as Map<String, dynamic>;
        final route  = (data['routes'] as List).first as Map<String, dynamic>;
        final coords = (route['geometry']['coordinates'] as List)
            .map((c) => LatLng(
                  (c[1] as num).toDouble(),
                  (c[0] as num).toDouble(),
                ))
            .toList();
        final eta  = (route['duration'] as num).round();
        final dist = (route['distance'] as num) / 1000;

        if (!mounted) return;
        setState(() {
          _routePoints  = coords;
          _etaSeconds   = eta;
          _remainingKm  = dist;
          _loadingRoute = false;
        });

        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(coords),
            padding: const EdgeInsets.fromLTRB(40, 80, 40, 80),
          ),
        );
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _routePoints  = [from, to];
      _etaSeconds   = 840;
      _remainingKm  = const Distance().as(LengthUnit.Kilometer, from, to);
      _loadingRoute = false;
    });
  }

  // ── Navigation control ─────────────────────────────────────────────────────

  Future<void> _startNavigation(Map<String, dynamic> place) async {
    _navTimer?.cancel();
    setState(() {
      _destination     = place['label'] as String;
      _isNavigating    = true;
      _turnIndex       = 0;
      _showSuggestions = false;
      _routePoints     = [];
      _searchController.text = _destination;
    });

    await _fetchRoute(
      _myLocation,
      LatLng(place['lat'] as double, place['lng'] as double),
    );
    if (!mounted || !_isNavigating) return;

    _navTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_etaSeconds > 0) _etaSeconds--;
        _remainingKm = (_remainingKm - 0.001).clamp(0, 999);
        if (t.tick % 30 == 0 && _turnIndex < _turns.length - 1) _turnIndex++;
        if (_etaSeconds == 0) _endNavigation();
      });
    });
  }

  void _endNavigation() {
    _navTimer?.cancel();
    setState(() {
      _isNavigating    = false;
      _destination     = '';
      _showSuggestions = false;
      _routePoints     = [];
      _searchController.clear();
    });
    _mapController.move(_myLocation, 13);
  }

  // ── Misc helpers ───────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _suggestions {
    final q = _searchController.text.toLowerCase().trim();
    if (q.isEmpty) return [];
    return [..._savedPlaces, ..._extraPlaces]
        .where((p) =>
            (p['label'] as String).toLowerCase().contains(q) ||
            (p['address'] as String).toLowerCase().contains(q))
        .take(5)
        .toList();
  }

  LatLng? get _destLatLng {
    final all = [..._savedPlaces, ..._extraPlaces];
    final p   = all.where((e) => e['label'] == _destination).firstOrNull;
    if (p == null) return null;
    return LatLng(p['lat'] as double, p['lng'] as double);
  }

  String get _etaLabel {
    final m = _etaSeconds ~/ 60;
    final s = _etaSeconds  % 60;
    return m > 0 ? '$m min' : '$s s';
  }

  IconData _placeIcon(String type) {
    switch (type) {
      case 'home':  return Icons.home;
      case 'work':  return Icons.business;
      case 'fuel':  return Icons.local_gas_station;
      default:      return Icons.location_on;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final currentTurn = _isNavigating ? _turns[_turnIndex] : null;

    return Scaffold(
      backgroundColor: App.bg,
      body: Stack(
        children: [
          // ── map ─────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _myLocation,
              initialZoom: 13.0,
              onTap: (_, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.test_app',
              ),
              if (_routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: App.accent,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // ── my location (pulsing) ──────────────────────────────
                  Marker(
                    point: _myLocation,
                    width: 48,
                    height: 48,
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, _) => Stack(
                        alignment: Alignment.center,
                        children: [
                          // outer pulse ring
                          Container(
                            width: 48 * _pulseAnim.value,
                            height: 48 * _pulseAnim.value,
                            decoration: BoxDecoration(
                              color: App.accent.withValues(
                                  alpha: (1.0 - _pulseAnim.value) * 0.45),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // inner dot
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: App.accent,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: App.accent.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── destination pin (Google Maps style) ────────────────
                  if (_isNavigating && _destLatLng != null)
                    Marker(
                      point: _destLatLng!,
                      width: 40,
                      height: 52,
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.place,
                                color: Colors.white, size: 18),
                          ),
                          // pin stem
                          Container(
                            width: 3,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(3),
                                bottomRight: Radius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── saved place pins (idle) ────────────────────────────
                  if (!_isNavigating)
                    ..._savedPlaces.map((p) => Marker(
                          point: LatLng(
                              p['lat'] as double, p['lng'] as double),
                          width: 32,
                          height: 42,
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: App.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: App.accent, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.35),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _placeIcon(p['icon'] as String),
                                  color: App.accent,
                                  size: 13,
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: App.accent,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(2),
                                    bottomRight: Radius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ],
          ),

          // ── search bar ──────────────────────────────────────────────────
          Positioned(
            top: 10, left: 10, right: 10,
            child: _buildSearchBar(),
          ),

          // ── suggestions ─────────────────────────────────────────────────
          if (_showSuggestions && _suggestions.isNotEmpty)
            Positioned(
              top: 64, left: 10, right: 10,
              child: _buildSuggestionsCard(),
            ),

          // ── loading spinner ──────────────────────────────────────────────
          if (_loadingRoute)
            Positioned(
              top: 64, left: 0, right: 0,
              child: Center(child: _buildLoadingChip()),
            ),

          // ── turn card ────────────────────────────────────────────────────
          if (currentTurn != null && !_loadingRoute)
            Positioned(
              top: 64, left: 0, right: 0,
              child: Center(child: _buildTurnCard(currentTurn)),
            ),

          // ── tap hint (idle) ──────────────────────────────────────────────
          if (!_isNavigating && !_showSuggestions && !_loadingRoute)
            Positioned(
              bottom: 58, left: 0, right: 0,
              child: Center(child: _buildTapHint()),
            ),

          // ── place chips (idle) ───────────────────────────────────────────
          if (!_isNavigating && !_showSuggestions)
            Positioned(
              bottom: 10, left: 10, right: 10,
              child: _buildPlaceChips(),
            ),

          // ── nav panel ────────────────────────────────────────────────────
          if (_isNavigating && !_loadingRoute)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildNavPanel(),
            ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoNote(
            'Karte: CartoDB / OSM  ·  Routing: OSRM  ·  Startpunkt: Karte antippen',
          ),
          const BottomNavigationBarWidget(currentPage: 'Nav'),
        ],
      ),
    );
  }

  // ── Widget builders ────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: App.bg.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: _showSuggestions ? App.accent : App.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Icon(
            _isNavigating ? Icons.navigation : Icons.search,
            color: _isNavigating ? App.accent : Colors.white38,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: _isNavigating
                    ? _destination
                    : 'Destination eingeben...',
                hintStyle:
                    const TextStyle(color: Colors.white38, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) =>
                  setState(() => _showSuggestions = v.trim().isNotEmpty),
              onSubmitted: (v) {
                final match = [..._savedPlaces, ..._extraPlaces]
                    .where((p) => (p['label'] as String)
                        .toLowerCase()
                        .contains(v.toLowerCase()))
                    .firstOrNull;
                if (match != null) _startNavigation(match);
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _showSuggestions = false);
              },
              child: const Icon(Icons.close,
                  color: Colors.white38, size: 16),
            ),
          if (_isNavigating) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _endNavigation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Beenden',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: App.bg.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: App.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)
        ],
      ),
      child: Column(
        children: _suggestions
            .map((s) => GestureDetector(
                  onTap: () => _startNavigation(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: App.border))),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            color: App.accent, size: 16),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['label'] as String,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            Text(s['address'] as String,
                                style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildLoadingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: App.bg.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: App.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: App.accent),
          ),
          const SizedBox(width: 10),
          const Text('Route wird berechnet…',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTurnCard(Map<String, dynamic> turn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: App.accent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(turn['icon'] as IconData, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(turn['dist'] as String,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 10)),
              Text(turn['text'] as String,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTapHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: App.bg.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: App.border),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app, color: Colors.white38, size: 13),
          SizedBox(width: 5),
          Text('Karte antippen = Startpunkt setzen',
              style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPlaceChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _savedPlaces
            .map((p) => GestureDetector(
                  onTap: () => _startNavigation(p),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: App.bg.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: App.border),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6)
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(_placeIcon(p['icon'] as String),
                            color: App.accent, size: 14),
                        const SizedBox(width: 6),
                        Text(p['label'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildNavPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: App.bg.withValues(alpha: 0.97),
        border: Border(top: BorderSide(color: App.border)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navStat(Icons.access_time,  'ETA',         _etaLabel),
          Container(width: 1, height: 28, color: App.border),
          _navStat(Icons.straighten,   'Entfernung',
              '${_remainingKm.toStringAsFixed(1)} km'),
          Container(width: 1, height: 28, color: App.border),
          _navStat(Icons.location_pin, 'Ziel',        _destination),
        ],
      ),
    );
  }

  Widget _navStat(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: App.accent, size: 15),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 9)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
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
            child: Text(text,
                style: const TextStyle(
                    color: Colors.white24, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class OurPlacesPage extends StatefulWidget {
  const OurPlacesPage({super.key});

  @override
  State<OurPlacesPage> createState() => _OurPlacesPageState();
}

class _OurPlacesPageState extends State<OurPlacesPage> {
  static const kPageBg = Color(0xFFFCE4EC);

  final MapController _mapController = MapController();

  // Centro inicial (fallback: Paraná)
  LatLng _currentCenter = const LatLng(-25.4300, -49.2700);
  bool _loadingLocation = true;
  bool _loadingPlaces = true;

  List<_Place> _places = [];

  @override
  void initState() {
    super.initState();
    // Busca lugares e localização em paralelo
    _loadPlacesFromRemoteConfig();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
  }

  Future<void> _loadPlacesFromRemoteConfig() async {
    try {
      final rc = FirebaseRemoteConfig.instance;

      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await rc.fetchAndActivate();

      final raw = rc.getString('our_places_json');
      final List<_Place> parsed = [];

      if (raw.isNotEmpty) {
        final dynamic data = json.decode(raw);
        if (data is List) {
          for (final item in data) {
            if (item is! Map) continue;

            final name = (item['name'] ?? '').toString();
            final reason = (item['reason'] ?? '').toString();
            final lat = (item['lat'] as num?)?.toDouble();
            final lng = (item['lng'] as num?)?.toDouble();

            if (name.isEmpty || reason.isEmpty || lat == null || lng == null) {
              continue;
            }

            parsed.add(
              _Place(name: name, reason: reason, point: LatLng(lat, lng)),
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _places = parsed; // agora sem fallback
          _loadingPlaces = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingPlaces = false;
        });
        _notify('Erro ao carregar lugares do Remote Config: $e');
      }
    }
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _notify('Ative a localização do aparelho');
        setState(() => _loadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _notify('Permissão de localização negada');
        setState(() => _loadingLocation = false);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _notify('Permissão negada permanentemente. Abra as configurações.');
        setState(() => _loadingLocation = false);
        return;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        ).timeout(const Duration(seconds: 5));
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        _notify('Não foi possível obter a localização');
        setState(() => _loadingLocation = false);
        return;
      }

      final here = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;

      setState(() {
        _currentCenter = here;
        _loadingLocation = false;
      });

      await Future.delayed(const Duration(milliseconds: 50));
      _mapController.move(here, 15.0);
    } catch (_) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _notify(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _recentre() async {
    await _initLocation();
    _mapController.move(_currentCenter, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPageBg,
      child: Stack(
        children: [
          // MAPA
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(-25.4300, -49.2700),
              initialZoom: 13.0,
              interactionOptions: InteractionOptions(
                flags: ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=5WRiohAcFVCpL65kG0ia',
                userAgentPackageName: 'com.example.poli_app',
              ),

              // Marcador da posição atual
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentCenter,
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: _PulseDot(isLoading: _loadingLocation),
                  ),
                ],
              ),

              // Lugares do Remote Config
              if (!_loadingPlaces)
                MarkerLayer(
                  markers: _places
                      .map(
                        (p) => Marker(
                          point: p.point,
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () => _openPlaceModal(p),
                            child: const _PlacePin(),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),

          // Loading discreto para lugares
          if (_loadingPlaces)
            const Positioned(
              top: 12,
              left: 12,
              child: _LoadingPill(text: 'Carregando lugares...'),
            ),

          // Botão recenter
          Positioned(
            right: 12,
            bottom: 12,
            child: FloatingActionButton(
              heroTag: 'recenter',
              mini: true,
              onPressed: _recentre,
              backgroundColor: const Color(0xFF7159c1),
              foregroundColor: Colors.white,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  void _openPlaceModal(_Place p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              p.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              p.reason,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '(${p.point.latitude.toStringAsFixed(5)}, ${p.point.longitude.toStringAsFixed(5)})',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------- modelos / widgets auxiliares ----------

class _Place {
  final String name;
  final String reason;
  final LatLng point;
  const _Place({required this.name, required this.reason, required this.point});
}

class _LoadingPill extends StatelessWidget {
  final String text;
  const _LoadingPill({required this.text});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// Bolinha da posição atual (com pulsar discreto)
class _PulseDot extends StatefulWidget {
  final bool isLoading;
  const _PulseDot({required this.isLoading});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: const Color(0xFF7159c1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );

    if (widget.isLoading) {
      return FadeTransition(
        opacity: _c.drive(Tween(begin: 0.3, end: 1.0)),
        child: dot,
      );
    }
    return dot;
  }
}

// Pin bonitinho
class _PlacePin extends StatelessWidget {
  const _PlacePin();
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        const Icon(Icons.location_on, size: 38, color: Color(0xFFE53935)),
        Positioned(
          bottom: -6,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

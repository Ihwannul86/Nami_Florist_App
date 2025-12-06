import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/location/location_service.dart';

class LocationTestPage extends StatefulWidget {
  const LocationTestPage({super.key});

  @override
  State<LocationTestPage> createState() => _LocationTestPageState();
}

class _LocationTestPageState extends State<LocationTestPage> {
  String _mode = '';
  Position? _position;
  String _error = '';

  // =========================
  // ✅ TEST NETWORK
  // =========================
  Future<void> _testNetwork() async {
    setState(() {
      _mode = 'Network';
      _position = null;
      _error = '';
    });

    try {
      final pos = await LocationService.getNetworkPosition();
      setState(() => _position = pos);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  // =========================
  // ✅ TEST GPS
  // =========================
  Future<void> _testGps() async {
    setState(() {
      _mode = 'GPS';
      _position = null;
      _error = '';
    });

    try {
      final pos = await LocationService.getGpsPosition();
      setState(() => _position = pos);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  // =========================
  // ✅ UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tes Lokasi (GPS vs Network)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // ✅ BUTTON
            // =========================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testNetwork,
                    child: const Text('Ambil dengan Network'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testGps,
                    child: const Text('Ambil dengan GPS'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =========================
            // ✅ MODE
            // =========================
            if (_mode.isNotEmpty)
              Text(
                'Mode: $_mode',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 12),

            // =========================
            // ✅ KOORDINAT
            // =========================
            if (_position != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Latitude : ${_position!.latitude}'),
                  Text('Longitude: ${_position!.longitude}'),
                  Text('Accuracy : ${_position!.accuracy} m'),
                  Text('Timestamp: ${_position!.timestamp}'),
                ],
              ),

            // =========================
            // ✅ ERROR
            // =========================
            if (_error.isNotEmpty)
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 16),

            // =========================
            // ✅ MAP (HANYA MUNCUL SAAT ADA MODE)
            // =========================
            if (_position != null)
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      _position!.latitude,
                      _position!.longitude,
                    ),
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.nami_florist',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            _position!.latitude,
                            _position!.longitude,
                          ),
                          child: Icon(
                            Icons.location_pin,
                            size: 45,
                            color: _mode == 'GPS'
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

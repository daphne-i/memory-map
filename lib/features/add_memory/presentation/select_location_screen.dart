import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;

  // The initState method has been removed.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin a Location'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(13.0827, 80.2707),
              initialZoom: 13.0,
              // ADD THIS onMapReady CALLBACK
              onMapReady: () {
                setState(() {
                  _selectedLocation = _mapController.camera.center;
                });
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _selectedLocation = position.center;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.memories_map',
              ),
            ],
          ),
          const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 50,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_selectedLocation != null) {
            Navigator.of(context).pop(_selectedLocation);
          }
        },
        label: const Text('Confirm Location'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
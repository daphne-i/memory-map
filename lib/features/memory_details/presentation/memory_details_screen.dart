import 'dart:io'; // Required for displaying images from files
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memories_map/data/models/memory.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';



class MemoryDetailsScreen extends StatelessWidget {
  final Memory memory;
  const MemoryDetailsScreen({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    final location = memory.location.value;
    final hasLocation = location?.latitude != null && location?.longitude != null;
    final hasPhotos = memory.photoPaths.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(memory.title),
        backgroundColor: const Color(0xFF2D273A),
      ),
      backgroundColor: const Color(0xFF2D273A),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show a carousel of photos if they exist
              if (hasPhotos) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 250, // Larger height for photos
                    child: PageView.builder(
                      itemCount: memory.photoPaths.length,
                      itemBuilder: (context, index) {
                        return Image.file(
                          File(memory.photoPaths[index]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Display the Date
              Text(
                DateFormat('EEEE, MMMM dd, yyyy').format(memory.date),
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Display the Title
              Text(
                memory.title,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Display the Map
              if (hasLocation) ...[
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 150, // Smaller map preview
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(location!.latitude, location.longitude),
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.memories_map',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(location.latitude, location.longitude),
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              if (memory.tags.isNotEmpty) ...[
                const Text(
                  'Tags',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: memory.tags.map((tag) => Chip(
                    label: Text(tag.name),
                    backgroundColor: const Color(0xFF8E44AD),
                    labelStyle: const TextStyle(color: Colors.white),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
              ],

              // Display the Notes
              Text(
                memory.notes,
                style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
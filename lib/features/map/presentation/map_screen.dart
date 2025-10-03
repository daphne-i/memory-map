import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import
import 'package:memories_map/data/repositories/memory_repository.dart';
import 'package:memories_map/features/add_memory/presentation/add_details_screen.dart';
import 'package:memories_map/features/add_memory/presentation/select_location_screen.dart'; // Add this import


final memoriesStreamProvider = StreamProvider((ref) {
  final repo = ref.watch(memoryRepositoryProvider);
  return repo.watchAllMemories();
});

// Placeholder for the Timeline Screen we'll create later
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Timeline Screen'),
      ),
    );
  }
}

// This will be our main screen with the Bottom Navigation Bar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of the main screens
  final List<Widget> _screens = [
    const MapView(), // The actual map will go here
    const TimelineScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
        ],
      ),
    );
  }
}


class MapView extends ConsumerWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the stream provider
    final memoriesAsyncValue = ref.watch(memoriesStreamProvider);

    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(13.0827, 80.2707),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.memories_map',
          ),
          // Use the 'when' method to handle loading/error/data states
          memoriesAsyncValue.when(
            loading: () => const SizedBox.shrink(), // Don't show anything while loading
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (memories) {
              // Once data is loaded, build the MarkerLayer
              final markers = memories.map((memory) {
                // Ensure the location and its value are not null
                if (memory.location.value?.latitude != null) {
                  return Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(
                      memory.location.value!.latitude,
                      memory.location.value!.longitude,
                    ),
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  );
                }
                return null; // Return null for memories without a location
              }).whereType<Marker>().toList(); // Filter out any null markers

              return MarkerLayer(markers: markers);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the select location screen
          final LatLng? selectedLocation = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SelectLocationScreen()),
          );

          if (selectedLocation != null) {
            if (!context.mounted) return;
            // Show the new screen as a modal bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // Allows the sheet to be taller
              builder: (ctx) => AddDetailsScreen(location: selectedLocation),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

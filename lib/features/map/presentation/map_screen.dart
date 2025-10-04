import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import
import 'package:memories_map/data/models/memory.dart';
import 'package:memories_map/data/repositories/memory_repository.dart';
import 'package:memories_map/features/add_memory/presentation/add_details_screen.dart';
import 'package:memories_map/features/add_memory/presentation/select_location_screen.dart';
import 'package:memories_map/features/map/presentation/widgets/memory_preview_card.dart'; // Add this import
import 'package:memories_map/features/timeline/presentation/timeline_screen.dart';


final memoriesStreamProvider = StreamProvider((ref) {
  final repo = ref.watch(memoryRepositoryProvider);
  return repo.watchAllMemories();
});

final selectedMemoryProvider = StateProvider<Memory?>((ref) => null);


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
    const MapView(),
    const TimelineScreen(), // This now refers to your new, real screen
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
    final memoriesAsyncValue = ref.watch(memoriesStreamProvider);
    final selectedMemory = ref.watch(selectedMemoryProvider);

    return Scaffold(
      // We use a Stack to place the preview card on top of the map
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(13.0827, 80.2707),
              initialZoom: 13.0,
              // When the map is tapped, deselect any memory
              onTap: (_, __) => ref.read(selectedMemoryProvider.notifier).state = null,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.memories_map',
              ),
              memoriesAsyncValue.when(
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (memories) {
                  final markers = memories.map((memory) {
                    if (memory.location.value?.latitude != null) {
                      return Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(
                          memory.location.value!.latitude,
                          memory.location.value!.longitude,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // When a pin is tapped, update the selectedMemoryProvider
                            ref.read(selectedMemoryProvider.notifier).state = memory;
                          },
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      );
                    }
                    return null;
                  }).whereType<Marker>().toList();

                  return MarkerLayer(markers: markers);
                },
              ),
            ],
          ),
          // If a memory is selected, show the preview card at the bottom
          if (selectedMemory != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MemoryPreviewCard(
                memory: selectedMemory,
                onDismiss: () {
                  // The close button on the card will deselect the memory
                  ref.read(selectedMemoryProvider.notifier).state = null;
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final LatLng? selectedLocation = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SelectLocationScreen()),
          );

          if (selectedLocation != null) {
            if (!context.mounted) return;
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (ctx) => AddDetailsScreen(location: selectedLocation),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
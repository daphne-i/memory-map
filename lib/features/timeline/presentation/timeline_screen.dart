import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memories_map/data/models/memory.dart';
import 'package:memories_map/data/repositories/memory_repository.dart';
import 'package:memories_map/features/memory_details/presentation/memory_details_screen.dart';

// Provider to fetch and watch the sorted list of memories
final timelineMemoriesProvider = StreamProvider<List<Memory>>((ref) {
  final repo = ref.watch(memoryRepositoryProvider);
  return repo.watchAllMemoriesByDate();
});

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsyncValue = ref.watch(timelineMemoriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF2D273A),
      appBar: AppBar(
        title: const Text('Timeline'),
        backgroundColor: const Color(0xFF2D273A),
      ),
      body: memoriesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (memories) {
          if (memories.isEmpty) {
            return const Center(
              child: Text(
                'No memories yet.\nAdd one from the map screen!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return TimelineMemoryCard(memory: memory);
            },
          );
        },
      ),
    );
  }
}

// A dedicated widget for displaying a single memory in the timeline
class TimelineMemoryCard extends StatelessWidget {
  final Memory memory;
  const TimelineMemoryCard({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = memory.photoPaths.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemoryDetailsScreen(memory: memory),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFF3F3B4A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Thumbnail Photo
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: hasPhoto
                      ? Image.file(
                    File(memory.photoPaths.first),
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: const Color(0xFF5D596B),
                    child: const Icon(Icons.photo_camera_back, color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Memory Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(memory.date),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    // Placeholder for tags
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: const [
                        Chip(
                          label: Text('Travel'),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        Chip(
                          label: Text('Romantic'),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
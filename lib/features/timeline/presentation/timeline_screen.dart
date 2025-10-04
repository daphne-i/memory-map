import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:memories_map/core/provider/filter_providers.dart';
import 'package:memories_map/data/models/memory.dart';
import 'package:memories_map/data/models/tag.dart';
import 'package:memories_map/data/repositories/memory_repository.dart';
import 'package:memories_map/features/memory_details/presentation/memory_details_screen.dart';

// Provider to get a list of all unique tags available in the database
final allTagsProvider = StreamProvider<List<Tag>>((ref) {
  final repo = ref.watch(memoryRepositoryProvider);
  return repo.watchAllTags();
});

// The single, correct timeline provider. It now watches the filter provider.
// When the filter changes, this provider will automatically re-run.
final timelineMemoriesProvider = StreamProvider<List<Memory>>((ref) {
  final repo = ref.watch(memoryRepositoryProvider);
  final selectedTags = ref.watch(tagFilterProvider);
  // It calls the new, correct method in the repository
  return repo.watchFilteredMemoriesByDate(selectedTags);
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
      body: Column(
        children: [
          // The filter bar at the top
          const FilterBar(),
          Expanded(
            child: memoriesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (memories) {
                if (memories.isEmpty) {
                  return const Center(
                    child: Text(
                      'No memories found.\nTry changing your filter or adding a new memory.',
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
          ),
        ],
      ),
    );
  }
}

// The widget for the horizontal list of filter tags
class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTagsAsync = ref.watch(allTagsProvider);
    final selectedTags = ref.watch(tagFilterProvider);

    return allTagsAsync.when(
      loading: () => const SizedBox(height: 50),
      error: (e, st) => const SizedBox.shrink(),
      data: (tags) {
        if (tags.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              final isSelected = selectedTags.contains(tag.name);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
                  label: Text(tag.name),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    final currentFilter = ref.read(tagFilterProvider.notifier);
                    if (selected) {
                      currentFilter.state = {...currentFilter.state, tag.name};
                    } else {
                      currentFilter.state = {...currentFilter.state}..remove(tag.name);
                    }
                  },
                  backgroundColor: const Color(0xFF3F3B4A),
                  selectedColor: const Color(0xFFE91E63),
                  labelStyle: const TextStyle(color: Colors.white),
                  checkmarkColor: Colors.white,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// The widget for displaying a single memory in the timeline
class TimelineMemoryCard extends StatelessWidget {
  final Memory memory;
  const TimelineMemoryCard({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = memory.photoPaths.isNotEmpty;
    final tags = memory.tags.toList();

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
                    const SizedBox(height: 8),
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: tags.map((tag) => Chip(
                          label: Text(tag.name),
                          backgroundColor: const Color(0xFF8E44AD),
                          labelStyle: const TextStyle(color: Colors.white, fontSize: 10),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        )).toList(),
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
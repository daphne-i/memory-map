import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:latlong2/latlong.dart';
import 'package:memories_map/core/provider/database_provider.dart';

import '../models/location.dart';
import '../models/memory.dart';
import '../models/tag.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) {
    throw Exception('Isar instance is not available');
  }
  return MemoryRepository(isar);
});

class MemoryRepository {
  final Isar _isar;

  MemoryRepository(this._isar);

  Stream<List<Memory>> watchAllMemories() {
    return _isar.memories.where().watch(fireImmediately: true);
  }

  Future<void> addMemory({
    required String title,
    required String notes,
    required DateTime date,
    required LatLng latLng,
    required List<String> photoPaths,
    required List<String> tags,
  }) async {
    final newMemory = Memory()
      ..title = title
      ..notes = notes
      ..date = date
      ..photoPaths = photoPaths;

    final newLocation = Location()
      ..latitude = latLng.latitude
      ..longitude = latLng.longitude;

    await _isar.writeTxn(() async {
      await _isar.locations.put(newLocation);
      await _isar.memories.put(newMemory);

      newMemory.location.value = newLocation;
      await newMemory.location.save();

      for (final tagName in tags) {
        Tag? existingTag = await _isar.tags.where().nameEqualTo(tagName).findFirst();

        if (existingTag == null) {
          final newTag = Tag()..name = tagName;
          await _isar.tags.put(newTag);
          existingTag = newTag;
        }

        newMemory.tags.add(existingTag);
      }
      await newMemory.tags.save();
    });
  }


  // --- FINAL CORRECTED FILTERING METHOD ---
  Stream<List<Memory>> watchFilteredMemoriesByDate(Set<String> tagsToFilter) {
    if (tagsToFilter.isEmpty) {
      return _isar.memories.where().sortByDateDesc().watch(fireImmediately: true);
    }

    // Use the type-safe `anyOf` composite filter to create the OR query.
    return _isar.memories
        .filter()
        .anyOf(tagsToFilter, (q, tagName) {
      // For each tag name in the set, this creates a condition:
      // "tags link contains a tag where the name equals tagName"
      return q.tags((tag) => tag.nameEqualTo(tagName));
    })
        .sortByDateDesc() // Now we can sort the filtered results
        .watch(fireImmediately: true);
  }
  // --- END OF CORRECTION ---

  Stream<List<Tag>> watchAllTags() {
    return _isar.tags.where().sortByName().watch(fireImmediately: true);
  }
}
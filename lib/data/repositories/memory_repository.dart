import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart'; // Make sure this import is here
import 'package:latlong2/latlong.dart';
import 'package:memories_map/core/provider/database_provider.dart';

import '../models/location.dart';
import '../models/memory.dart';

// This provider creates an instance of our repository.
// It watches the main isarProvider to get the database instance.
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

  // A method to get a continuous stream of all memories.
  // The UI will listen to this to update automatically.
  Stream<List<Memory>> watchAllMemories() {
    // This is where the error was happening.
    // The .memories getter is an extension on the Isar class.
    return _isar.memories.where().watch(fireImmediately: true);
  }

  Future<void> addMemory({
    required String title,
    required String notes,
    required DateTime date,
    required LatLng latLng,
  }) async {
    final newMemory = Memory()
      ..title = title
      ..notes = notes
      ..date = date;

    final newLocation = Location()
      ..latitude = latLng.latitude
      ..longitude = latLng.longitude;

    await _isar.writeTxn(() async {
      // Save the location first
      await _isar.locations.put(newLocation);

      // Save the memory
      await _isar.memories.put(newMemory);

      // Link the location to the memory
      newMemory.location.value = newLocation;
      await newMemory.location.save();
    });
  }
}
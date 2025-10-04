import 'package:flutter_riverpod/flutter_riverpod.dart';

// This provider holds the set of currently selected tag names for filtering.
// Using a Set is efficient for adding/removing items.
final tagFilterProvider = StateProvider<Set<String>>((ref) => {});
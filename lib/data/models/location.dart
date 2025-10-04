import 'package:isar/isar.dart';

// This line is crucial. It tells Dart that 'location.g.dart' is part of this file.
part 'location.g.dart';

@collection
class Location {
  Id id = Isar.autoIncrement;

  late double latitude;
  late double longitude;
}
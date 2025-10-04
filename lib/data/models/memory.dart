import 'package:isar/isar.dart';
import 'location.dart';
import 'tag.dart';

part 'memory.g.dart';

@Collection(accessor: 'memories') // Manually specify the correct plural name
class Memory {
  Id id = Isar.autoIncrement;

  late String title;
  late String notes;
  late DateTime date;

  List<String> photoPaths = [];

  final location = IsarLink<Location>();
  final tags = IsarLinks<Tag>();
}
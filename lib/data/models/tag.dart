import 'package:isar/isar.dart';

// This line is crucial.
part 'tag.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  late String name;
}
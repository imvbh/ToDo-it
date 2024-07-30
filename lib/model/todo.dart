import 'package:isar/isar.dart';

part 'todo.g.dart';

@collection
class ToDo {
  Id id = Isar.autoIncrement;
  late String todoText;
  bool isDone = false;
  DateTime? deadline;

  ToDo({
    required this.todoText,
    this.isDone = false,
    this.deadline,
  });
}

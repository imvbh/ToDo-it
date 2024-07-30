import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'todo.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';

class ToDoDatabase extends ChangeNotifier {
  static late Isar isar;

  Map<String, List<ToDo>> get groupedTodos {
    Map<String, List<ToDo>> grouped = {
      'Past': [],
      'Today': [],
      'Tomorrow': [],
      'No Deadline': [],
      'Completed': [],
    };

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.add(const Duration(days: 1));

    for (var todo in _filteredTodos) {
      if (todo.isDone) {
        grouped['Completed']!.add(todo);
      } else if (todo.deadline != null) {
        DateTime deadlineDate = DateTime(
            todo.deadline!.year, todo.deadline!.month, todo.deadline!.day);
        if (deadlineDate.isBefore(today)) {
          grouped['Past']!.add(todo);
        } else if (deadlineDate.isAtSameMomentAs(today)) {
          grouped['Today']!.add(todo);
        } else if (deadlineDate.isAtSameMomentAs(tomorrow)) {
          grouped['Tomorrow']!.add(todo);
        } else {
          String futureKey = DateFormat('d MMMM yyyy').format(deadlineDate);
          if (!grouped.containsKey(futureKey)) {
            grouped[futureKey] = [];
          }
          grouped[futureKey]!.add(todo);
        }
      } else {
        grouped['No Deadline']!.add(todo);
      }
    }

    return grouped;
  }

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ToDoSchema], directory: dir.path);
  }

  final List<ToDo> _todos = [];
  List<ToDo> get todos => _todos;
  final List<ToDo> _filteredTodos = [];
  List<ToDo> get filteredTodos => _filteredTodos;

  Future<void> addTodo(String text, DateTime? deadline) async {
    final todo = ToDo(
      todoText: text,
      deadline: deadline,
    );
    await isar.writeTxn(() => isar.toDos.put(todo));
    await fetchTodos();
    if (deadline != null) {
      scheduleNotification(todo);
    }
  }

  Future<void> fetchTodos() async {
    final fetchedTodos = await isar.toDos.where().findAll();

    // Clear and update the todos list
    _todos.clear();
    _todos.addAll(fetchedTodos);

    // Sort todos by deadline
    _todos.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });

    _filteredTodos.clear();
    _filteredTodos.addAll(_todos);

    notifyListeners();
  }

  void filterTodos(String query) {
    if (query.isEmpty) {
      _filteredTodos.clear();
      _filteredTodos.addAll(_todos);
    } else {
      _filteredTodos.clear();
      _filteredTodos.addAll(_todos.where(
          (todo) => todo.todoText.toLowerCase().contains(query.toLowerCase())));
    }
    notifyListeners();
  }

  Future<void> updateTodoStatus(ToDo todo) async {
    todo.isDone = !todo.isDone;
    await isar.writeTxn(() => isar.toDos.put(todo));
    await fetchTodos();
  }

  Future<void> deleteTodoById(int id) async {
    await isar.writeTxn(() => isar.toDos.delete(id));
    await fetchTodos();
  }

  Future<void> clearCompletedTodos() async {
    final completedTodos = _todos.where((todo) => todo.isDone).toList();
    await isar.writeTxn(() async {
      for (var todo in completedTodos) {
        await isar.toDos.delete(todo.id);
      }
    });
    await fetchTodos();
  }

  void scheduleNotification(ToDo todo) async {
    if (todo.deadline != null) {
      final scheduledTime = tz.TZDateTime.from(
          todo.deadline!.subtract(const Duration(days: 1)), tz.local);

      if (scheduledTime.isAfter(DateTime.now())) {
        try {
          await flutterLocalNotificationsPlugin.zonedSchedule(
            todo.id,
            'ToDo Reminder',
            'You have a task pending for tomorrow: ${todo.todoText}',
            scheduledTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'defualt_channel_id',
                'Default channel name',
                channelDescription: 'Notifications for general alerts.',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
          print(
              "Notification scheduled for task: ${todo.todoText} at $scheduledTime");
        } catch (e) {
          print("Error scheduling notification: $e");
        }
      }
    }
  }
}

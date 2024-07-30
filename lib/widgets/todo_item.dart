import 'package:flutter/material.dart';
import '../model/todo.dart';
import 'package:intl/intl.dart';

class ToDoItem extends StatelessWidget {
  final ToDo todo;
  final Function(ToDo) onToDoChange;
  final Function(int) onDeleteItem;

  const ToDoItem({
    Key? key,
    required this.todo,
    required this.onToDoChange,
    required this.onDeleteItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.add(const Duration(days: 1));
    DateTime yesterday = today.subtract(const Duration(days: 1));

    String formatDeadline(DateTime? deadline) {
      if (deadline == null) return "No due";
      DateTime deadlineDate =
          DateTime(deadline.year, deadline.month, deadline.day);
      if (deadlineDate == today) return "Today";
      if (deadlineDate == tomorrow) return "Tomorrow";
      if (deadlineDate == yesterday) return "Yesterday";
      return DateFormat('d MMMM').format(deadline.toLocal());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Stack(children: [
        ListTile(
          onTap: () {
            onToDoChange(todo);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 0,
          ),
          tileColor: Theme.of(context).colorScheme.background,
          leading: (todo.deadline != null && isPastDeadline(todo.deadline!))||todo.isDone==true
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 40,
                  width: 65,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                      top: 8.0,
                    ),
                    child: Text(
                      formatDeadline(todo.deadline),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todo.todoText,
                style: TextStyle(
                  fontSize: todo.isDone ? 16 : 20,
                  fontWeight: todo.isDone ? FontWeight.normal : FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
          trailing: todo.isDone == true
              ? Icon(Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.inversePrimary,                
              )
              : Icon(
                  Icons.circle_outlined,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
        ),
        if (todo.isDone)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right:56),
                child: Divider(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  thickness: 2,
                ),
              ),
            ),
          ),
      ]),
    );
  }

  bool isPastDeadline(DateTime deadline) {
    final now = DateTime.now();
    return deadline.isBefore(DateTime(now.year, now.month, now.day));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../themes/theme_provider.dart';
import '../widgets/todo_item.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/todo_database.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _todoController = TextEditingController();
  final _focusNode = FocusNode();
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    Provider.of<ToDoDatabase>(context, listen: false).fetchTodos();
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose the focus node
    _todoController.dispose();
    super.dispose();
  }

  void _clearCompletedTodos(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text(
              'Are you sure you want to clear all the completed todos?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Provider.of<ToDoDatabase>(context, listen: false)
                    .clearCompletedTodos();
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todoDatabase = Provider.of<ToDoDatabase>(context);
    final groupedTodos = todoDatabase.groupedTodos;
    final hasTodos = groupedTodos.values.any((list) => list.isNotEmpty);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: searchBox(),
            ),
            Expanded(
              child: hasTodos
                  ? ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 15,
                      ),
                      children: groupedTodos.keys
                          .where((key) => groupedTodos[key]!.isNotEmpty)
                          .map((key) {
                        final todosForKey = groupedTodos[key]!;
                        final itemCount = todosForKey.length;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: ExpansionTile(
                            iconColor:
                                Theme.of(context).colorScheme.inversePrimary,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$key ($itemCount)',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                ),
                                if (key == 'Completed')
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.redAccent,
                                    onPressed: () =>
                                        _clearCompletedTodos(context),
                                  ),
                              ],
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            children: groupedTodos[key]!.map((todo) {
                              return ToDoItem(
                                todo: todo,
                                onDeleteItem: (id) =>
                                    todoDatabase.deleteTodoById(id),
                                onToDoChange: (todo) =>
                                    todoDatabase.updateTodoStatus(todo),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    )
                  : Center(
                      child: Text(
                      "Add ToDos with the '+' button",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 20),
                    )),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Made with ❤️ by imvbh',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoBottomSheet,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }

  void _showAddTodoBottomSheet() {
    _todoController.clear();
    DateTime? selectedDate;
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20.0,
              left: 20.0,
              right: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Add new ToDo',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
              TextField(
                cursorColor: Theme.of(context).colorScheme.inversePrimary,
                controller: _todoController,
                decoration: const InputDecoration(
                  hintText: 'Enter ToDo...',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.calendar_month_outlined),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Theme.of(context)
                                    .colorScheme
                                    .background, // header background color
                                onPrimary: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary, // header text color
                                onSurface: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary, // body text color
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary, // button text color
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  Text(
                    selectedDate == null
                        ? ''
                        : 'Deadline: ${DateFormat('d MMMM yyyy').format(selectedDate!.toLocal())}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<ToDoDatabase>(context, listen: false).addTodo(
                        _todoController.text,
                        selectedDate,
                      );
                      Navigator.of(context).pop();
                      _todoController.clear();
                    },
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        border: Border.all(
            color: Theme.of(context).colorScheme.inversePrimary, width: 1.0),
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.inversePrimary,
        onChanged: (value) {
          Provider.of<ToDoDatabase>(context, listen: false).filterTodos(value);
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.inversePrimary,
            size: 20,
          ),
          prefixIconConstraints: const BoxConstraints(
            maxHeight: 20,
            minWidth: 25,
          ),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: const TextStyle(color: tdGrey),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("ToDo-it",
                style: GoogleFonts.rubik(
                  fontSize: 48,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                )),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isPressed = !isPressed;
              });
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            icon: isPressed
                ? const Icon(Icons.dark_mode)
                : const Icon(Icons.light_mode),
            color: Theme.of(context).colorScheme.inversePrimary,
            iconSize: 30,
          ),
        ],
      ),
    );
  }
}

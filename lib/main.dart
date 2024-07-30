import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_basic_1/themes/theme_provider.dart';
import 'package:todo_basic_1/screens/home.dart';
import 'package:todo_basic_1/model/todo_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ToDoDatabase.initialize();

  // Initialize the timezone
  tz.initializeTimeZones();

  // Request permissions and initialize notifications
  await requestPermissionsAndInitializeNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ToDoDatabase()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> requestPermissionsAndInitializeNotifications() async {
  if (await Permission.scheduleExactAlarm.request().isGranted) {
    // Initialize the notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  } else {
    // Handle the case when the permission is not granted
    print("Permission not granted");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      home: const Home(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}

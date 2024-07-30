import 'package:flutter/material.dart';

// light mode
ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light (
    background: Color.fromARGB(255, 240, 240, 240),
    primary: Color.fromARGB(255, 250, 250, 250),
    secondary: Color.fromARGB(255, 250, 250, 250),
    inversePrimary: Color.fromARGB(255, 79, 79, 79),
  ), // ColorScheme. light
); // ThemeData

// dark mode
ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: const Color.fromARGB(255, 13, 13, 13),
    primary: Colors.grey.shade900,
    secondary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade300,
  ), // ColorScheme.dark
); // ThemeData
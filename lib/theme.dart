import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue, // Primary color
    brightness: Brightness.light, // Light mode
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurple, // AppBar color
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white), // AppBar icon color
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 16,  fontWeight: FontWeight.w500,color: Colors.black87),
      bodySmall: TextStyle(fontSize: 16, color: Colors.black87),
      titleMedium :TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      titleSmall :TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      titleLarge :TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),


    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark, // Dark mode
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black, // Dark Blue
      // AppBar color
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 16,fontWeight: FontWeight.w500, color: Colors.white70),
      bodySmall: TextStyle(fontSize: 16, color: Colors.grey),
        titleMedium :TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      titleSmall :TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
      titleLarge :TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),

    ),



  );
}
class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider({bool isDarkMode = true})
      : _themeData =
  isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;

  ThemeData get themeData => _themeData;

  void toggleTheme() {
    _themeData = (_themeData.brightness == Brightness.dark)
        ? AppThemes.lightTheme
        : AppThemes.darkTheme;
    notifyListeners();
  }
}

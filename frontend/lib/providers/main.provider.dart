import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProvider with ChangeNotifier {
  bool darkMode;
  MainProvider({
    this.darkMode = true,
  });

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_theme', !darkMode);
    darkMode = !darkMode;
    notifyListeners();
  }
}

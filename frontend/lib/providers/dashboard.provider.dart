import 'package:flutter/material.dart';

class DashBoardProvider with ChangeNotifier {
  bool drawerOpen;
  DashBoardProvider({
    this.drawerOpen = false,
  });

  void templateFun() {
    notifyListeners();
  }
}

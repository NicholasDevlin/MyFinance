import 'package:flutter/material.dart';

class DrawerProvider with ChangeNotifier {
  bool _isDrawerOpen = false;

  bool get isDrawerOpen => _isDrawerOpen;

  void setDrawerOpen(bool isOpen) {
    if (_isDrawerOpen != isOpen) {
      _isDrawerOpen = isOpen;
      notifyListeners();
    }
  }

  void openDrawer() => setDrawerOpen(true);
  void closeDrawer() => setDrawerOpen(false);
}
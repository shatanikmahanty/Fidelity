import 'package:flutter/material.dart';

class MenuProvider extends ChangeNotifier {
  int _currentPage = 0;

  bool isMenuOpen = false;

  int get currentPage => _currentPage;

  void menuOpened(bool action) {
    isMenuOpen = action;

    notifyListeners();
  }

  void updateCurrentPage(int index) {
    if (index != currentPage) {
      _currentPage = index;
      notifyListeners();
    }
  }
}

import 'package:fidelity/screens/assistant_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'blocs/menu_provider.dart';

class DrawerPages extends StatefulWidget {
  @override
  _DrawerPagesState createState() => _DrawerPagesState();
}

class _DrawerPagesState extends State<DrawerPages> {
  @override
  Widget build(BuildContext context) {
    final int _currentPage =
        context.select<MenuProvider, int>((provider) => provider.currentPage);

    switch (_currentPage) {
      case 0:
        return HomeScreen();
      default:
        return Scaffold(
          body: Container(
            child: Text(
              "Coming Soon!",
              style: TextStyle(

              ),
            ),
          ),
        );
    }
  }
}

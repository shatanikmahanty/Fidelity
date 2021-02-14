import 'package:fidelity/drawer_page_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';

import 'blocs/menu_provider.dart';
import 'screens/menu_page.dart';

class Home extends StatefulWidget {
  static List<MenuItem> menuItems = [
    MenuItem("Assistant", Icons.payment, 0),
    MenuItem("Read Aloud", Icons.record_voice_over_outlined, 1),
    MenuItem("Help", Icons.help, 2),
    MenuItem("Settings", Icons.settings, 3),
  ];

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _drawerController = ZoomDrawerController();

  String lastWords = '', lastStatus;
  String lastError;

  bool isDeviceConnected = true;

  FlutterTts flutterTts = FlutterTts();

  SpeechToText speech = SpeechToText();


  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _drawerController,
      menuScreen: MenuScreen(
        Home.menuItems,
        callback: _updatePage,
        current: _currentPage,
      ),
      mainScreen: MainScreen(),
      borderRadius: 24.0,
      showShadow: true,
      angle: 0,
      slideWidth: MediaQuery.of(context).size.width *
          (MediaQuery.of(context).size.width > 600 ? 0.25 : 0.55),
      openCurve: Curves.easeInCirc,
      closeCurve: Curves.easeOutCirc,
    );
  }

  void _updatePage(index) {
    Provider.of<MenuProvider>(context, listen: false).updateCurrentPage(index);
    Provider.of<MenuProvider>(context, listen: false).menuOpened(false);
    _drawerController.toggle();
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {

    MenuProvider mp = Provider.of<MenuProvider>(context);

    return ValueListenableBuilder<DrawerState>(
      valueListenable: ZoomDrawer.of(context).stateNotifier,
      builder: (context, state, child) {
        return AbsorbPointer(
          absorbing: state != DrawerState.closed,
          child: child,
        );
      },
      child: GestureDetector(
        child: DrawerPages(),
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            ZoomDrawer.of(context).toggle();
            mp.menuOpened(true);
          }
        },
      ),
    );
  }
}

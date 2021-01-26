import 'package:fidelity/drawer_page_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';

import 'blocs/menu_provider.dart';
import 'menu_page.dart';

class Home extends StatefulWidget {
  static List<MenuItem> mainMenu = [
    MenuItem("payment", Icons.payment, 0),
    MenuItem("promos", Icons.card_giftcard, 1),
    MenuItem("notifications", Icons.notifications, 2),
    MenuItem("help", Icons.help, 3),
    MenuItem("about_us", Icons.info_outline, 4),
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
        Home.mainMenu,
        callback: _updatePage,
        current: _currentPage,
      ),
      mainScreen: MainScreen(),
      borderRadius: 24.0,
      showShadow: true,
      angle: 0,
      slideWidth: MediaQuery.of(context).size.width *
          (ZoomDrawer.isRTL() ? 0.45 : 0.55),
      openCurve: Curves.easeInCirc,
      closeCurve: Curves.easeOutCirc,
    );
  }

  void _updatePage(index) {
    Provider.of<MenuProvider>(context, listen: false).updateCurrentPage(index);
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

    final rtl = ZoomDrawer.isRTL();
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

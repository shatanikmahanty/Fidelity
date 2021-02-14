import 'package:fidelity/blocs/menu_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';

class DocReadScreen extends StatefulWidget {
  @override
  _DocReadScreenState createState() => _DocReadScreenState();
}

class _DocReadScreenState extends State<DocReadScreen> {

  FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {

    MenuProvider mp = Provider.of<MenuProvider>(context);

    final Shader linearGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xffbf953f),
          Color(0xfffcf6ba),
          Color(0xffb38728),
          Color(0xfffbf5B7),
          Color(0xffAA771C)
        ]).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    return Scaffold(
      backgroundColor: Color(0xff222225),
      body: Container(),
      appBar: AppBar(
          brightness: Brightness.dark,
          elevation: 0,
          centerTitle: true,
          leading: mp.isMenuOpen
              ? null
              : IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  ZoomDrawer.of(context).toggle();
                  mp.menuOpened(true);
                },
              ),
          title: Text(
            "Fidelity",
            style: kIsWeb
                ? TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xffF7EF8A),
                fontFamily: "Potta",
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(4, 4),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ])
                : TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                foreground: Paint()..shader = linearGradient,
                fontFamily: "Potta",
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(4, 4),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ]),
          ),
          backgroundColor: Color(0xff2F2F31)),
    );
  }
}

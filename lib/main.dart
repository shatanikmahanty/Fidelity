import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en'),
      ],
      title: 'Fidelity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MaterialColor(0xff171717, {
          50: Color(0xff171717),
          100: Color(0xff171717),
          200: Color(0xff171717),
          300: Color(0xff171717),
          400: Color(0xff171717),
          500: Color(0xff171717),
          600: Color(0xff171717),
          700: Color(0xff171717),
          800: Color(0xff171717),
          900: Color(0xff171717),
        }),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

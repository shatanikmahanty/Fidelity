import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var shortestSide;
  var height;
  var width;

  String lastWords = '', lastStatus;
  String lastError;

  bool isDeviceConnected = true;

  SpeechToText speech = SpeechToText();

  final Shader linearGradient = LinearGradient(
      stops: [0.25, 0.50, 0.75, 1],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xffAE8625),
        Color(0xffF7EF8A),
        Color(0xffD2AC47),
        Color(0xffEDC967),
      ]).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = '${result.recognizedWords}';
    });

    if (!speech.isListening) print(lastWords);
  }

  void errorListener(SpeechRecognitionError error) {
    // print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    // print(
    // 'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = '$status';
    });
  }

  @override
  Widget build(BuildContext context) {
    shortestSide = MediaQuery.of(context).size.shortestSide;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xff2F2F31),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              speech.isListening
                  ? Column(
                      children: [
                        JumpingText(
                          "Listening...",
                          style: TextStyle(
                            fontFamily: "Potta",
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          lastWords,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      lastWords,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            child: BottomAppBar(
              elevation: 10,
              color: Colors.white30,
              child: Container(
                height: 50,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.help_outline_sharp,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.help_outline_sharp,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              shape: CircularNotchedRectangle(),
              notchMargin: 5,
            ),
          )),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () async {
            bool available = false;

            setState(() {
              lastWords = '';
            });

            if (!speech.isAvailable)
              available = await speech.initialize(
                  onStatus: statusListener, onError: errorListener);
            else {
              available = true;
            }

            if (available) {
              speech.listen(
                partialResults: true,
                cancelOnError: true,
                onResult: resultListener,
              );
            } else {
              print("The user has denied the use of speech recognition.");
            }
          },
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return RadialGradient(
                center: Alignment.topLeft,
                radius: 0.5,
                colors: <Color>[
                  Colors.greenAccent[200],
                  Colors.blueAccent[200],
                  Colors.red
                ],
                tileMode: TileMode.repeated,
              ).createShader(bounds);
            },
            child: Icon(
              Icons.settings_voice,
              size: 40,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
          brightness: Brightness.dark,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Fidelity",
            style: TextStyle(
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

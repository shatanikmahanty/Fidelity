import 'package:contacts_service/contacts_service.dart';
import 'package:fidelity/blocs/assitant_bloc.dart';
import 'package:fidelity/blocs/menu_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String lastWords = '', lastStatus;
  String lastError;

  SpeechToText speech = SpeechToText();

  FlutterTts flutterTts = FlutterTts();

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

  void resultListener(SpeechRecognitionResult result, AssistantBloc ab) async {
    setState(() {
      lastWords = '${result.recognizedWords}';
    });

    if (!speech.isListening) {
      await speech.stop();
      ab.updateListeningStatus();
      print(lastWords);
      lastWords = lastWords.toLowerCase();

      if (await flutterTts.isLanguageAvailable("en-IN"))
        await flutterTts.setLanguage("en-IN");

      await flutterTts.setSpeechRate(1);
      await flutterTts.setVolume(0.9);
      await flutterTts.setPitch(1);
      await flutterTts
          .setVoice({"name": "en - us - x - tpf - local", "locale": "en - US"});
      await flutterTts.awaitSpeakCompletion(true);

      if (lastWords.startsWith("search")) {
        String command = lastWords.replaceAll("search", "");
        await flutterTts
            .speak("Asking google to perform a search for" + command);
        await ab.performSearch(command);
      } else if (lastWords.startsWith("play")) {
        String command = lastWords.replaceAll("play", "");
        await flutterTts.speak("Playing $command");
        ab.playSong(command);
      } else if (lastWords.startsWith("set alarm for")) {
        String command =
            lastWords.replaceAll("set alarm for", "").replaceAll(":", "");
        print(command);
        ab.setAlarm(
          hour: int.parse(command.length > 3
              ? command.substring(0, 2)
              : command.substring(0, 1)),
          minute: int.parse(
              command.length > 3 ? command.substring(2) : command.substring(1)),
        );
      } else if (lastWords.startsWith("open")) {
        String command = lastWords.replaceAll(" ", "");
        if (command.contains("openwhatsapp") && command.contains("send")) {
          String phoneNumber = command.replaceAll(new RegExp(r'[a-zA-Z ]'), '');
          await flutterTts.speak("Sending WhatsApp Message");
          FlutterOpenWhatsapp.sendSingleMessage(phoneNumber, "Hello");
        } else {
          String commandAppName = lastWords.replaceAll("open", "").trim();
          List<AppInfo> apps = await InstalledApps.getInstalledApps();

          for (AppInfo app in apps) {
            print(app.name.toLowerCase());
            if (app.name.toLowerCase().replaceAll(" ", "") == commandAppName) {
              await flutterTts.speak("opening" + commandAppName);
              InstalledApps.startApp(app.packageName);
            }
          }
        }
      } else if (lastWords.contains("call")) {
        List<Contact> results = [];

        String requiredCallRecipient =
            lastWords.replaceAll("call", "").replaceAll(" ", "");

        if (await Permission.contacts.request().isGranted) {
          Iterable<Contact> allContacts = await ContactsService.getContacts();
          if (allContacts.length == 0) {
            await flutterTts
                .speak("I could not find any contacts on your phone");
          } else if (allContacts.length == 1) {
            if (allContacts.first.displayName
                .toLowerCase()
                .trim()
                .startsWith(requiredCallRecipient)) {
              ab.callNumber(allContacts.first.phones.first.toString());
            }
          } else {
            allContacts.forEach((contact) {
              if (contact.displayName
                  .toLowerCase()
                  .trim()
                  .startsWith(requiredCallRecipient)) {
                results.add(contact);
              }
            });

            if (results.length == 1) {
              ab.callNumber(results.first.phones.first.value);
            } else {
              await flutterTts.speak(
                  "I found multiple contacts for $requiredCallRecipient. I am still learning how to distinguish multiple contacts");
            }
          }
        } else {
          await flutterTts
              .speak("I could not make the call due to missing permission");
        }
      } else if (lastWords.contains("hello") ||
          lastWords.contains("hi") ||
          lastWords.contains("hey there")) {
        await flutterTts.speak("Hello. Hope you are having a great day");
      } else {
        await flutterTts.speak(
            "I didn't understand. Do you want me to do a google search?");
        speech.listen(
          listenFor: Duration(seconds: 10),
          partialResults: false,
          cancelOnError: true,
          onResult: resultListenerConfirmationGoogleSearch,
        );
      }
    }
  }

  void resultListenerConfirmationGoogleSearch(
      SpeechRecognitionResult result) async {
    String confirmationWords = "No";
    confirmationWords = '${result.recognizedWords}';

    confirmationWords = confirmationWords.toLowerCase().replaceAll(" ", "");

    if (confirmationWords.contains("yes") ||
        confirmationWords.contains("yup") ||
        confirmationWords.contains("goahead") ||
        confirmationWords.contains("sure")) {
      speech.stop();
      launch("https://www.google.com/search?q=" + lastWords);
    }
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

  getVoices() async {
    print((await flutterTts.getVoices).toString());
  }

  @override
  Widget build(BuildContext context) {

    AssistantBloc ab = Provider.of<AssistantBloc>(context);
    MenuProvider mp = Provider.of<MenuProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xff222225),
      body: Column(
        children: [
          if (ab.isWorking)
            Align(
              alignment: Alignment.topLeft,
              child: LinearProgressIndicator(
                backgroundColor: Colors.black,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            ),
          if (ab.isListening)
            Align(
              alignment: Alignment.topLeft,
              child: LinearProgressIndicator(
                backgroundColor: Colors.blue,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            ),
          Spacer(),
          Center(
            child: speech.isListening
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
          ),
          Spacer(),
        ],
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
            // getVoices();
            bool available = false;

            ab.updateListeningStatus();

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
                listenFor: Duration(seconds: 10),
                partialResults: true,
                cancelOnError: true,
                onResult: (SpeechRecognitionResult result) {
                  resultListener(result, ab);
                },
                onSoundLevelChange: (double value) {
                  // TODO Update UI accordingly
                },
              );
            } else {
              print("The user has denied the use of speech recognition.");
            }
          },
          child: kIsWeb
              ? Icon(
                  Icons.settings_voice,
                  color: Colors.greenAccent[200],
                  size: 40,
                )
              : ShaderMask(
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

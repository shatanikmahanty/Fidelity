import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

class AssistantBloc extends ChangeNotifier {
  static const platform = const MethodChannel('com.shatanik.fidelity');

  bool _isWorking = false;
  bool _isListening = false;

  bool get isListening => _isListening;

  bool get isWorking => _isWorking;

  updateListeningStatus() {
    _isListening = !_isListening;
    notifyListeners();
  }

  Future<void> performSearch(String command) async {
    launch("https://www.google.com/search?q=" + command);
  }

  Future<void> playSong(String songName) async {
    await platform.invokeMethod('playMusic', {"song": songName});
  }

  Future<bool> setAlarm({int hour = 12, int minute = 0}) async {
    bool ok = await platform
        .invokeMethod('setAlarm', {"hour": hour, "minute": minute});
    return ok;
  }

  void callNumber(String phone) async {
    await FlutterPhoneDirectCaller.callNumber(phone);
  }
}

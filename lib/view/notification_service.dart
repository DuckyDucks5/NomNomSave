import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_se/main.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> setupFCM(String userId) async {
    try{
      await _fcm.requestPermission();

      String? fcmtoken = await _fcm.getToken();
      print("FCM Token: $fcmtoken");

      if(fcmtoken != null){
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/save-fcm-token'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({"fcmToken": fcmtoken}),
        );

        if(response.statusCode == 200) {
          print("success");
        }
        else{
          print("error: ${response.body}");
        }
      }
    }
    catch(e){
      print('Error on FCM setup: $e');
    }
  }
}

class FirebaseApi{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();

    final fcmToken = await _firebaseMessaging.getToken();
    print('Token (FirebaseApi): $fcmToken');

    initPushNotification();
  }

  void initPushNotification() {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

   
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      print('Received a message in foreground: ${message.messageId}');
    });
  }

  void handleMessage(RemoteMessage? message){
    if (message == null) return;

    navigatorKey.currentState?.pushNamed(
      '/notification_screen',
      arguments: message,
    );
  }
}

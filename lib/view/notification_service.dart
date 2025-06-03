import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_se/main.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) {
      return;
    }
    const initSettingsAndroid = AndroidInitializationSettings('notif_icon');

    const initSettings = InitializationSettings(android: initSettingsAndroid);

    await notificationPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'new_channel_id',
        'Updated daily notification',
        channelDescription: 'daily notif channel',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        ticker: 'ticker',
      ),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return notificationPlugin.show(id, title, body, notificationDetails());
  }

  Future<void> setupFCM(String userId) async {
    try {
      await _fcm.requestPermission();

      String? fcmtoken = await _fcm.getToken();
      print("FCM Token: $fcmtoken");

      if (fcmtoken != null) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        final response = await http.post(
          Uri.parse(
            'https://nomnomsave-be-se-production.up.railway.app/save-fcm-token',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({"fcmToken": fcmtoken}),
        );

        if (response.statusCode == 200) {
          print("success");
        } else {
          print("error: ${response.body}");
        }
      }
    } catch (e) {
      print('Error on FCM setup: $e');
    }
  }
}

class FirebaseApi {
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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Received a message in foreground: ${message.messageId}');

      final notification = message.notification;
      if (notification != null) {
        final android = notification.android;
        if (android != null) {
          await NotificationService().showNotification(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
          );
        }
      }
    });
  }

  void handleMessage(RemoteMessage? message) async {
    if (message == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getInt('UserID');
    final loginStatus = prefs.getBool('isLoggedIn');

    if (token == null || loginStatus == false) {
      navigatorKey.currentState?.pushNamed('/');
    }
    else{
       navigatorKey.currentState?.pushNamed('/home', arguments: message);
    }
   
  }
}

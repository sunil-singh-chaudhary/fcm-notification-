// ignore_for_file: file_names

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  final localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> onSelectNotification(String payload) async {
    Map<dynamic, dynamic> messageData, body;
    try {
      messageData = json.decode(payload);
      body = jsonDecode(messageData['body']);
      debugPrint('notification click body $body');
      debugPrint('notification click type ${body['notificationType']}');
      debugPrint('notification key 1 ${body['key1']}');
      debugPrint('notification key2 ${body['key2']}');
    } catch (e) {
      debugPrint(
        'Exception in onSelectNotification main.dart:- ${e.toString()}',
      );
    }
  }

  Future<void> foregroundNotification(RemoteMessage payload) async {
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      defaultPresentBadge: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
      defaultPresentSound: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        debugPrint("object notification call");
        return;
      },
    );
    AndroidInitializationSettings android =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initialSetting = InitializationSettings(
        android: android, iOS: initializationSettingsDarwin);
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initialSetting,
        onDidReceiveNotificationResponse: (_) {
      NotificationHandler().onSelectNotification(json.encode(payload.data));
    });
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'Atroway local notifications',
      'High Importance Notifications for Atroway',
      importance: Importance.high,
    );

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      importance: Importance.max,
      priority: Priority.high,
      icon: "@mipmap/ic_launcher",
      playSound: true,
    );
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);
    // global.sp = await SharedPreferences.getInstance();
    // if (global.sp!.getString("currentUser") != null) {

    // }
    await flutterLocalNotificationsPlugin.show(
      0,
      payload.notification!.title,
      payload.notification!.body,
      platformChannelSpecifics,
      payload: json.encode(payload.data.toString()),
    );
  }
}

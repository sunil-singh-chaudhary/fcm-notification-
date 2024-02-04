import 'dart:convert';

import 'package:fcm_sample_messaging/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';
import 'notificationHandler.dart';

String fcmToken =
    'AAAAKtki87c:APA91bHpgHiqOMZ0-6qzIJicso5I5pKVyfbZg4roX5s8C3OZZPy1_dJnNdByaO_l3jGcSe_Ma0fzHpnuulk-_y7ip7fH8cZZ_dFUHXsJlcyq32Vu-Ap96GbElzlRT3eaYIfJoAlR0aSq';

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('handleBackgroundMessage -message: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(
    handleBackgroundMessage, //SHOULD BE TOP LEVEL METHOD ELSE SOME BUGS
  );
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    firebaseNotification();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Homepage(),
    );
  }

  void firebaseNotification() {
    //Sent Notification When App is Running || Background Message is Automatically Sent by Firebase
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // if (message.notification!.title == "For Live Streaming Chat") {

      try {
        if (message.data.isNotEmpty) {
          //  var messageData = json.decode((message.data['body']));
          //messageData['notificationType'] != null
          String title = message.data['title'] ?? 'Default Title';
          String name = message.data['name'] ?? 'Rocky';
          String id = message.data['id'] ?? '00';
          String classes = message.data['class'] ?? '01';

          debugPrint('Received Notification:');
          debugPrint('Title: $title');
          debugPrint('name: $name');
          debugPrint('id: $id');
          debugPrint('classes: $classes');
          Map<String, dynamic>? notibody;
          //String notibody = message.data['body'] ?? {};

          try {
            notibody = jsonDecode(message.data['body']);
          } catch (e) {
            debugPrint('Error parsing body string: ${e.toString()}');
          }

          String key1 = notibody?['key1'] ?? 'defaultValue1';
          debugPrint('new key1 is $key1');
          if (key1 != '') {
            debugPrint('key present dont show notification');

            //! can show a dialog something without showing notifiation for user in background it listen alway
          } else {
            NotificationHandler().foregroundNotification(message);
            await FirebaseMessaging.instance
                .setForegroundNotificationPresentationOptions(
                    alert: true, badge: true, sound: true);
          }
        }
      } catch (e) {
        debugPrint('Exception in onMessage:- ${e.toString()}');
      }
    });
    //Perform On Tap Operation On Notification Click when app is in backgroud Or in Kill Mode
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationHandler().onSelectNotification(json.encode(message.data));
    });
  }
}

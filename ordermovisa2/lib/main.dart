
import 'package:flutter/material.dart';
import 'package:ordermovisa2/pages/home.dart';
import 'package:ordermovisa2/pages/login2.dart';
import 'package:ordermovisa2/pages/dashboard.dart';
import 'package:ordermovisa2/pages/order_taking_page.dart';
import 'package:ordermovisa2/ordering.dart';
import 'package:ordermovisa2/pages/orderwalking.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//=========================
//Global Initialization
const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title// description
    importance: Importance.high,
    playSound: true);

// flutter local notification
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// firebase background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A Background message just showed up :  ${message.messageId}');
}
Future<void> fire_stuff() async{
  // Firebase local notification plugin
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

//Firebase messaging
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}
//=========================

Future<void> main() async {
  // firebase App initialize
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  // WidgetsFlutterBinding.ensureInitialized();
//await Firebase.initializeApp();

  runApp(MaterialApp(
      initialRoute: '/login',
      routes: {
        '/home': (context) => Home(),
        '/login': (context) => login2(),
        '/dashboard': (context) => dash(),
        '/ordering_map': (context) => OrderTrackingPage(),
        '/ordering_map2': (context) => OrderTrackingPage2(),
        '/ordering_map3': (context) => OrderTrackingPage4(),

      }
  ));
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


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


class dash extends StatefulWidget {
  @override
  _DashState createState() => _DashState();
}

class _DashState extends State<dash> {
  late IO.Socket socket;
  String _value = '';
  int _counter = 0;
  int _counter2 = 0;
  Map<String, dynamic> from_pre_page_data = {};
String user_id1 = '';
  //===============================
  // set drivers firebase device access token to database
  void set_firebase_device_token(String userid) async{
    try{
      await Firebase.initializeApp();
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print("token : "+fcmToken.toString());
      print("driverid : "+userid);
      var url = "https://www.site.com/user_firebase_set";
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          //get the drivers working location and get all orders from the drivers province
          'userid': userid,
          'device_token': fcmToken.toString(),
        }),
      );

      if(response.statusCode == 200){
        print("the token was set successfully");
      }
    }catch(e){
      print(e.toString());
    }
  }

  //===========================
  // set socket io token
  void set_socketio_token(String userid,socket_token) async{
    try{
      print("socket io id : "+socket_token);
      var url = "https://www.site.com/user_socketio_set";
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          //get the drivers working location and get all orders from the drivers province
          'userid': userid,
          'socketio_token': socket_token,
        }),
      );

      if(response.statusCode == 200){
        print("the token was set successfully");
      }
    }catch(e){
      print(e.toString());
    }
  }

  void _onClick(String value) => setState(() => _value = value);
//================
  //========================
  // everything notification

  //=========================
  // socket io stuff
  Future<void> initSocket() async {
    try{
      socket = IO.io('https://www.site.com/',<String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      },
      );

      socket.connect();

      socket.onConnect((_) {
        print('Connected: ${socket.id} user id: '+user_id1 );
        set_socketio_token(user_id1,socket.id.toString());
      });

    } catch (e) {
      print(e.toString());
    }
  }
  @override
  void initState()  {

    fire_stuff();
    //getCurrentLocation();
    
    super.initState();

    initSocket();
    //  om message app open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        print("_counter");

        // here we need to get the order details so driver can accept or decline
      //  get_order_for_driver_response( from_pre_page_data["driver_id"].toString() );

        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,

            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.blue,
                playSound: true,
                icon: '@drawable/ic_stat_justwater',
              ),
              iOS: IOSNotificationDetails(
                sound: 'default.wav',
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            )
        );
      }
    });

    //Message for Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new messageopen app event was published');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {

       // get_order_for_driver_response( from_pre_page_data["driver_id"].toString() );

        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title!),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body!)],
                  ),
                ),
              );
            });
      }
    });
  }

  void showNotification() {
    setState(() {
      _counter2++;
    });

    flutterLocalNotificationsPlugin.show(
        0,
        "Testing $_counter2",
        "This is an Flutter Push Notification",
        NotificationDetails(
          android: AndroidNotificationDetails(
              channel.id, channel.name,
              importance: Importance.high,
              color: Colors.blue,
              playSound: true,
              icon: '@drawable/ic_stat_justwater'),
          iOS: IOSNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ));
  }
  //========================
  //==============
  Color mainColor = Color(0xff247BA0);
  @override

  Widget build(BuildContext context) {
    if(_counter == 0) {
      from_pre_page_data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      user_id1 = from_pre_page_data["userid"].toString();
      print("here is user id"+ from_pre_page_data["userid"].toString() );
      //set_firebase_device_token(from_pre_page_data["userid"].toString());
      _counter++;
    }
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Image.asset(
                'assets/bloommlogo.png',
                fit: BoxFit.fitWidth,
                height: 100,
                width: 100,
              ),
            ),
            Container(
                width: 100,
                child: Text('Moviza', style: TextStyle(fontSize: 25) )
            ),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
        // persistentFooterButtons: <Widget>[
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: <Widget>[
        //       Column(
        //         children: <Widget>[
        //           Stack(
        //             children: <Widget>[
        //               Container(
        //                 height: 90.0,
        //                 width: 375.0,
        //                 decoration: BoxDecoration(
        //                   color: Colors.grey,
        //                 ),
        //               ),
        //               Container(
        //                 height: 40.0,
        //                 width: 375.0,
        //                 decoration: BoxDecoration(
        //                   color: Colors.grey[200],
        //                 ),
        //               ),
        //               Container(
        //                 height: 90.0,
        //                 width: 375.0,
        //                 child: Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //                   children: <Widget>[
        //                     ElevatedButton(
        //                       style: ElevatedButton.styleFrom(
        //                           shape: const CircleBorder(), primary: Color(0xFF9A7D1E) ),
        //                       child: Container(
        //                         width: 50,
        //                         height: 40,
        //                         alignment: Alignment.center,
        //                         decoration: const BoxDecoration(shape: BoxShape.circle),
        //                         child: Icon(Icons.add_card_rounded,semanticLabel: 'Place order',),
        //                       ),
        //                       onPressed: () { Navigator.pushNamed(context, '/ordering_map', arguments: {
        //                         'userid': user_id1,
        //                       }); } ,
        //                     ),
        //                     ElevatedButton(
        //                       style: ElevatedButton.styleFrom(
        //                           shape: const CircleBorder(), primary: Color(0xFF9A7D1E)),
        //                       child: Container(
        //                         width: 50,
        //                         height: 60,
        //                         alignment: Alignment.center,
        //                         decoration: const BoxDecoration(shape: BoxShape.circle),
        //                         child: Icon(Icons.people),
        //                       ),
        //                       onPressed: () => _onClick('Button2'),
        //                     ),
        //                     ElevatedButton(
        //                       style: ElevatedButton.styleFrom(
        //                           shape: const CircleBorder(), primary: Color(0xFF9A7D1E)),
        //                       child: Container(
        //                         width: 50,
        //                         height: 40,
        //                         alignment: Alignment.center,
        //                         decoration: const BoxDecoration(shape: BoxShape.circle),
        //                         child: Icon(Icons.timer),
        //                       ),
        //                       onPressed: () => _onClick('Button3'),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ],
        //       ),
        //
        //     ],
        //   ),
        //
        // ],
        body:  Container(
          padding:  EdgeInsets.all(32.0),
          child:  Center(
            child:  Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:  <Widget>[
                    ElevatedButton(
                      onPressed: () { Navigator.pushNamed(context, '/ordering_map', arguments: {
                        'userid': user_id1,
                      }); },
                      child:  Text('driver'),
                    ),
                    ElevatedButton(
                      onPressed: () { Navigator.pushNamed(context, '/ordering_map3', arguments: {
                        'userid': user_id1,
                      }); },
                      child:  Text('walking'),
                    ),

                  ],
                ),

                 Text(_value),
              ],
            ),
          ),
        )

    );
  }
}

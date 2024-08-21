import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ordermovisa2/pages/constants.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:sliding_up_panel/sliding_up_panel.dart';

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



class OrderTrackingPage2 extends StatefulWidget {
  const OrderTrackingPage2({Key? key}) : super(key: key);

  @override
  _OrderTrackingPageState2 createState() => _OrderTrackingPageState2();
// State<_OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState2 extends State<OrderTrackingPage2> {
  GoogleMapController? mapController;
  late IO.Socket socket;

  var _controller1 = TextEditingController();
  var _controller2 = TextEditingController();

  var checkinput = "";
  var setcheckinput = "";
  var checkedinputfinal = "";
  var checkedinputfinal2 = "";

  var counter = 1;

  var uuid = new Uuid();
  String? _sessionToken;
  List<dynamic> _placeList = [];
  List<dynamic> _placeList2 = [];

  Set<Marker> _markers = {};

  List<Marker> markers_pickup = [];
  List<Marker> markers_drop = [];
  List<Marker> _makers_t = [
    Marker(
      markerId: MarkerId("currentLocation"),
    ),
    Marker(
      markerId: MarkerId("currentLocation2"),
    ),
    Marker(
      markerId: MarkerId("driverslocation"),
    )
  ];

  var location_now_check = 0;
  var location_now_check2 = 0;
  var sourcevalcheck = 0;
  var sourcevalcheck2 = 0;

  double sourceLocation_lat = 0.0;
  double sourceLocation_lng = 0.0;
  double destination_lat = 0.0;
  double destination_lng = 0.0;
  final Completer<GoogleMapController> _controller = Completer();


  String sourceLocation2_lat = "";
  String sourceLocation2_lng ="";


  List<LatLng> polylineCoordinates = [];
  List<LatLng> polylineCoordinates2 = [];
  LocationData? currentLocation;

  double distance_ = 0.0;
  double t_amount = 0.0;

  var _counter = 0;
  Map<String, dynamic> from_pre_page_data = {};
  String user_id1 = '';

  var first_receive_socketio = 0;
  var driverid;

  var driver_info_check = 0;
  var driver_info;

  var remove_inputfields = 0;
  var remove_confirm = 0;
  var icon_destination;
  var icon_source;
  var icon_current;

  // custom markers
  getIcons() async {

    var i_des = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3.5),
        "assets/Pin_destination.png");

    var i_src = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3.5),
        "assets/Pin_source.png");

    setState(() {
      icon_destination = i_des;
      icon_source = i_src;
    });


  }

  void getCurrentLocation() async {
    Location location_now = Location();

    location_now.getLocation().then(
          (location) {
        currentLocation = location;
      },
    );

    if( location_now_check == 0 && remove_confirm == 0){
      location_now.onLocationChanged.listen(
            (newLoc) {
          if( location_now_check == 0 && remove_confirm == 0){

            currentLocation = newLoc;
            print('location_now_check :${location_now_check}');
            print('remove_confirm :${remove_confirm}');
            getCurrentLocationAddress(
                currentLocation!.latitude!, currentLocation!.longitude!);

            sourceLocation_lat = currentLocation!.latitude!;
            sourceLocation_lng = currentLocation!.longitude!;

            _makers_t[0] =
                Marker(
                  markerId: MarkerId("currentLocation"),
                  position: LatLng(
                      currentLocation!.latitude!,
                      currentLocation!.longitude!),
                  icon: icon_source,
                );
            setState(() {
              _markers = _makers_t.toSet();
            });
            location_now_check = 1;
          }
        },
      );

    }
  }

  void getCurrentLocationAddress(double lat,double lng) async{
    print("inside get current location adress");
    String kPLACES_API_KEY = google_api_key;

    String baseURL =
        'https://maps.googleapis.com/maps/api/geocode/json';
    String request =
        '$baseURL?latlng=${lat},${lng}&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {

      //print("print geocode response:");
      //print( json.decode(response.body) );
      Map<String, dynamic> data = json.decode(response.body);
      // print(data['results'][1]["formatted_address"]);

      if(remove_confirm == 0){
        _placeList = json.decode(response.body)['predictions'];
        checkedinputfinal = data['results'][1]["formatted_address"];
        _controller1.text = data['results'][1]["formatted_address"];
      }

      setState(() {

      });
    } else {
      throw Exception('Failed to load predictions');
    }

  }

  void getPolyPoints()async{
    print("inside get polylines");
    print("sourceLocation_lat: ${sourceLocation_lat} sourceLocation_lng: ${sourceLocation_lng} ");
    print("destination_lat: ${destination_lat} destination_lat: ${destination_lng} ");
    polylineCoordinates.clear();

    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation_lat, sourceLocation_lng),
        PointLatLng(destination_lat, destination_lng)
    );

    //polulineCoordinates is the List of longitute and latidtude.
    double calculateDistance(lat1, lon1, lat2, lon2){
      var p = 0.017453292519943295;
      var a = 0.5 - cos((lat2 - lat1) * p)/2 +
          cos(lat1 * p) * cos(lat2 * p) *
              (1 - cos((lon2 - lon1) * p))/2;
      return 12742 * asin(sqrt(a));
    }

    if (result.points.isNotEmpty) {
      result.points.forEach(
            (PointLatLng point) => polylineCoordinates.add(
            LatLng(point.latitude, point.longitude )
        ),
      );

      double totalDistance = 0;
      for(var i = 0; i < polylineCoordinates.length-1; i++){
        totalDistance += calculateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i+1].latitude,
            polylineCoordinates[i+1].longitude);
      }

      setState((){
        print("total distance:");
        print(totalDistance);
        distance_ =  double.parse(totalDistance.toStringAsFixed(2));
        remove_confirm = 1;


        t_amount = double.parse(totalDistance.toStringAsFixed(2));
        t_amount = (t_amount * 11.90) + 200;
        t_amount = double.parse(t_amount.toStringAsFixed(2));

        LatLng newlatlang = LatLng(destination_lat,destination_lng);
        mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
                CameraPosition(target: newlatlang, zoom: 13.5)
              //17 is new zoom level
            )
        );

      });

    }

    //#########################################################
    // everything notification
    // @override
    // void initState()  {
    //
    //
    // }

    void showNotification() {
      setState(() {
        _counter++;
      });

      flutterLocalNotificationsPlugin.show(
          0,
          "Testing $_counter",
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
    //########################################################

  }
  final _destinationController = TextEditingController();

  @override
  void initState() {
    fire_stuff();
    getCurrentLocation();
    getIcons();

    super.initState();

    print("inside super init state");

    initSocket();

    _controller1.addListener(() {
      _onChanged(_controller1.text);
      print("inside controller 1 listener");
    });
    _controller2.addListener(() {
      _onChanged2(_controller2.text);
      print("inside controller 2 listener");
    });

    //  om message app open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        print("_counter");

        // here we need to get the order details so driver can accept or decline
        //get_order_for_driver_response( from_pre_page_data["driver_id"].toString() );

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
        //get_order_for_driver_response( from_pre_page_data["driver_id"].toString() );
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


  _onChanged(texts) {
    print("inside on change function controller 1");
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(texts);
  }

  _onChanged2(texts) {
    print("inside on change function controller 2");
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion2(texts);
  }


  void getSuggestion(String input) async {
    print("inside get suggestion function");
    checkinput = input;
    String kPLACES_API_KEY = google_api_key;
    String type = '(regions)';
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        _placeList = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  void getSuggestion2(String input) async {
    print("inside get suggestion function 2");
    checkinput = input;
    String kPLACES_API_KEY = google_api_key;
    String type = '(regions)';
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        _placeList2 = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  void getLatLngFromAdress(String  autocompletePlaceId, String completeadress, String checkinput) async {
    print("inside getLatLngFromAdress function");
    String kPLACES_API_KEY = google_api_key;
    String _host = 'https://maps.googleapis.com/maps/api/geocode/json';
    final url = '$_host?place_id=$autocompletePlaceId&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(url));
    if(response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      checkedinputfinal = completeadress;
      var sourceLocation2_lat =  data["results"][0]["geometry"]["location"]["lat"];
      var sourceLocation2_lng = data["results"][0]["geometry"]["location"]["lng"];

      _controller1.text = completeadress;

      sourceLocation_lat = sourceLocation2_lat;
      sourceLocation_lng = sourceLocation2_lng;

      if ((checkedinputfinal == _controller1.text) && (checkedinputfinal2 == _controller2.text) ) {
        print("should run polypoints function");
        getPolyPoints();
      }

      // print(sourceLocation2_lat.runtimeType);
      counter = counter + 1;
      _makers_t[0]=
          Marker(
            markerId: MarkerId("origin point$counter"),
            position: LatLng(sourceLocation2_lat, sourceLocation2_lng),
            icon: icon_source,
          );
      setState((){
        _markers.clear();
        _markers = _makers_t.toSet();
        //print('list:${_markers}');
        _placeList = [];
      });

    } else print("null respone");

  }

  void getLatLngFromAdress2(String  autocompletePlaceId, String completeadress, String checkinput) async {
    print("inside getLatLngFromAdress2 function");
    String kPLACES_API_KEY = google_api_key;
    String _host = 'https://maps.googleapis.com/maps/api/geocode/json';
    final url = '$_host?place_id=$autocompletePlaceId&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';

    var response = await http.get(Uri.parse(url));
    if(response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      checkedinputfinal2 = completeadress;
      var destination2_lat =  data["results"][0]["geometry"]["location"]["lat"];
      var destination2_lng = data["results"][0]["geometry"]["location"]["lng"];

      _controller2.text = completeadress;

      destination_lat = destination2_lat;
      destination_lng = destination2_lng;

      if ((checkedinputfinal == _controller1.text) && (checkedinputfinal2 == _controller2.text) ) {
        print("should run polypoints function2");
        getPolyPoints();
      }

      //print(sourceLocation2_lat.runtimeType);
      counter = counter + 1;
      _makers_t[1]=
          Marker(
            markerId: MarkerId("origin point$counter"),
            position: LatLng(destination2_lat, destination2_lng),
            icon: icon_destination,
          );
      setState((){
        _markers.clear();
        _markers = _makers_t.toSet();
        //print('list:${_markers}');
        _placeList = [];
      });

    } else print("null respone");
  }

//create order
  void make_order(String userid) async {
    print("inside make order function");
    try{
      var url = "https://www.site.com/flutter_make_order";
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          //get the drivers working location and get all orders from the drivers province
          'userid': userid,
          'pick_up': "$sourceLocation_lat,$sourceLocation_lng",
          'destination':"$destination_lat,$destination_lng",
          'province':"east_london",
          'service': "delivery"
        }),
      );

      if(response.statusCode == 200){
        var data = jsonDecode(response.body.toString());
        print(data['token']);
        print('got orders successfully');
        print(data);
        setState(() {
          remove_inputfields = 1;
          remove_confirm = 0;
        });
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

  //============================
  //get driver details
  void get_driver(String driverid) async{
    try{

      var url = "https://www.site.com/get_driver_info";
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          //get the drivers working location and get all orders from the drivers province
          'driverid': driverid,
        }),
      );

      if(response.statusCode == 200){
        var data = jsonDecode(response.body);
        print(data['result']);

        driver_info_check = 1;
        driver_info = {
          'drivername': data['result']['driver_name'],
          'vehicle': data['result']['vehicle'],
        };
        print("getting driver detail");
        distance_ = 0.0;
        remove_inputfields = 1;
        remove_confirm = 0;

        setState(() {

        });
      }
    }catch(e){
      print(e.toString());
    }
  }


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
      socket.on('connect', (data) {
        print('Connected2: ${socket.id}'); // an alphanumeric id...
      });

      socket.onConnect((_) {
        print('Connected2: ${socket.id} user id: '+user_id1 );
        set_socketio_token(user_id1,socket.id.toString());
      });

      // ...............
      socket.on("receive_message", (data) async {
        print("here is the data recieved:");
        print("socket io recieved:");
        print(jsonDecode(data));

        var latlng = jsonDecode(data);
        //FIRST TIME RECIEVING INFORMATION
        if(first_receive_socketio == 0){
          print("once socket io reciever set driver id");
          driverid = latlng["driverid"];
          print("driverid:"+driverid);
          get_driver(latlng["driverid"]);

          first_receive_socketio = 1;

          setState(() {

          });
        }
        // POLY POINTS OF THE DRIVERS CURRENT ROUTE TO PICK UP
        polylineCoordinates.clear();

        PolylinePoints polylinePointss = PolylinePoints();

        PolylineResult result = await polylinePointss.getRouteBetweenCoordinates(
          google_api_key,
          PointLatLng(latlng["lat"], latlng["lng"]),
          PointLatLng(sourceLocation_lat, sourceLocation_lng),
          //PointLatLng(destination_lat, destination_lng)
        );

        if (result.points.isNotEmpty) {
          result.points.forEach(
                (PointLatLng point) =>
                polylineCoordinates.add(
                    LatLng(point.latitude, point.longitude)
                ),
          );


          counter = counter + 1;
          _makers_t[2]=
              Marker(
                markerId: MarkerId("origin point$counter"),
                position: LatLng(latlng["lat"], latlng["lng"]),
              );
          setState((){
            _markers.clear();
            _markers = _makers_t.toSet();
            //currentLocation = LatLng(latlng["lat"], latlng["lng"]);
            // _markers = _makers_t.toSet();
          });

        }
        //==========================
        var image = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(),
            "assets/map_icon_24.png"
        );



      });
      //..........................

    } catch (e) {
      print(e.toString());
    }
  }
  Color mainColor = Color(0xff247BA0);
  @override
  Widget build(BuildContext context) {

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );

    if(_counter == 0) {
      getCurrentLocation();
      from_pre_page_data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      user_id1 = from_pre_page_data["userid"].toString();
      print("here is user id 2: "+ from_pre_page_data["userid"].toString() );
      //set_firebase_device_token(from_pre_page_data["userid"].toString());
      _counter++;
    }

    return Scaffold(
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
      //                           shape: const CircleBorder(), primary: Color(0xFF9A7D1E)),
      //                       child: Container(
      //                         width: 50,
      //                         height: 40,
      //                         alignment: Alignment.center,
      //                         decoration: const BoxDecoration(shape: BoxShape.circle),
      //                         child: Icon(Icons.timer),
      //                       ),
      //                       onPressed: () {},
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
      //                       onPressed: () {
      //                         Navigator.pushNamed(context, '/ordering_map');
      //                       },
      //                     ),
      //                     ElevatedButton(
      //                       style: ElevatedButton.styleFrom(
      //                           shape: const CircleBorder(), primary: Color(0xFF9A7D1E)),
      //                       child: Container(
      //                         width: 50,
      //                         height: 40,
      //                         alignment: Alignment.center,
      //                         decoration: const BoxDecoration(shape: BoxShape.circle),
      //                         child: Icon(Icons.map),
      //                       ),
      //                       onPressed: () {},
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
      body: SlidingUpPanel(
        minHeight: 90.0,
        body: currentLocation == null
            ? Center(child: Text("loading"))
            :Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      (remove_inputfields == 1)? Text("") : Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,// center horizontally
                            children: <Widget>[

                              Container(
                                  width: 345.0,
                                  height: 45,
                                  //color: Colors.grey,
                                  // switching textfields
                                  child: TextField(
                                    controller: _controller1,
                                    decoration: InputDecoration(
                                      hintText: "Seek your location here",
                                      focusColor: Colors.white,
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      prefixIcon: Icon(Icons.map),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.cancel),
                                        onPressed: () { _controller1.clear(); location_now_check = 1; },
                                      ),
                                    ),
                                  )
                              ),
                            ],
                          ),
                          (checkedinputfinal == _controller1.text) ? Text("") :  ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _placeList.length,
                            itemBuilder: (context, index) {
                              // returns list of autocomplete and has the on pressed function that needs to be set in a variable for the map
                              return GestureDetector(
                                  onTap: () {
                                    print(_placeList[index]["place_id"]);
                                    setcheckinput = checkinput;
                                    getLatLngFromAdress(_placeList[index]["place_id"],_placeList[index]["description"],setcheckinput);
                                    //Navigator.pushNamed(context, "myRoute");
                                  },
                                  child: ListTile(
                                    title: Text(_placeList[index]["description"]),
                                  )
                              );

                            },
                          ),
                        ],
                      ),

                      (remove_inputfields == 1)? Text("") : Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,// center horizontally
                            children: <Widget>[
                              Container(
                                width: 345.0,
                                height: 45,
                                //color: Colors.grey,
                                child: TextField(
                                  controller: _controller2,
                                  decoration: InputDecoration(
                                    hintText: "Seek your location here",
                                    focusColor: Colors.white,
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    prefixIcon: Icon(Icons.map),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.cancel),
                                      onPressed: () { _controller2.clear(); },
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                          (checkedinputfinal2 == _controller2.text) ? Text(""): ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _placeList2.length,
                            itemBuilder: (context, index) {
                              // returns list of autocomplete and has the on pressed function that needs to be set in a variable for the map
                              return GestureDetector(
                                onTap: () {
                                  print(_placeList2[index]["place_id"]);
                                  setcheckinput = checkinput;

                                  getLatLngFromAdress2(_placeList2[index]["place_id"],_placeList2[index]["description"],setcheckinput);

                                  //Navigator.pushNamed(context, "myRoute");
                                },
                                child: ListTile(
                                  title: Text(_placeList2[index]["description"]),
                                ),
                              );

                            },
                          ),
                        ],
                      ),

                      Container(
                        height: 400,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                              zoom: 13.5,
                              target: ((checkedinputfinal == _controller1.text) && (checkedinputfinal2 == _controller2.text) )
                                  ? LatLng(currentLocation!.latitude!, currentLocation!.longitude!)
                                  : LatLng(destination_lat, destination_lng)

                          ),
                          polylines: {
                            Polyline(
                              polylineId: PolylineId("route"),
                              points: polylineCoordinates,
                              color: primaryColor,
                              width: 6,
                            ),
                          },
                          markers: Set<Marker>.of(_markers) ,
                          onMapCreated: (controller) { //method called when map is created
                            setState(() {
                              mapController = controller;
                            });
                          },
                        ),
                      ),




                    ],
                  ),
                ],
              ),
            )
        ),

        panel: Column(
          children: <Widget>[
            (distance_ == 0.0)? Text('') : Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:  <Widget>[
                    Text('Order Summary:',
                      style: TextStyle(height: 2, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:  <Widget>[
                    Text('Distance: ${distance_}km',
                      style: TextStyle(height: 2, fontSize: 20),
                    ),
                    Text('Payable: R${t_amount}',
                      style: TextStyle(height: 2, fontSize: 20),
                    ),
                  ],
                ),

              ],
            ),

            (driver_info_check == 0)? Text(''): Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:  <Widget>[
                    Text('Driver Details:',
                      style: TextStyle(height: 2,fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:  <Widget>[
                    Text('Driver Name: ${driver_info['drivername']}',
                      style: TextStyle(height: 2,fontSize: 20),
                    ),
                    Text('Vehicle: ${driver_info['vehicle']}',
                      style: TextStyle(height: 2,fontSize: 20),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:  <Widget>[
                    Text('Order Summary:',
                      style: TextStyle(height: 2, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:  <Widget>[
                    Text('Distance: ${distance_}km',
                      style: TextStyle(height: 2,fontSize: 20),
                    ),
                    Text('Payable: R${t_amount}',
                      style: TextStyle(height: 2,fontSize: 20),
                    ),
                  ],
                ),

              ],
            ),

            (remove_confirm == 0)? Text('') : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                (distance_ == 0.0)? Text('') : ElevatedButton(
                  child: Text('Confirm Request'),
                  onPressed: () {
                    // insure that next time the user comes to the page the location works
                    // location_now_check = 0;
                    make_order(from_pre_page_data["userid"].toString());
                  },
                  style: ElevatedButton.styleFrom(
                      primary: mainColor,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),

        collapsed: Container(
          decoration: BoxDecoration(
            //color: Colors.blueGrey,
              borderRadius: radius
          ),
        ),
        borderRadius: radius,
      ),

    );
  }
}

// Column(
// children: <Widget>[
// TextField(
// // controller: controller,
// // onChanged: onChanged,
// // onTap: onTap,
// // enabled: enabled,
// decoration: InputDecoration.collapsed(
// hintText: "hintText",
// ),
// ),

// ],
// )

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}
// log in code starts

String _message = 'Enter username';
Map<String, dynamic> map = {};
var ch;
var jsonde;

final TextEditingController _controller_username = TextEditingController();
final TextEditingController _controller_email = TextEditingController();
final TextEditingController _controller_passwaord = TextEditingController();
final TextEditingController _controller = TextEditingController();


var username_check = '';


class Album {

  final int id;
  final String username;
  final String email;
  final String password;

  const Album({required this.id, required this.username,required this.email,required this.password});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        email: json['email']
    );

  }
}

class _HomeState extends State<Home> {

  //log in logic code

  Future<String>? _futureAlbum;
  Future<Album>? _futureAlbum2;
  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
        () => 'Data Loaded',
  );

  Future<String> createAlbum3(String username, String email, String password) async {
    var url = "https://movingone.herokuapp.com/reg";
    final response = await http.post(
      // Uri.parse('https://jsonplaceholder.typicode.com/albums'),
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    Album.fromJson({'id': 0, 'email': 'b', 'username': 'yu', 'password': 'l'});
    jsonde = response.body;
    map = jsonDecode(response.body);
    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      map = jsonDecode(response.body);
      print("here:");
      print(map);
      print(map["title"]);
      settingstate2(jsonde);
      ch = 0;
      return 'registered';
    }else if (response.statusCode == 202) {
      print("here:::");
      _controller_username.clear();
      settingstate('username exists',1);
      return 'username_exsists';
    }else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  void settingstate(String check,int chh){
    print("here3:");
    setState(() {
      ch = chh;
      username_check = 'username exists';
      // _message = "username exists";
      _controller_username.clear();
    });
  }

  void settingstate2(var jsonde2){
    print("here4:");
    setState(() {
      _futureAlbum2 = Future<Album>(
              () =>  Album.fromJson({ 'id': 0, 'username': map['username'],'email': map['email'], 'password': map['password'] })
      );

    });
  }

  // log in logic end
  Color mainColor = Color(0xff247BA0);
  @override
  Widget build(BuildContext context) {
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
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: (_futureAlbum2 == null) ? buildColumn() : buildFutureBuilder(),
      ),
    );
  }

  Padding buildColumn() {
   return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _controller_username,
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
                hintText: 'Username',
              hintStyle: TextStyle(fontSize: 20),
            ),
          ),
          (username_check == 'username exists') ? Text('${username_check}') : Text(''),
          SizedBox(height: 5,),
          TextFormField(
            controller: _controller_email,
            style: TextStyle(fontSize: 20),
            decoration: InputDecoration(
                hintText: 'Email',
              hintStyle: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 20,),
          TextFormField(
            controller: _controller_passwaord,
            style: TextStyle(fontSize: 20),
            obscureText: true,
            decoration: InputDecoration(
                hintText: 'Password',
              hintStyle: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 40,),
          GestureDetector(
            onTap: ()async{
              //login(emailController.text.toString(), passwordController.text.toString());
              if(_controller_username.text == ""){
                setState(() {
                  username_check = "empty username field";
                });
              }else if (_controller_email.text == ""){
                setState(() {
                  username_check = "empty email field";
                });
              }else if(_controller_passwaord.text == ""){
                setState(() {
                  username_check = "empty password field";
                });
              }else{

                setState(() {
                  username_check = '';
                });

                _futureAlbum = createAlbum3(_controller_username.text,_controller_email.text,_controller_passwaord.text) as Future<String>?;

                if( await _futureAlbum == 'registered'){
                  print('registered');
                  Navigator.pushNamed(context, '/login');
                }else if( await _futureAlbum == 'username_exsists'){
                  print('username_exsists');
                }

              }

            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Center(child: Text('Register', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold) ),),
            ),
          ),
          Text(""),
          Row(
            children: <Widget>[
              Spacer(),
              Container(
                width: 140.0,
                child: GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, '/home');
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(child: Text('Forgot Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold) ),),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  FutureBuilder<Album> buildFutureBuilder() {
    return FutureBuilder<Album>(
      future: _futureAlbum2,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              Text(snapshot.data!.username),
              Text(snapshot.data!.email),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

// Column(
// mainAxisAlignment: MainAxisAlignment.center,
// children: <Widget>[
// TextField(
// controller: _controller_username,
// decoration: InputDecoration(hintText: _message,),
// ),
// (username_check == 'username exists') ? Text('error in username exists') : Text(''),
// TextField(
// controller: _controller_email,
// decoration: InputDecoration(hintText: 'Enter email'),
// ),
// TextField(
// controller: _controller_passwaord,
// decoration: InputDecoration(hintText: 'Enter password'),
// ),
// ElevatedButton(
//
// onPressed: () async {
// if(_controller_username.text == ""){
//
// }else if (_controller_email.text == ""){
//
// }else if(_controller_passwaord.text == ""){
//
// }else{
// _futureAlbum = createAlbum3(_controller_username.text,_controller_email.text,_controller_passwaord.text) as Future<String>?;
//
// if( await _futureAlbum == 'registered'){
// print('ddo');
// Navigator.pushNamed(context, '/login');
// }else if( await _futureAlbum == 'username_exsists'){
// print('hhuuu');
// }
//
// }
//
// },
// child: const Text('Regiter'),
// style: ElevatedButton.styleFrom(
// primary: Colors.yellowAccent, // Background color
// onPrimary: Colors.black, // Text Color (Foreground color)
// ),
// ),
// ],
// );
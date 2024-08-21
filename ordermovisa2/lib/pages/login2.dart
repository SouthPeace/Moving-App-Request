
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class login2 extends StatefulWidget {
  @override
  _loginstate2 createState() => _loginstate2();
}

class _loginstate2 extends State<login2> {
  int error_message = 0;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login(String email , password) async {

    try{
      error_message = 0;
      setState(() {

      });
      var url = "https://www.site.com/login";
      final response = await http.post(
        // Uri.parse('https://jsonplaceholder.typicode.com/albums'),
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if(response.statusCode == 200){

        var data = jsonDecode(response.body.toString());
        print(data['token']);
        print('Login successfully');
        Navigator.pushNamed(context, '/dashboard', arguments: {
          'userid': data['userid'],
        });

      }else {

        error_message = 1;
        setState(() {

        });
        print('incorrect credentials');
      }
    }catch(e){
      print(e.toString());
    }
  }
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
                child: Text('Moviza', style: TextStyle(fontSize: 25))
            ),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (error_message == 0) ? Text("") : Text("password doesnt match email."),
            TextFormField(
              controller: emailController,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                  hintText: 'Email',
                hintStyle: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20,),
            TextFormField(
              controller: passwordController,
              style: TextStyle(fontSize: 20),
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Password',
                hintStyle: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 40,),
            GestureDetector(
              onTap: (){
                login(emailController.text.toString(), passwordController.text.toString());
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Center(child: Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),),
              ),
            ),
            Text(""),
            Row(
              children: <Widget>[
                Spacer(),
                Container(
                  width: 160.0,
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
                      child: Center(child: Text('Register', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold) ),),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}

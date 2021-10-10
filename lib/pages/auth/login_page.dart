import 'dart:convert';
import 'dart:html';
import 'dart:ui';
import 'package:fluro/fluro.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/chapter.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/utils/config.dart';
import 'dart:html' as html;
import 'package:mydeca_web/utils/theme.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/src/painting/text_style.dart' as ts;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Storage _localStorage = html.window.localStorage;

  String _email;
  String _password;

  Widget loginWidget = new Container();

  _LoginPageState() {
    loginWidget = new Container(
      width: double.infinity,
      child: new RaisedButton(
          child: new Text("LOGIN"),
          textColor: Colors.white,
          color: mainColor,
          onPressed: login),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void alert(String alert) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: currCardColor,
              title: new Text(
                "Alert",
                style: TextStyle(color: currTextColor),
              ),
              content: new Text(alert, style: TextStyle(color: currTextColor)),
              actions: [
                new FlatButton(
                    child: new Text("GOT IT"),
                    textColor: mainColor,
                    onPressed: () {
                      router.pop(context);
                    })
              ],
            ));
  }

  Future<void> login() async {
    fb.auth().setPersistence("local");
    if (_email != "" && _password != "") {
      try {
        setState(() {
          loginWidget = new Container(
            child: new HeartbeatProgressIndicator(
              child: new Image.asset(
                "images/deca-diamond.png",
                height: 20,
              ),
            ),
          );
        });
        await fb
            .auth()
            .signInWithEmailAndPassword(_email, _password)
            .then((value) async {
          print(fb.auth().currentUser.uid);
          _localStorage["userID"] = fb.auth().currentUser.uid;
          if (html.window.location.toString().contains("login")) {
            router.navigateTo(context, "/home",
                transition: TransitionType.fadeIn, clearStack: true);
          } else {
            html.window.location.reload();
          }
        });
      } catch (e) {
        print(e);
        alert("An error occured while creating your account: ${e.message}");
      }
    }
    setState(() {
      loginWidget = new Container(
        width: double.infinity,
        child: new RaisedButton(
            child: new Text("LOGIN"),
            textColor: Colors.white,
            color: mainColor,
            onPressed: login),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Title(
      title: "myDECA",
      color: mainColor,
      child: new Scaffold(
        backgroundColor: currBackgroundColor,
        body: new Center(
          child: new Card(
            color: currCardColor,
            child: new AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(32.0),
              width: (MediaQuery.of(context).size.width > 500)
                  ? 500.0
                  : MediaQuery.of(context).size.width - 25,
              child: new SingleChildScrollView(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text("LOGIN",
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gotham"),
                        textAlign: TextAlign.center),
                    new Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    new TextField(
                      decoration: InputDecoration(
                        icon: new Icon(Icons.email),
                        labelText: "Email",
                        hintText: "Enter your email",
                      ),
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      onChanged: (value) {
                        _email = value;
                      },
                    ),
                    new TextField(
                      decoration: InputDecoration(
                        icon: new Icon(Icons.lock),
                        labelText: "Password",
                        hintText: "Enter a password",
                      ),
                      autocorrect: false,
                      obscureText: true,
                      onChanged: (value) {
                        _password = value;
                      },
                    ),
                    new Padding(padding: EdgeInsets.all(16.0)),
                    loginWidget,
                    new Padding(padding: EdgeInsets.all(8.0)),
                    new FlatButton(
                      child: new Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 17),
                      ),
                      textColor: mainColor,
                      onPressed: () {
                        router.navigateTo(context, "/register",
                            transition: TransitionType.fadeIn);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:html';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;
class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  final Storage _localStorage = html.window.localStorage;

  void getStarted() {
    if (fb.auth().currentUser != null) {
      print("User logged! Redirect to home");
      _localStorage["userID"] = fb.auth().currentUser.uid;
      router.navigateTo(context, "/home", transition: TransitionType.fadeIn);
    }
    else {
      print("User not logged! Redirect to register");
      _localStorage.remove("userID");
      router.navigateTo(context, '/register', transition: TransitionType.materialFullScreenDialog);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        child: new SingleChildScrollView(
          child: new Column(
            children: [
              Container(
                height: 100.0,
                color: Colors.black.withOpacity(0.8),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Container(
//                        width: 300,
//                        color: Colors.greenAccent,
                        child: Row(
                          children: [
//                            new Image.asset(
//                              "images/deca-diamond.png",
//                              color: mainColor,
//                              fit: BoxFit.fitHeight,
//                              height: 60,
//                            ),
//                            new Padding(padding: EdgeInsets.all(4)),
                            new Text(
                              "my",
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 65
                              ),
                            ),
                            new Text(
                              "DECA",
                              style: TextStyle(
                                fontFamily: "Gotham",
                                color: mainColor,
                                fontSize: 65
                              ),
                            )
                          ],
                        )
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new OutlineButton(
                          highlightElevation: 6.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
                          borderSide: BorderSide(color: Colors.grey),
                          child: new Text("GET STARTED", style: TextStyle(fontFamily: "Montserrat", letterSpacing: 1)),
                          textColor: Colors.white,
                          color: mainColor,
                          onPressed: getStarted
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              new Container(
                padding: EdgeInsets.all(200),
                child: Column(
                  children: [
                    new Text(
                      "A brand new way to DECA",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: "Montserrat", fontSize: 75, fontWeight: FontWeight.bold),
                    ),
                    new Padding(padding: EdgeInsets.all(8.0)),
                    new Text(
                      "Coming Summer 2020",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 50, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

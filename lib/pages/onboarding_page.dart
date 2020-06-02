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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        child: new SingleChildScrollView(
          child: new Column(
            children: [
              Container(
                height: 100.0,
                color: currBackgroundColor,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                        width: 300,
                        color: Colors.greenAccent,
                        child: Row(
                          children: [
                            new Image.asset(
                              "images/deca-diamond.png",
                              color: mainColor,
                              fit: BoxFit.fitHeight,
                              height: 85,
                            ),
                            new Padding(padding: EdgeInsets.all(4)),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                new Text(
                                  "VALLEY CHRISTIAN",
                                  style: TextStyle(
                                      fontFamily: "Gotham",
                                      color: mainColor,
                                      fontSize: 17
                                  ),
                                ),
                                new Text(
                                  "DECA",
                                  style: TextStyle(
                                    fontFamily: "Gotham",
                                    color: mainColor,
                                    fontSize: 60
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Visibility(
                          visible: (!_localStorage.containsKey("userID")),
                          child: new OutlineButton(
                            highlightElevation: 6.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                            borderSide: BorderSide(color: Colors.grey),
                            child: new Text("LOGIN"),
                            textColor: Colors.white,
                            color: mainColor,
                            onPressed: () {
                              router.navigateTo(context, '/login', transition: TransitionType.materialFullScreenDialog);
                            },
                          ),
                        ),
                        new Visibility(
                          visible: (_localStorage.containsKey("userID")),
                          child: new RaisedButton(
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                            child: new Text("SIGN OUT"),
                            textColor: Colors.white,
                            color: Colors.red,
                            onPressed: () {
                              setState(() {
                                fb.auth().signOut();
                                _localStorage.remove("userID");
                                html.window.location.reload();
                              });
                            },
                          ),
                        ),
                      ],
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

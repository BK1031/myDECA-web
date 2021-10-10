import 'dart:html';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import '../utils/config.dart';
import '../utils/theme.dart';
import 'package:flutter/src/painting/text_style.dart' as ts;

class OnboardingNavbar extends StatefulWidget {
  @override
  _OnboardingNavbarState createState() => _OnboardingNavbarState();
}

class _OnboardingNavbarState extends State<OnboardingNavbar> {
  final Storage _localStorage = html.window.localStorage;

  void getStarted() {
    if (fb.auth().currentUser != null) {
      print("User logged! Redirect to home");
      _localStorage["userID"] = fb.auth().currentUser.uid;
      router.navigateTo(context, "/home", transition: TransitionType.fadeIn);
    } else {
      print("User not logged! Redirect to register");
      _localStorage.remove("userID");
      router.navigateTo(context, '/register',
          transition: TransitionType.materialFullScreenDialog);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 1100) {
      return Container(
        height: 80.0,
        padding: EdgeInsets.only(left: 64, right: 64),
        color: Colors.black.withOpacity(0.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Container(
                child: Row(
              children: [
                new Image.asset(
                  "images/deca-logo.png",
                  color: Colors.white,
                  fit: BoxFit.fitHeight,
                  height: 60,
                ),
              ],
            )),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new FlatButton(
                  textColor: Colors.white,
                  child: new Text("JOIN BETA",
                      style: TextStyle(
                          fontFamily: "Montserrat", letterSpacing: 1)),
                  onPressed: () {
                    router.navigateTo(context, "/beta",
                        transition: TransitionType.fadeIn);
                  },
                ),
                new Padding(
                  padding: EdgeInsets.all(8),
                ),
                new FlatButton(
                  textColor: Colors.white,
                  child: new Text("DOCUMENTATION",
                      style: TextStyle(
                          fontFamily: "Montserrat", letterSpacing: 1)),
                  onPressed: () {
                    html.window.location.assign("https://docs.mydeca.org");
                  },
                ),
                new Padding(
                  padding: EdgeInsets.all(8),
                ),
                new FlatButton(
                  textColor: Colors.white,
                  child: new Text("DOWNLOAD",
                      style: TextStyle(
                          fontFamily: "Montserrat", letterSpacing: 1)),
                  onPressed: () {
                    router.navigateTo(context, "/download",
                        transition: TransitionType.fadeIn);
                  },
                ),
                new Padding(
                  padding: EdgeInsets.all(8),
                ),
                new RaisedButton(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    padding: EdgeInsets.all(16),
                    child: new Text("OPEN MYDECA",
                        style: TextStyle(
                            fontFamily: "Montserrat", letterSpacing: 1)),
                    textColor: Colors.white,
                    color: mainColor,
                    onPressed: getStarted),
              ],
            ),
          ],
        ),
      );
    } else {
      return new Drawer(
        child: new Container(
          color: Colors.black.withOpacity(0.8),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new FlatButton(
                textColor: Colors.white,
                child: new Text("JOIN BETA",
                    style:
                        TextStyle(fontFamily: "Montserrat", letterSpacing: 1)),
                onPressed: () {
                  router.navigateTo(context, "/beta",
                      transition: TransitionType.fadeIn);
                },
              ),
              new Padding(
                padding: EdgeInsets.all(8),
              ),
              new FlatButton(
                textColor: Colors.white,
                child: new Text("DOCUMENTATION",
                    style:
                        TextStyle(fontFamily: "Montserrat", letterSpacing: 1)),
                onPressed: () {
                  html.window.location.assign("https://docs.mydeca.org");
                },
              ),
              new Padding(
                padding: EdgeInsets.all(8),
              ),
              new FlatButton(
                textColor: Colors.white,
                child: new Text("DOWNLOAD",
                    style:
                        TextStyle(fontFamily: "Montserrat", letterSpacing: 1)),
                onPressed: () {
                  router.navigateTo(context, "/download",
                      transition: TransitionType.fadeIn);
                },
              ),
              new Padding(
                padding: EdgeInsets.all(8),
              ),
              new RaisedButton(
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  padding: EdgeInsets.all(16),
                  child: new Text("OPEN MYDECA",
                      style: TextStyle(
                          fontFamily: "Montserrat", letterSpacing: 1)),
                  textColor: Colors.white,
                  color: mainColor,
                  onPressed: getStarted),
            ],
          ),
        ),
      );
    }
  }
}

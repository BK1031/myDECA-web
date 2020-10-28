import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

class HomeNavbar extends StatefulWidget {
  @override
  _HomeNavbarState createState() => _HomeNavbarState();
}

class _HomeNavbarState extends State<HomeNavbar> {

  final Storage _localStorage = html.window.localStorage;

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 100.0,
      color: mainColor,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
              child: Row(
                children: [
                  new Image.asset(
                    "images/deca-diamond.png",
                    color: mainColor,
                    fit: BoxFit.fitHeight,
                    height: 60,
                  ),
                  new Padding(padding: EdgeInsets.all(4)),
                  new Text(
                    "my",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 65,
                    ),
                  ),
                  new Text(
                    "DECA",
                    style: TextStyle(
                        fontFamily: "Gotham",
                        color: Colors.white,
                        fontSize: 65
                    ),
                  )
                ],
              )
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new FlatButton(
                child: new Text("HOME", style: TextStyle(fontFamily: "Montserrat", color: Colors.white)),
                padding: EdgeInsets.only(left: 20, top: 16, bottom: 16, right: 20),
                onPressed: () {
                  router.navigateTo(context, '/home', transition: TransitionType.fadeIn);
                },
              ),
              new FlatButton(
                child: new Text("CONFERENCES", style: TextStyle(fontFamily: "Montserrat", color: Colors.white)),
                padding: EdgeInsets.only(left: 20, top: 16, bottom: 16, right: 20),
                onPressed: () {
                  router.navigateTo(context, '/conferences', transition: TransitionType.fadeIn);
                },
              ),
              new FlatButton(
                child: new Text("EVENTS", style: TextStyle(fontFamily: "Montserrat", color: Colors.white)),
                padding: EdgeInsets.only(left: 20, top: 16, bottom: 16, right: 20),
                onPressed: () {
                  router.navigateTo(context, '/events', transition: TransitionType.fadeIn);
                },
              ),
              new FlatButton(
                child: new Text("CHAT", style: TextStyle(fontFamily: "Montserrat", color: Colors.white)),
                padding: EdgeInsets.only(left: 20, top: 16, bottom: 16, right: 20),
                onPressed: () {
                  router.navigateTo(context, '/chat', transition: TransitionType.fadeIn);
                },
              ),
              new Padding(padding: EdgeInsets.all(4.0),),
              new FlatButton(
                child: new Text("SIGN OUT", style: TextStyle(fontFamily: "Montserrat")),
                textColor: Colors.white,
                padding: EdgeInsets.only(left: 20, top: 16, bottom: 16, right: 20),
                color: Colors.red,
                onPressed: () async {
                  await fb.auth().signOut();
                  _localStorage.remove("userID");
                  router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

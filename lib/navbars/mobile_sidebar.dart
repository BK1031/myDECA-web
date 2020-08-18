import 'dart:html';
import 'dart:html' as html;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';

class MobileSidebar extends StatefulWidget {
  @override
  _MobileSidebarState createState() => _MobileSidebarState();
}

class _MobileSidebarState extends State<MobileSidebar> {

  User currUser = User.plain();
  final Storage _localStorage = html.window.localStorage;
  List<Widget> roleWidgetList = new List();

  @override
  void initState() {
    super.initState();
    if (_localStorage.containsKey("userID")) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
          for (int i = 0; i < currUser.roles.length; i++) {
            print(currUser.roles[i]);
            roleWidgetList.add(new Card(
              color: roleColors[currUser.roles[i]],
              child: new Container(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                child: new Text(currUser.roles[i], style: TextStyle(color: Colors.white),),
              ),
            ));
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mainColor,
      child: new Column(
        children: [
          new Container(
            padding: new EdgeInsets.all(16),
            child: new Card(
              elevation: 2.0,
              child: new Container(
                color: currCardColor,
                child: new Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new Icon(Icons.person),
                          new Padding(padding: EdgeInsets.all(4)),
                          new Text("PROFILE", style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor),)
                        ],
                      ),
                    ),
                    new Container(padding: EdgeInsets.only(top: 8, bottom: 16), child: new Divider(color: currDividerColor, height: 8)),
                    new ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      child: new CachedNetworkImage(
                        imageUrl: currUser.profileUrl,
                        height: 100,
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(8)),
                    new Text(
                      currUser.firstName + " " + currUser.lastName,
                      style: TextStyle(fontSize: 25),
                    ),
                    new Padding(padding: EdgeInsets.all(8)),
                    new Wrap(
                        direction: Axis.horizontal,
                        children: roleWidgetList
                    ),
                    new ListTile(
                      leading: new Icon(currUser.emailVerified ? Icons.verified_user : Icons.mail),
                      title: new Text(currUser.email),
                    ),
                  ],
                ),
              ),
            ),
          ),
          new Padding(padding: EdgeInsets.all(16.0),),
          new FlatButton(
            child: new Text("HOME", style: TextStyle(fontFamily: "Montserrat", color: Colors.white)),
            onPressed: () {
              router.navigateTo(context, '/home', transition: TransitionType.fadeIn);
            },
          ),
          new FlatButton(
            child: new Text("CONFERENCES", style: TextStyle(fontFamily: "Montserrat", color: Colors.white)),
            onPressed: () {
              router.navigateTo(context, '/conferences', transition: TransitionType.fadeIn);
            },
          ),
          new FlatButton(
            child: new Text("EVENTS", style: TextStyle(fontFamily: "Montserrat", color: Colors.white)),
            onPressed: () {
              router.navigateTo(context, '/events', transition: TransitionType.fadeIn);
            },
          ),
          new Padding(padding: EdgeInsets.all(4.0),),
          new ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            child: new CachedNetworkImage(
              imageUrl: "",
            ),
          ),
          new FlatButton(
            child: new Text("SIGN OUT", style: TextStyle(fontFamily: "Montserrat")),
            textColor: Colors.white,
            color: Colors.red,
            onPressed: () async {
              await fb.auth().signOut();
              _localStorage.remove("userID");
              router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
            },
          ),
        ],
      ),
    );
  }
}

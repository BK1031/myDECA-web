import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Storage _localStorage = html.window.localStorage;

  List<String> announcementList = new List();

  User currUser = User.plain();

  @override
  void initState() {
    super.initState();
    if (_localStorage.containsKey("userID")) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorage["userID"] != null) {
      return new Scaffold(
        body: Container(
          child: new SingleChildScrollView(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeNavbar(),
                new Container(
                  padding: new EdgeInsets.all(16),
                  child: new Text("Welcome back, ${currUser.firstName}.", style: TextStyle(fontFamily: "Montserrat", color: currTextColor, fontSize: 35), textAlign: TextAlign.start,),
                ),
                new Container(
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Expanded(
                        flex: 3,
                        child: new Column(
                          children: [
                            new Container(
                              padding: new EdgeInsets.only(left: 16),
                              child: new Card(
                                elevation: 2.0,
                                child: new Container(
                                  color: currCardColor,
                                  padding: new EdgeInsets.all(16),
                                  child: new Column(
                                    children: [
                                      new Row(
                                        children: [
                                          new Icon(Icons.event),
                                          new Padding(padding: EdgeInsets.all(4)),
                                          new Text("DASHBOARD", style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor),)
                                        ],
                                      ),
                                      new Padding(padding: EdgeInsets.only(top: 8, bottom: 16), child: new Divider(color: currDividerColor, height: 8)),
                                      new Container(
                                        width: double.infinity,
                                        height: 100.0,
                                        child: new Row(
                                          children: <Widget>[
                                            new Expanded(
                                              flex: 5,
                                              child: new Card(
                                                elevation: 2.0,
                                                color: currCardColor,
                                                child: new InkWell(
                                                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                                  onTap: () {
                                                  },
                                                  child: new Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                      new Icon(Icons.event, size: 35.0, color: darkMode ? Colors.grey : Colors.black54),
                                                      new Text(
                                                        "My Events",
                                                        style: TextStyle(fontSize: 13.0, color: currTextColor),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            new Padding(padding: EdgeInsets.all(4.0)),
                                            new Expanded(
                                              flex: 3,
                                              child: new Card(
                                                elevation: 2.0,
                                                color: currCardColor,
                                                child: new InkWell(
                                                  onTap: () {
                                                    router.navigateTo(context, '/home/announcements', transition: TransitionType.native);
                                                  },
                                                  child: new Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: <Widget>[
                                                      new Text(
                                                        announcementList.length.toString(),
                                                        style: TextStyle(fontSize: 35.0, color: darkMode ? Colors.grey : Colors.black54),
                                                      ),
                                                      new Text(
                                                        "Announcements",
                                                        style: TextStyle(fontSize: 13.0, color: currTextColor),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      new Padding(padding: EdgeInsets.all(4.0)),
                                      new Container(
                                        width: double.infinity,
                                        height: 100.0,
                                        child: new Row(
                                          children: <Widget>[
                                            new Expanded(
                                              flex: 3,
                                              child: new Visibility(
                                                visible: true,
                                                child: new Card(
                                                  color: currCardColor,
                                                  elevation: 2.0,
                                                  child: new InkWell(
                                                    onTap: () {
                                                      router.navigateTo(context, '/home/notification-manager', transition: TransitionType.native);
                                                    },
                                                    child: new Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: <Widget>[
                                                        new Icon(Icons.notifications_active, size: 35.0, color: darkMode ? Colors.grey : Colors.black54,),
                                                        new Text(
                                                          "Send Notification",
                                                          style: TextStyle(fontSize: 13.0, color: currTextColor),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            new Padding(padding: EdgeInsets.all(4.0)),
                                            new Expanded(
                                              flex: 5,
                                              child: new Visibility(
                                                visible: true,
                                                child: new Card(
                                                  elevation: 2.0,
                                                  color: currCardColor,
                                                  child: new InkWell(
                                                    onTap: () {
                                                      // TODO: Implement role management
                                                    },
                                                    child: new Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: <Widget>[
                                                        new Icon(Icons.supervised_user_circle, size: 35.0, color: darkMode ? Colors.grey : Colors.black54),
                                                        new Text(
                                                          "Manage Users",
                                                          style: TextStyle(fontSize: 13.0, color: currTextColor),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(8)),
                      new Expanded(
                        flex: 1,
                        child: new Column(
                          children: [
                            new Container(
                              padding: new EdgeInsets.only(right: 16),
                              child: new Card(
                                elevation: 2.0,
                                child: new Container(
                                  color: currCardColor,
                                  padding: new EdgeInsets.all(16),
                                  child: new Column(
                                    children: [
                                      new Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          new Icon(Icons.person),
                                          new Padding(padding: EdgeInsets.all(4)),
                                          new Text("PROFILE", style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor),)
                                        ],
                                      ),
                                      new Padding(padding: EdgeInsets.only(top: 8, bottom: 16), child: new Divider(color: currDividerColor, height: 8)),
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
                                      new ListTile(
                                        leading: new Icon(Icons.mail),
                                        title: new Text(currUser.email),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            new Padding(padding: EdgeInsets.all(8)),
                            new Container(
                              padding: new EdgeInsets.only(right: 16),
                              child: new Card(
                                elevation: 2.0,
                                child: new Container(
                                  color: currCardColor,
                                  padding: new EdgeInsets.all(16),
                                  child: new Column(
                                    children: [
                                      new Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          new Icon(Icons.event),
                                          new Padding(padding: EdgeInsets.all(4)),
                                          new Text("UPCOMING EVENTS", style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor),)
                                        ],
                                      ),
                                      new Padding(padding: EdgeInsets.only(top: 8, bottom: 16), child: new Divider(color: currDividerColor, height: 8, )),
                                      new Text("There are no upcoming events.")
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    else {
      return LoginPage();
    }
  }
}

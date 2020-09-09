import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/competitive_event.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/navbars/mobile_sidebar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:html' as html;

import '../../utils/theme.dart';
import '../../utils/theme.dart';

class EventDetailsPage extends StatefulWidget {
  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {

  final Storage _localStorage = html.window.localStorage;

  User currUser = User.plain();

  CompetitiveEvent event = new CompetitiveEvent();

  @override
  void initState() {
    super.initState();
    renderEvent(html.window.location.toString());
  }

  void renderEvent(String route) {
    event.id = route.split("details?id=")[1];
    fb.database().ref("events").child(event.id).once("value").then((value) {
      setState(() {
        event = new CompetitiveEvent.fromSnapshot(value.snapshot);
        getCategoryColor(event.cluster);
      });
    });
  }

  void getCategoryColor(String name) {
    if (name == "Business Management") {
      eventColor = Color(0xFFfcc414);
      print("YELLOW");
    }
    else if (name == "Entrepreneurship") {
      eventColor = Color(0xFF818285);
      print("GREY");
    }
    else if (name == "Finance") {
      eventColor = Color(0xFF049e4d);
      print("GREEN");
    }
    else if (name == "Hospitality + Tourism") {
      eventColor = Color(0xFF046faf);
      print("INDIGO");
    }
    else if (name == "Marketing") {
      eventColor = Color(0xFFe4241c);
      print("RED");
    }
    else if (name == "Personal Financial Literacy") {
      eventColor = Color(0xFF7cc242);
      print("LT GREEN");
    }
    else {
      eventColor = mainColor;
      print("COLOR NOT FOUND");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorage["userID"] != null) {
      if (MediaQuery.of(context).size.width > 600) {
        return new Scaffold(
          backgroundColor: currBackgroundColor,
          body: Container(
            child: new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HomeNavbar(),
                  new Padding(padding: EdgeInsets.only(bottom: 16.0)),
                  new Container(
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new FlatButton(
                          child: new Text("Back to Events", style: TextStyle(color: mainColor, fontSize: 15),),
                          onPressed: () {
                            router.navigateTo(context, '/events', transition: TransitionType.fadeIn);
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Card(
                      color: currCardColor,
                      child: new Container(
                        padding: EdgeInsets.all(16.0),
                        child: new Column(
                          children: <Widget>[
                            new Text(
                                event.name,
                                style: TextStyle(fontFamily: "Montserrat", fontSize: 25.0, color: currTextColor)
                            ),
                            new Container(
                              width: double.infinity,
                              height: 100.0,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 3,
                                    child: new Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        new Text(
                                          event.snapshot.val()["participants"].toString(),
                                          style: TextStyle(fontSize: 35.0, color: eventColor),
                                        ),
                                        new Text(
                                          "Participants",
                                          style: TextStyle(fontSize: 15.0, color: currTextColor),
                                        )
                                      ],
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "written",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Text(
                                            event.snapshot.val()["pages"].toString(),
                                            style: TextStyle(fontSize: 35.0, color: eventColor),
                                          ),
                                          new Text(
                                            "Pages",
                                            style: TextStyle(fontSize: 15.0, color: currTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "written",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Text(
                                            event.snapshot.val()["presentationTime"].toString(),
                                            style: TextStyle(fontSize: 35.0, color: eventColor),
                                          ),
                                          new Text(
                                            "Minutes",
                                            style: TextStyle(fontSize: 15.0, color: currTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "roleplay",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Text(
                                            event.snapshot.val()["prepTime"].toString(),
                                            style: TextStyle(fontSize: 35.0, color: eventColor),
                                          ),
                                          new Text(
                                            "Minutes Prep",
                                            style: TextStyle(fontSize: 15.0, color: currTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "roleplay",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Text(
                                            event.snapshot.val()["interviewTime"].toString(),
                                            style: TextStyle(fontSize: 35.0, color: eventColor),
                                          ),
                                          new Text(
                                            "Minutes",
                                            style: TextStyle(fontSize: 15.0, color: currTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            new Text(
                              event.desc,
                              style: TextStyle(fontSize: 16.0, color: currTextColor),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(4.0)),
                  Container(
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Card(
                      color: currCardColor,
                      child: new Container(
                        padding: EdgeInsets.all(16.0),
                        child: new Column(
                          children: <Widget>[
                            new Container(
                              width: double.infinity,
                              height: 100.0,
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                    flex: 3,
                                    child: new InkWell(
                                      onTap: () {
                                        launch(event.guidelines);
                                      },
                                      child: new Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Icon(Icons.format_list_bulleted, size: 50.0, color: eventColor),
                                          new Text(
                                            "Guidelines",
                                            style: TextStyle(fontSize: 15.0, color: currTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "written" || event.type == "roleplay",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new InkWell(
                                        onTap: () {
                                          launch(event.snapshot.val()["sample"]);
                                        },
                                        child: new Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            new Icon(event.type == "written" ? Icons.library_books : Icons.speaker_notes, size: 50.0, color: eventColor),
                                            new Text(
                                              "Sample Event",
                                              style: TextStyle(fontSize: 15.0, color: currTextColor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "written",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new InkWell(
                                        onTap: () {
                                          launch(event.snapshot.val()["penalty"]);
                                        },
                                        child: new Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            new Icon(Icons.close, size: 50.0, color: eventColor),
                                            new Text(
                                              "Penalty Points",
                                              style: TextStyle(fontSize: 15.0, color: currTextColor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "roleplay",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new InkWell(
                                        onTap: () {
                                          launch(event.snapshot.val()["sampleExam"]);
                                        },
                                        child: new Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            new Icon(Icons.library_books, size: 50.0, color: eventColor),
                                            new Text(
                                              "Sample Exam",
                                              style: TextStyle(fontSize: 15.0, color: currTextColor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: event.type == "online",
                                    child: new Expanded(
                                      flex: 3,
                                      child: new InkWell(
                                        onTap: () {
                                          launch(event.snapshot.val()["register"]);
                                        },
                                        child: new Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            new Icon(Icons.open_in_new, size: 50.0, color: eventColor),
                                            new Text(
                                              "Register",
                                              style: TextStyle(fontSize: 15.0, color: currTextColor),
                                            )
                                          ],
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
                  ),
                  new Padding(padding: EdgeInsets.all(4.0)),
                  Container(
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Card(
                      color: currCardColor,
                      child: new Container(
                        width: double.infinity,
                        child: new FlatButton(
                          child: new Text("COMPETITIVE EVENTS SITE"),
                          textColor: eventColor,
                          onPressed: () {
                            launch("https://www.deca.org/high-school-programs/high-school-competitive-events");
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      else {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Events", style: TextStyle(color: Colors.white, fontFamily: "Montserrat"),),
          ),
          body: Container(
            child: new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                ],
              ),
            ),
          ),
        );
      }
    }
    else {
      return LoginPage();
    }
  }
}

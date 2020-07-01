import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/chapter.dart';
import 'dart:ui' as ui;
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/conference_agenda_item.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/pages/conference/conference_media_page.dart';
import 'package:mydeca_web/pages/conference/conference_overview_page.dart';
import 'package:mydeca_web/pages/conference/conference_schedule_page.dart';
import 'package:mydeca_web/pages/conference/conference_winner_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

class ConferenceSchedulePage extends StatefulWidget {
  @override
  _ConferenceSchedulePageState createState() => _ConferenceSchedulePageState();
}

class _ConferenceSchedulePageState extends State<ConferenceSchedulePage> {

  List<ConferenceAgendaItem> agendaList = new List();
  List<Widget> widgetList = new List();

  User currUser = User.plain();
  final Storage _localStorage = html.window.localStorage;

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
        fb.database().ref("conferences").child(html.window.location.toString().split("?id=")[1]).child("agenda").onChildAdded.listen((event) {
          setState(() {
            ConferenceAgendaItem agendaItem = ConferenceAgendaItem.fromSnapshot(event.snapshot);
            agendaList.add(agendaItem);
            widgetList.add(new Container(
              padding: EdgeInsets.only(bottom: 4.0),
              child: new Card(
                color: currCardColor,
                elevation: 2.0,
                child: new Container(
                  padding: EdgeInsets.all(16.0),
                  child: new Row(
                    children: <Widget>[
                      new Container(
                          padding: EdgeInsets.all(8.0),
                          child: new Text(
                            agendaItem.time,
                            style: TextStyle(color: mainColor, fontSize: 17.0, fontWeight: FontWeight.bold, fontFamily: "Gotham"),
                          )
                      ),
                      new Padding(padding: EdgeInsets.all(8.0)),
                      new Expanded(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              child: new Text(
                                agendaItem.title,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            new Padding(padding: EdgeInsets.all(2.0)),
                            new Container(
                              child: new Text(
                                agendaItem.location,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Container(
                        child: new Icon(
                          Icons.arrow_forward_ios,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widgetList.isEmpty) {
      return Container(
          child: new Text("Nothing to see here!\nCheck back later for schedule.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
      );
    }
    else {
      return Container(
        child: new Column(
            children: widgetList
        ),
      );
    }
  }
}

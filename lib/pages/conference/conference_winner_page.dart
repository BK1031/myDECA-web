import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/chapter.dart';
import 'dart:ui' as ui;
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/conference_agenda_item.dart';
import 'package:mydeca_web/models/conference_winner.dart';
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

class ConferenceWinnersPage extends StatefulWidget {
  String id;
  ConferenceWinnersPage(this.id);
  @override
  _ConferenceWinnersPageState createState() => _ConferenceWinnersPageState(this.id);
}

class _ConferenceWinnersPageState extends State<ConferenceWinnersPage> {

  List<ConferenceWinner> winnerList = new List();
  List<Widget> widgetList = new List();

  User currUser = User.plain();
  final Storage _localStorage = html.window.localStorage;

  String id;

  _ConferenceWinnersPageState(this.id);

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
        fb.database().ref("chapters").child(currUser.chapter.chapterID).child("conferences").child(id).child("winners").onChildAdded.listen((event) {
          ConferenceWinner winner = ConferenceWinner.fromSnapshot(event.snapshot);
          print(winner);
          setState(() {
            winnerList.add(winner);
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
                            winner.award.toUpperCase(),
                            style: TextStyle(color: mainColor, fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: "Gotham"),
                          )
                      ),
                      new Padding(padding: EdgeInsets.all(8.0)),
                      new Expanded(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              child: new Text(
                                winner.name,
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
                                winner.event,
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
        child: new Text("Nothing to see here!\nCheck back later for winners.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
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

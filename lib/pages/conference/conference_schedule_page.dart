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
import 'package:flutter/src/painting/text_style.dart' as ts;
class ConferenceSchedulePage extends StatefulWidget {
  String id;
  ConferenceSchedulePage(this.id);
  @override
  _ConferenceSchedulePageState createState() =>
      _ConferenceSchedulePageState(this.id);
}

class _ConferenceSchedulePageState extends State<ConferenceSchedulePage> {
  List<ConferenceAgendaItem> agendaList = new List();
  List<Widget> widgetList = new List();

  User currUser = User.plain();
  final Storage _localStorage = html.window.localStorage;

  String id;

  _ConferenceSchedulePageState(this.id);

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb
          .database()
          .ref("users")
          .child(_localStorage["userID"])
          .once("value")
          .then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
        fb
            .database()
            .ref("conferences")
            .child(id)
            .child("agenda")
            .onChildAdded
            .listen((event) {
          setState(() {
            ConferenceAgendaItem agendaItem =
                ConferenceAgendaItem.fromSnapshot(event.snapshot);
            agendaList.add(agendaItem);
            widgetList.add(new Container(
              padding: EdgeInsets.only(bottom: 4.0),
              child: new Card(
                color: currCardColor,
                child: new Container(
                  padding: EdgeInsets.all(16.0),
                  child: new Row(
                    children: <Widget>[
                      new Container(
                          padding: EdgeInsets.all(8.0),
                          child: new Text(
                            agendaItem.time,
                            style: TextStyle(
                                color: mainColor,
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gotham"),
                          )),
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
                                    color: Colors.grey),
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

  void addItem() {
    ConferenceAgendaItem item = new ConferenceAgendaItem.plain();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: currCardColor,
              title: new Text(
                "Add Schedule Item",
                style: TextStyle(color: currTextColor),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  new TextField(
                    decoration: InputDecoration(hintText: "Title"),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (input) {
                      item.title = input;
                    },
                  ),
                  new TextField(
                    decoration: InputDecoration(hintText: "Description"),
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (input) {
                      item.desc = input;
                    },
                  ),
                  new TextField(
                    decoration: InputDecoration(hintText: "Date"),
                    onChanged: (input) {
                      item.date = input;
                    },
                  ),
                  new TextField(
                    decoration: InputDecoration(hintText: "Start Time"),
                    onChanged: (input) {
                      item.time = input;
                    },
                  ),
                  new TextField(
                    decoration: InputDecoration(hintText: "End Time"),
                    onChanged: (input) {
                      item.endTime = input;
                    },
                  ),
                  new TextField(
                    decoration: InputDecoration(hintText: "Location"),
                    onChanged: (input) {
                      item.location = input;
                    },
                  )
                ],
              ),
              actions: [
                new FlatButton(
                    child: new Text("CANCEL"),
                    textColor: mainColor,
                    onPressed: () {
                      router.pop(context);
                    }),
                new FlatButton(
                    child: new Text("ADD"),
                    textColor: mainColor,
                    onPressed: () {
                      if (item.title != "" &&
                          item.date != "" &&
                          item.time != "" &&
                          item.endTime != "" &&
                          item.location != "") {
                        fb
                            .database()
                            .ref("conferences")
                            .child(id)
                            .child("agenda")
                            .push()
                            .set({
                          "title": item.title,
                          "desc": item.desc,
                          "date": item.date,
                          "time": item.time,
                          "endTime": item.endTime,
                          "location": item.location
                        });
                        router.pop(context);
                      }
                    })
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    if (widgetList.isEmpty) {
      return SingleChildScrollView(
          child: Column(
        children: [
          new Text(
            "Nothing to see here!\nCheck back later for schedule.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: currTextColor),
          ),
          new Padding(
            padding: EdgeInsets.all(16),
          ),
          new Visibility(
            visible: currUser.roles.contains("Developer"),
            child: new FlatButton(
              child: new Text("ADD ITEM"),
              textColor: mainColor,
              onPressed: () {
                addItem();
              },
            ),
          )
        ],
      ));
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            new Column(children: widgetList),
            new Padding(
              padding: EdgeInsets.all(16),
            ),
            new Visibility(
              visible: currUser.roles.contains("Developer"),
              child: new FlatButton(
                child: new Text("ADD ITEM"),
                textColor: mainColor,
                onPressed: () {
                  addItem();
                },
              ),
            )
          ],
        ),
      );
    }
  }
}

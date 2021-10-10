import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';
import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:intl/intl.dart';
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/navbars/mobile_sidebar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/pages/conference/conference_media_page.dart';
import 'package:mydeca_web/pages/conference/conference_overview_page.dart';
import 'package:mydeca_web/pages/conference/conference_schedule_page.dart';
import 'package:mydeca_web/pages/conference/conference_winner_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

import 'package:url_launcher/url_launcher.dart';

class MockConferenceRoleplayJudgingPage extends StatefulWidget {
  String id;
  String roleplayTeamID;
  MockConferenceRoleplayJudgingPage(this.id, this.roleplayTeamID);
  @override
  _MockConferenceRoleplayJudgingPageState createState() =>
      _MockConferenceRoleplayJudgingPageState(this.id, this.roleplayTeamID);
}

class _MockConferenceRoleplayJudgingPageState
    extends State<MockConferenceRoleplayJudgingPage> {
  final Storage _localStorage = html.window.localStorage;
  User currUser = User.plain();
  Conference conference = Conference.plain();

  String mockConferenceEvent = "";
  String selectedRoleplay = "";
  String roleplayTeamID;

  DateTime startTime = DateTime.now();

  String roleplayUrl = 'https://static.impression.co.uk/2014/05/loading1.gif';
  String guidelinesUrl = 'https://static.impression.co.uk/2014/05/loading1.gif';
  static ValueKey key = ValueKey('key_0');

  String zoomUrl = "";

  String eventName = "";
  String eventDesc = "";

  int score = 0;
  String feedback = "";

  List<List<int>> scores = new List();

  List<Widget> scoringWidgets = new List();

  TextEditingController feedbackController = new TextEditingController();

  _MockConferenceRoleplayJudgingPageState(String id, String writtenTeamID) {
    conference.conferenceID = id;
    this.roleplayTeamID = writtenTeamID;
  }

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
          writtenTeam.clear();
          print(currUser);
        });
        fb
            .database()
            .ref("conferences")
            .child(conference.conferenceID)
            .once("value")
            .then((value) {
          setState(() {
            conference = new Conference.fromSnapshot(value.snapshot);
          });
        });
        getTeammates();
        fb
            .database()
            .ref("conferences")
            .child(conference.conferenceID)
            .child("teams")
            .child(roleplayTeamID)
            .once("value")
            .then((value) {
          if (value.snapshot.val()["roleplay"] != null) {
            setState(() {
              selectedRoleplay = value.snapshot.val()["roleplay"];
              mockConferenceEvents.forEach((key, value) {
                if (value.contains(selectedRoleplay)) mockConferenceEvent = key;
              });
              roleplayUrl = roleplayPrompts[mockConferenceEvent][1];
            });
            fb
                .database()
                .ref("events")
                .child(selectedRoleplay)
                .once("value")
                .then((value) {
              setState(() {
                eventName = value.snapshot.val()["name"];
                eventDesc = value.snapshot.val()["desc"];
                guidelinesUrl = value.snapshot.val()["guidelines"];
              });
            });
          }
          if (value.snapshot.val()["writtenUrl"] != null) {
            setState(() {
              roleplayUrl = value.snapshot.val()["writtenUrl"];
            });
          }
          createScoringForms(mockConferenceEvent);
        });
        fb
            .database()
            .ref("conferences")
            .child(conference.conferenceID)
            .child("eventSchedule")
            .child(roleplayTeamID)
            .once("value")
            .then((value) {
          setState(() {
            startTime = DateTime.parse(value.snapshot.val()["time"]);
            zoomUrl = value.snapshot.val()["url"];
          });
        });
      });
    }
  }

  void alert(String alert) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: currCardColor,
              title: new Text(
                "Alert",
                style: TextStyle(color: currTextColor),
              ),
              content: new Text(alert, style: TextStyle(color: currTextColor)),
              actions: [
                new FlatButton(
                    child: new Text("GOT IT"),
                    textColor: mainColor,
                    onPressed: () {
                      router.pop(context);
                    })
              ],
            ));
  }

  void getTeammates() {
    writtenTeam.clear();
    fb
        .database()
        .ref("conferences")
        .child(conference.conferenceID)
        .child("teams")
        .child(roleplayTeamID)
        .child("users")
        .onChildAdded
        .listen((event) {
      fb
          .database()
          .ref("users")
          .child(event.snapshot.val())
          .once("value")
          .then((value) {
        setState(() {
          writtenTeam.add(new User.fromSnapshot(value.snapshot));
        });
      });
    });
  }

  Future<void> createScoringForms(String event) async {
    scoringWidgets.clear();
    scores.clear();
    List<dynamic> savedScores;
    fb
        .database()
        .ref("conferences")
        .child(conference.conferenceID)
        .child("teams")
        .child(roleplayTeamID)
        .child("scores")
        .once("value")
        .then((value) {
      if (value.snapshot.val() != null &&
          value.snapshot.val()["feedback"] != null) {
        feedback = value.snapshot.val()["feedback"];
        feedbackController.text = feedback;
      }
      if (value.snapshot.val() != null &&
          value.snapshot.val()["breakdown"] != null) {
        print("Retrieving saved scores");
        score = value.snapshot.val()["total"];
        savedScores = value.snapshot.val()["breakdown"];
        print("\nSAVED SCORES\n" + savedScores.toString() + "\n");
        savedScores.forEach((element) => print(element));
      }
      setState(() {
        scoringWidgets.add(
          new Text(
            "Key Performance Indicators:",
            style: TextStyle(fontSize: 20, color: mainColor),
          ),
        );
      });
      scores.add(new List());
      for (int i = 0; i < roleplayRubrics[event][0].length; i++) {
        savedScores != null
            ? scores[0].add(savedScores[0][i])
            : scores[0].add(0);
        setState(() {
          scoringWidgets.add(new Row(children: [
            new Expanded(
                flex: 3,
                child: new Text(roleplayRubrics[event][0][i],
                    style: TextStyle(fontSize: 17))),
            new Expanded(
              flex: 1,
              child: new TextField(
                controller: TextEditingController()
                  ..text = scores[0][i].toString(),
                decoration: InputDecoration(hintText: "0"),
                textAlign: TextAlign.center,
                onChanged: (input) {
                  print(int.tryParse(input).toString());
                  if (int.tryParse(input) != null) {
                    scores[0][i] = int.tryParse(input);
                  } else {
                    scores[0][i] = 0;
                  }
                  calculateTotal();
                },
              ),
            )
          ]));
        });
      }
      setState(() {
        scoringWidgets.add(new Padding(
          padding: EdgeInsets.all(4),
        ));
        scoringWidgets.add(
          new Text(
            "21st Century Skills:",
            style: TextStyle(fontSize: 20, color: mainColor),
          ),
        );
      });
      scores.add(new List());
      for (int i = 0; i < roleplayRubrics[event][1].length; i++) {
        savedScores != null
            ? scores[1].add(savedScores[1][i])
            : scores[1].add(0);
        setState(() {
          scoringWidgets.add(new Row(children: [
            new Expanded(
                flex: 3,
                child: new Text(roleplayRubrics[event][1][i],
                    style: TextStyle(fontSize: 17))),
            new Expanded(
              flex: 1,
              child: new TextField(
                controller: TextEditingController()
                  ..text = scores[1][i].toString(),
                decoration: InputDecoration(hintText: "0"),
                textAlign: TextAlign.center,
                onChanged: (input) {
                  print(int.tryParse(input).toString());
                  if (int.tryParse(input) != null) {
                    scores[1][i] = int.tryParse(input);
                  } else {
                    scores[1][i] = 0;
                  }
                  calculateTotal();
                },
              ),
            )
          ]));
        });
      }
    });
  }

  void calculateTotal() {
    score = 0;
    print(scores);
    for (int i = 0; i < scores[0].length; i++) {
      setState(() {
        score += scores[0][i];
      });
    }
    for (int i = 0; i < scores[1].length; i++) {
      setState(() {
        score += scores[1][i];
      });
    }
    fb
        .database()
        .ref("conferences")
        .child(conference.conferenceID)
        .child("teams")
        .child(roleplayTeamID)
        .child("scores")
        .child("total")
        .set(score);
    fb
        .database()
        .ref("conferences")
        .child(conference.conferenceID)
        .child("teams")
        .child(roleplayTeamID)
        .child("scores")
        .child("breakdown")
        .set(scores);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currBackgroundColor,
      body: new Container(
        child: Column(
          children: [
            HomeNavbar(),
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 8.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new FlatButton(
                    child: new Text(
                      "Back to ${conference.fullName}",
                      style: TextStyle(color: mainColor, fontSize: 15),
                    ),
                    onPressed: () {
                      router.navigateTo(
                          context, '/conferences/${conference.conferenceID}',
                          transition: TransitionType.fadeIn);
                    },
                  ),
                ],
              ),
            ),
            new Expanded(
              child: new Row(
                children: [
                  new Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.only(left: 25, top: 8, bottom: 25),
                      child: new Card(
                        child: new Stack(
                          children: [
                            EasyWebView(
                                src: roleplayUrl,
                                ///onLoaded: () {
                                ///  print('$key: Loaded: $roleplayUrl');
                                ///},
                                key: key),
                          ],
                        ),
                      ),
                    ),
                  ),
                  new Expanded(
                    child: new Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding: EdgeInsets.only(
                            left: 25, right: 25, top: 8, bottom: 25),
                        child: SingleChildScrollView(
                          child: new Column(
                            children: [
                              new Card(
                                child: new Container(
                                  padding: EdgeInsets.all(16),
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      new Text(
                                        mockConferenceEvent,
                                        style: TextStyle(
                                            fontFamily: "Montserrat",
                                            fontSize: 25),
                                      ),
                                      new Padding(
                                        padding: EdgeInsets.all(4),
                                      ),
                                      new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          new Text(
                                            "$selectedRoleplay – $eventName",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          new Text(
                                              "${DateFormat("MMMd").format(startTime)} (${DateFormat("jm").format(startTime)} - ${DateFormat("jm").format(startTime.add(Duration(minutes: 10)))})",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: mainColor)),
                                        ],
                                      ),
                                      new Padding(
                                        padding: EdgeInsets.all(8),
                                      ),
                                      new Text("$eventDesc",
                                          style: TextStyle(fontSize: 17)),
                                      new Padding(
                                        padding: EdgeInsets.all(4),
                                      ),
                                      new FlatButton(
                                        child:
                                            new Text("VIEW EVENT GUIDELINES"),
                                        onPressed: () => launch(guidelinesUrl),
                                        textColor: mainColor,
                                      ),
                                      new Padding(
                                        padding: EdgeInsets.all(8),
                                      ),
                                      new Text("Team ID: $roleplayTeamID",
                                          style: TextStyle(fontSize: 17)),
                                      new Padding(
                                        padding: EdgeInsets.all(4),
                                      ),
                                      Row(
                                        children: writtenTeam
                                            .map((k) => Container(
                                                  padding:
                                                      EdgeInsets.only(right: 8),
                                                  child: new Chip(
                                                    label: new Text(
                                                        k.firstName +
                                                            " " +
                                                            k.lastName,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                    backgroundColor: mainColor,
                                                  ),
                                                ))
                                            .toList(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              new Padding(
                                padding: EdgeInsets.all(4),
                              ),
                              new Card(
                                child: new Container(
                                  padding: EdgeInsets.all(16),
                                  child: new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              new Text(
                                                "JUDGING",
                                                style: TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 25),
                                              ),
                                              new Padding(
                                                padding: EdgeInsets.all(8),
                                              ),
                                            ],
                                          ),
                                          new Text("$score/100",
                                              style: TextStyle(
                                                  fontFamily: "Gotham",
                                                  fontSize: 60,
                                                  color: mainColor))
                                        ],
                                      ),
                                      new Padding(
                                        padding: EdgeInsets.all(8),
                                      ),
                                      new Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: scoringWidgets,
                                      ),
                                      new Padding(
                                        padding: EdgeInsets.all(8),
                                      ),
                                      new Text(
                                        "Additional Feedback:",
                                        style: TextStyle(
                                            fontSize: 20, color: mainColor),
                                      ),
                                      new Padding(
                                        padding: EdgeInsets.all(4),
                                      ),
                                      new TextField(
                                        controller: feedbackController,
                                        decoration: InputDecoration(
                                          labelText: "Feedback",
                                        ),
                                        maxLines: null,
                                        onChanged: (input) {
                                          feedback = input;
                                          fb
                                              .database()
                                              .ref("conferences")
                                              .child(conference.conferenceID)
                                              .child("teams")
                                              .child(roleplayTeamID)
                                              .child("scores")
                                              .child("feedback")
                                              .set(feedback);
                                        },
                                      ),
                                      new Padding(
                                        padding: EdgeInsets.all(8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

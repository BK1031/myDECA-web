import 'dart:async';

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

class MockConferenceTestingPage extends StatefulWidget {
  String id;
  MockConferenceTestingPage(this.id);
  @override
  _MockConferenceTestingPageState createState() => _MockConferenceTestingPageState(this.id);
}

class _MockConferenceTestingPageState extends State<MockConferenceTestingPage> {

  final Storage _localStorage = html.window.localStorage;
  User currUser = User.plain();
  Conference conference = Conference.plain();

  bool taken = false;
  Stopwatch stopwatch = new Stopwatch();
  DateTime startTime;
  DateTime endTime;

  Timer timer;

  String selectedRoleplay = "0";
  String roleplayTeamID = "";

  String examName = "";

  String testUrl = 'https://static.impression.co.uk/2014/05/loading1.gif';
  String solutionUrl = 'https://static.impression.co.uk/2014/05/loading1.gif';
  static ValueKey key = ValueKey('key_0');

  List<String> myAnswers = new List(50);
  List<String> correctAnswers = new List();

  List<Widget> examForm = new List();

  _MockConferenceTestingPageState(String id) {
    conference.conferenceID = id;
  }

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
        fb.database().ref("conferences").child(conference.conferenceID).once("value").then((value) {
          setState(() {
            conference = new Conference.fromSnapshot(value.snapshot);
          });
        });
        fb.database().ref("conferences").child(conference.conferenceID).child("examOpen").once("value").then((event) {
          print("TEST OPEN: ${event.snapshot.val()}");
          if (!event.snapshot.val()) {
            alert("This test has not been opened yet! Please check back again later.");
            router.navigateTo(context, "/conferences/${conference.conferenceID}", clearStack: true, replace: true, transition: TransitionType.fadeIn);
          }
        });
        fb.database().ref("conferences").child(conference.conferenceID).child("users").child(currUser.userID).once("value").then((value) {
          if (value.snapshot.val()["roleplay"] != null) {
            setState(() {
              roleplayTeamID = value.snapshot.val()["roleplay"];
            });
            fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(roleplayTeamID).once("value").then((value) {
              if (value.snapshot.val()["roleplay"] != null) {
                setState(() {
                  selectedRoleplay = value.snapshot.val()["roleplay"];
                });
                roleplayExams.forEach((key, value) {
                  if (value.contains(selectedRoleplay)) {
                    setState(() {
                      examName = key;
                      print(examName);
                    });
                  }
                });
                fb.database().ref("conferences").child(conference.conferenceID).child("exams").child(examName).once("value").then((value) {
                  setState(() {
                    testUrl = value.snapshot.val()["testUrl"];
                    solutionUrl = value.snapshot.val()["solutionUrl"];
                    correctAnswers = value.snapshot.val()["answers"];
                  });
                  print(testUrl);
                });
              }
              else {
                router.navigateTo(context, "/conferences/${conference.conferenceID}", clearStack: true, replace: true, transition: TransitionType.fadeIn);
              }
            });
          }
        });
        fb.database().ref("conferences").child(conference.conferenceID).child("scores").child("exam").child(currUser.userID).once("value").then((value) {
          if (value.snapshot.val() != null) {
            setState(() {
              taken = true;
            });
          }
        });
      });
    }
  }

  void confirmStart() {
    showDialog(
        context: context,
        child: new AlertDialog(
          backgroundColor: currCardColor,
          title: new Text("Start Exam", style: TextStyle(color: currTextColor),),
          content: new Text("Are you sure you want to start the exam now?", style: TextStyle(color: currTextColor)),
          actions: [
            new FlatButton(
                child: new Text("CANCEL"),
                textColor: mainColor,
                onPressed: () {
                  router.pop(context);
                }
            ),
            new FlatButton(
                child: new Text("START"),
                textColor: mainColor,
                onPressed: () {
                  setState(() {
                    for (int i = 0; i < myAnswers.length; i++) {
                      examForm.add(new Row(
                        children: <Widget>[
                          new Text(
                            "Question ${i+1}",
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0),
                          ),
                          new DropdownButton(
                            value: myAnswers[i],
                            items: [
                              DropdownMenuItem(child: new Text("Select an answer choice"), value: null),
                              DropdownMenuItem(child: new Text("A"), value: "a"),
                              DropdownMenuItem(child: new Text("B"), value: "b"),
                              DropdownMenuItem(child: new Text("C"), value: "c"),
                              DropdownMenuItem(child: new Text("D"), value: "d"),
                            ],
                            onChanged: (value) {
                              setState(() {
                                myAnswers[i] = value;
                              });
                            },
                          ),
                        ],
                      ));
                    }
                  });

                  stopwatch.start();
                  startTime = DateTime.now();
                  endTime = startTime.add(Duration(minutes: 45));

                  timer = new Timer.periodic(const Duration(milliseconds: 500), (timer) {
                    setState(() {});

                  });

                  router.pop(context);
                }
            )
          ],
        )
    );
  }

  void alert(String alert) {
    showDialog(
        context: context,
        child: new AlertDialog(
          backgroundColor: currCardColor,
          title: new Text("Alert", style: TextStyle(color: currTextColor),),
          content: new Text(alert, style: TextStyle(color: currTextColor)),
          actions: [
            new FlatButton(
                child: new Text("GOT IT"),
                textColor: mainColor,
                onPressed: () {
                  router.pop(context);
                }
            )
          ],
        )
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(label: new Text("SUBMIT"), onPressed: () {},),
      backgroundColor: currBackgroundColor,
      body: new Container(
        child: new Row(
          children: [
            new Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                padding: EdgeInsets.only(left: 25, top: 25, bottom: 25),
                child: new Card(
                  child: new Stack(
                    children: [
                      Expanded(
                        child: EasyWebView(
                          src: testUrl,
                          onLoaded: () {
                            print('$key: Loaded: $testUrl');
                          },
                          key: key
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ),
            new Expanded(
              child: new Container(
                width: MediaQuery.of(context).size.width / 2,
                padding: EdgeInsets.all(25),
                child: new Column(
                  children: [
                    new Card(
                      child: new Container(
                        padding: EdgeInsets.all(16),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            new Text(examName, style: TextStyle(fontFamily: "Montserrat", fontSize: 25),),
                            new Padding(padding: EdgeInsets.all(4),),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                new Text("${currUser.firstName} ${currUser.lastName}", style: TextStyle(fontSize: 17),),
                                new Visibility(
                                    visible: taken,
                                    child: new Text("Score: ", style: TextStyle(fontSize: 17))
                                ),
                                new Visibility(
                                  visible: !taken && stopwatch.isRunning,
                                  child: new Text("Time Remaining: ${stopwatch.isRunning ? _printDuration(endTime.difference(DateTime.now())) : ""}", style: TextStyle(fontSize: 17))
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(4),),
                    new Visibility(
                      visible: !taken && !stopwatch.isRunning,
                      child: new Card(
                        child: new InkWell(
                          onTap: () {
                            confirmStart();
                          },
                          child: new Container(
                            padding: EdgeInsets.all(16),
                            child: Center(child: new Text("START EXAM", style: TextStyle(fontSize: 17, color: mainColor),)),
                          ),
                        ),
                      ),
                    ),
                    new Visibility(
                      visible: !taken && stopwatch.isRunning,
                      child: new Expanded(
                        child: new Card(
                          child: new SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: new Column(
                              children: examForm,
                            ),
                          )
                        ),
                      ),
                    )
                  ],
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}

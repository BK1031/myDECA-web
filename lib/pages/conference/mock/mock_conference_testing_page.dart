import 'dart:async';

import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';
import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:intl/intl.dart';
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/mock_conference_exam.dart';
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

class MockConferenceTestingPage extends StatefulWidget {
  String id;
  MockConferenceTestingPage(this.id);
  @override
  _MockConferenceTestingPageState createState() =>
      _MockConferenceTestingPageState(this.id);
}

class _MockConferenceTestingPageState extends State<MockConferenceTestingPage> {
  final Storage _localStorage = html.window.localStorage;
  User currUser = User.plain();
  Conference conference = Conference.plain();

  bool taken = false;
  int score = 0;
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
  List<dynamic> correctAnswers;

  List<dynamic> submittedAnswers;

  List<Widget> answersWidgets = new List();

  _MockConferenceTestingPageState(String id) {
    conference.conferenceID = id;
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
        // fb.database().ref("conferences").child(conference.conferenceID).child("examOpen").once("value").then((event) {
        //   print("TEST OPEN: ${event.snapshot.val()}");
        //   if (!event.snapshot.val()) {
        //     alert("This test has not been opened yet! Please check back again later.");
        //     router.navigateTo(context, "/conferences/${conference.conferenceID}", clearStack: true, replace: true, transition: TransitionType.fadeIn);
        //   }
        // });
        fb
            .database()
            .ref("conferences")
            .child(conference.conferenceID)
            .child("users")
            .child(currUser.userID)
            .once("value")
            .then((value) {
          if (value.snapshot.val()["roleplay"] != null) {
            setState(() {
              roleplayTeamID = value.snapshot.val()["roleplay"];
            });
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
                });
                roleplayExams.forEach((key, value) {
                  if (value.contains(selectedRoleplay)) {
                    setState(() {
                      examName = key;
                      print(examName);
                    });
                  }
                });
                fb
                    .database()
                    .ref("conferences")
                    .child(conference.conferenceID)
                    .child("exams")
                    .child(examName)
                    .once("value")
                    .then((value) {
                  setState(() {
                    testUrl = value.snapshot.val()["testUrl"];
                    solutionUrl = value.snapshot.val()["solutionUrl"];
                    correctAnswers = value.snapshot.val()["answers"];
                  });
                  print(testUrl);
                  fb
                      .database()
                      .ref("conferences")
                      .child(conference.conferenceID)
                      .child("examScores")
                      .child(currUser.userID)
                      .once("value")
                      .then((value) {
                    if (value.snapshot.val() != null) {
                      print(value.snapshot.val());
                      setState(() {
                        taken = true;
                        score = value.snapshot.val()["score"];
                        startTime =
                            DateTime.parse(value.snapshot.val()["startTime"]);
                        endTime =
                            DateTime.parse(value.snapshot.val()["endTime"]);
                        submittedAnswers = value.snapshot.val()["answers"];
                      });
                      createAnswersWidgets();
                      print("START TIME: " + startTime.toString());
                      print("START TIME + " + startTime.toString());
                    }
                  });
                });
              } else {
                router.navigateTo(
                    context, "/conferences/${conference.conferenceID}",
                    clearStack: true,
                    replace: true,
                    transition: TransitionType.fadeIn);
              }
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    stopwatch.stop();
  }

  void createAnswersWidgets() {
    print(submittedAnswers);
    print(correctAnswers);
    setState(() {
      answersWidgets.add(new FlatButton(
        child: Text("VIEW EXAM SOLUTIONS"),
        onPressed: () => launch(solutionUrl),
        textColor: mainColor,
      ));
    });
    for (int i = 0; i < correctAnswers.length; i++) {
      setState(() {
        answersWidgets.add(new ListTile(
            title: Row(
              children: [
                new Text("Question ${i + 1}: "),
                new Padding(padding: EdgeInsets.all(4)),
                new Text(
                  "${submittedAnswers[i] == "0" ? "Not Answered" : submittedAnswers[i].toString().toUpperCase()}",
                  style: TextStyle(fontSize: 17),
                ),
                new Padding(padding: EdgeInsets.all(4)),
                new Visibility(
                    visible: submittedAnswers[i] != correctAnswers[i],
                    child: Text(
                      "(Correct Answer is ${correctAnswers[i].toString().toUpperCase()})",
                      style: TextStyle(fontSize: 17, color: Colors.red),
                    ))
              ],
            ),
            trailing: new Icon(
                submittedAnswers[i] == correctAnswers[i]
                    ? Icons.check_circle
                    : Icons.remove_circle,
                color: submittedAnswers[i] == correctAnswers[i]
                    ? Colors.green
                    : Colors.red)));
      });
    }
  }

  void confirmStart() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: currCardColor,
              title: new Text(
                "Start Exam",
                style: TextStyle(color: currTextColor),
              ),
              content: Container(
                  width: 500,
                  child: new Text(
                      "Are you sure you want to start the exam now?\n\nOnce you start the exam, you will not be able to leave until you are finished. If you click off the exam, your work will not be saved. Make sure that you have a 45 minute period to take the exam without any distractions.",
                      style: TextStyle(color: currTextColor))),
              actions: [
                new FlatButton(
                    child: new Text("CANCEL"),
                    textColor: mainColor,
                    onPressed: () {
                      router.pop(context);
                    }),
                new FlatButton(
                    child: new Text("START"),
                    textColor: mainColor,
                    onPressed: () {
                      stopwatch.start();
                      startTime = DateTime.now();
                      endTime = startTime.add(Duration(minutes: 45));
                      if (endTime.isAfter(DateTime.parse("2020-11-14 12:00")))
                        endTime = DateTime.parse("2020-11-14 12:00");
                      timer = new Timer.periodic(
                          const Duration(milliseconds: 500), (timer) {
                        if (stopwatch.isRunning) {
                          setState(() {});
                          if (endTime
                                      .difference(DateTime.now())
                                      .inMilliseconds <
                                  300000 &&
                              endTime
                                      .difference(DateTime.now())
                                      .inMilliseconds >
                                  300000 - 500) {
                            alert("5 minutes left to submit your test!");
                          }
                          if (endTime
                                      .difference(DateTime.now())
                                      .inMilliseconds <
                                  60000 &&
                              endTime
                                      .difference(DateTime.now())
                                      .inMilliseconds >
                                  60000 - 500) {
                            alert("1 minute left to submit your test!");
                          }
                          if (endTime
                                      .difference(DateTime.now())
                                      .inMilliseconds <
                                  10000 &&
                              endTime
                                      .difference(DateTime.now())
                                      .inMilliseconds >
                                  10000 - 500) {
                            alert(
                                "Your test will be automatically submitted in 10 seconds!");
                          }
                          if (endTime
                                      .difference(DateTime.now())
                                      .inMilliseconds <
                                  1000 &&
                              endTime
                                      .difference(DateTime.now())
                                      .inMilliseconds >
                                  1000 - 500) {
                            submitExam();
                          }
                        }
                      });
                      router.pop(context);
                    })
              ],
            ));
  }

  // void createExamForm() {
  //   for (int i = 0; i < myAnswers.length; i++) {
  //     examForm.add(new Row(
  //       children: <Widget>[
  //         new Text(
  //           "Question ${i+1}",
  //           style: TextStyle(fontWeight: FontWeight.normal, fontSize: 17.0),
  //         ),
  //         new Padding(padding: EdgeInsets.all(4)),
  //         new DropdownButton(
  //           value: myAnswers[i],
  //           items: [
  //             DropdownMenuItem(child: new Text("Select an answer choice"), value: null),
  //             DropdownMenuItem(child: new Text("A"), value: "a"),
  //             DropdownMenuItem(child: new Text("B"), value: "b"),
  //             DropdownMenuItem(child: new Text("C"), value: "c"),
  //             DropdownMenuItem(child: new Text("D"), value: "d"),
  //           ],
  //           onChanged: (value) {
  //             print(value);
  //             setState(() {
  //               myAnswers[i] = value;
  //             });
  //           },
  //         ),
  //       ],
  //     ));
  //     setState(() {});
  //   }
  // }

  void confirmSubmit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: currCardColor,
              title: new Text(
                "Submit Exam",
                style: TextStyle(color: currTextColor),
              ),
              content: new Text("Are you sure you want to submit the exam?",
                  style: TextStyle(color: currTextColor)),
              actions: [
                new FlatButton(
                    child: new Text("CANCEL"),
                    textColor: mainColor,
                    onPressed: () {
                      router.pop(context);
                    }),
                new FlatButton(
                    child: new Text("SUBMIT"),
                    textColor: mainColor,
                    onPressed: () {
                      router.pop(context);
                      submitExam();
                    })
              ],
            ));
  }

  void submitExam() {
    stopwatch.stop();
    timer.cancel();
    score = 0;
    print(myAnswers);
    print(correctAnswers);
    try {
      for (int i = 0; i < 50; i++) {
        if (myAnswers[i] == null) myAnswers[i] = "0";
        if (correctAnswers[i] == null) correctAnswers[i] = "0";
        if (myAnswers[i] == correctAnswers[i]) score++;
      }
      fb
          .database()
          .ref("conferences")
          .child(conference.conferenceID)
          .child("examScores")
          .child(currUser.userID)
          .set({
        "score": score,
        "startTime": startTime.toString(),
        "endTime": DateTime.now().toString(),
        "answers": myAnswers
      });
      html.window.location.reload();
    } catch (e) {
      alert("There was an error submitting your test $e");
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

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: new Visibility(
          visible: !taken && stopwatch.isRunning,
          child: FloatingActionButton.extended(
            label: new Text("SUBMIT"),
            onPressed: () => confirmSubmit(),
          )),
      backgroundColor: currBackgroundColor,
      body: Container(
        child: Column(
          children: [
            new Visibility(
                visible: taken || !stopwatch.isRunning, child: HomeNavbar()),
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 8.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Visibility(
                    visible: taken || !stopwatch.isRunning,
                    child: new FlatButton(
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
                                src: testUrl,
                                onLoaded: () {
                                  print('$key: Loaded: $testUrl');
                                },
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
                        child: new Column(
                          children: [
                            new Card(
                              child: new Container(
                                padding: EdgeInsets.all(16),
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    new Text(
                                      examName,
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
                                          "${currUser.firstName} ${currUser.lastName}",
                                          style: TextStyle(fontSize: 17),
                                        ),
                                        new Visibility(
                                            visible: taken,
                                            child: new Text("Score: $score/50",
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: mainColor,
                                                    fontFamily: "Gotham"))),
                                        new Visibility(
                                            visible:
                                                taken || stopwatch.isRunning,
                                            child: new Text(
                                                stopwatch.isRunning
                                                    ? "Time Remaining: ${_printDuration(endTime.difference(DateTime.now()))}"
                                                    : taken
                                                        ? "Completed in: ${_printDuration(endTime.difference(startTime))}"
                                                        : "",
                                                style: TextStyle(fontSize: 17)))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            new Padding(
                              padding: EdgeInsets.all(4),
                            ),
                            new Visibility(
                              visible: !taken && !stopwatch.isRunning,
                              child: new Card(
                                child: new InkWell(
                                  onTap: () {
                                    confirmStart();
                                  },
                                  child: new Container(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                        child: new Text(
                                      "START EXAM",
                                      style: TextStyle(
                                          fontSize: 17, color: mainColor),
                                    )),
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
                                      children: List<int>.generate(
                                              50, (i) => i + 1)
                                          .map((e) => new Row(
                                                children: <Widget>[
                                                  new Text(
                                                    "Question ${e}:",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 17.0),
                                                  ),
                                                  new Padding(
                                                      padding:
                                                          EdgeInsets.all(8)),
                                                  new DropdownButton(
                                                    value: myAnswers[e - 1],
                                                    items: [
                                                      DropdownMenuItem(
                                                          child: new Text(
                                                              "Select an answer choice"),
                                                          value: null),
                                                      DropdownMenuItem(
                                                          child: new Text(
                                                            "A",
                                                            style: TextStyle(
                                                                fontSize: 17),
                                                          ),
                                                          value: "a"),
                                                      DropdownMenuItem(
                                                          child: new Text("B",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      17)),
                                                          value: "b"),
                                                      DropdownMenuItem(
                                                          child: new Text("C",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      17)),
                                                          value: "c"),
                                                      DropdownMenuItem(
                                                          child: new Text("D",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      17)),
                                                          value: "d"),
                                                    ],
                                                    onChanged: (value) {
                                                      print(value);
                                                      setState(() {
                                                        myAnswers[e - 1] =
                                                            value;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ))
                                          .toList()),
                                )),
                              ),
                            ),
                            new Visibility(
                              visible: taken,
                              child: new Expanded(
                                child: new Card(
                                    child: new SingleChildScrollView(
                                  padding: EdgeInsets.all(16),
                                  child: new Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: answersWidgets),
                                )),
                              ),
                            )
                          ],
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

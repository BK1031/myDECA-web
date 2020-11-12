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

class MockConferenceWrittenJudgingPage extends StatefulWidget {
  String id;
  String writtenTeamID;
  MockConferenceWrittenJudgingPage(this.id, this.writtenTeamID);
  @override
  _MockConferenceWrittenJudgingPageState createState() => _MockConferenceWrittenJudgingPageState(this.id, this.writtenTeamID);
}

class _MockConferenceWrittenJudgingPageState extends State<MockConferenceWrittenJudgingPage> {

  final Storage _localStorage = html.window.localStorage;
  User currUser = User.plain();
  User student = User.plain();
  Conference conference = Conference.plain();

  String mockConferenceEvent = "";
  String selectedWritten = "";
  String writtenTeamID;

  DateTime startTime = DateTime.now();

  String writtenUrl = 'https://static.impression.co.uk/2014/05/loading1.gif';
  String guidelinesUrl = 'https://static.impression.co.uk/2014/05/loading1.gif';
  static ValueKey key = ValueKey('key_0');

  String zoomRoom = "";

  String eventName = "";
  String eventDesc = "";

  _MockConferenceWrittenJudgingPageState(String id, String writtenTeamID) {
    conference.conferenceID = id;
    this.writtenTeamID = writtenTeamID;
  }

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          writtenTeam.clear();
          print(currUser);
        });
        fb.database().ref("conferences").child(conference.conferenceID).once("value").then((value) {
          setState(() {
            conference = new Conference.fromSnapshot(value.snapshot);
          });
        });
        fb.database().ref("conferences").child(conference.conferenceID).child("users").child(currUser.userID).once("value").then((value) {
          if (value.snapshot.val()["written"] != null) {
            setState(() {
              writtenTeamID = value.snapshot.val()["written"];
            });
            getTeammates();
            fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(writtenTeamID).once("value").then((value) {
              if (value.snapshot.val()["written"] != null) {
                setState(() {
                  selectedWritten = value.snapshot.val()["written"];
                });
                mockConferenceEvents.forEach((key, value) {
                  if (value.contains(selectedWritten)) mockConferenceEvent = key;
                });
                fb.database().ref("events").child(selectedWritten).once("value").then((value) {
                  setState(() {
                    eventName = value.snapshot.val()["name"];
                    eventDesc = value.snapshot.val()["desc"];
                    guidelinesUrl = value.snapshot.val()["guidelines"];
                  });
                });
              }
              if (value.snapshot.val()["writtenUrl"] != null) {
                setState(() {
                  writtenUrl = value.snapshot.val()["writtenUrl"];
                });
              }
            });
            fb.database().ref("conferences").child(conference.conferenceID).child("eventSchedule").child(writtenTeamID).once("value").then((value) {
              setState(() {
                startTime = DateTime.parse(value.snapshot.val()["time"]);
                zoomRoom = value.snapshot.val()["url"];
              });
              fb.database().ref("users").child(value.snapshot.val()["judge"]).once("value").then((value) {
                setState(() {
                  student = User.fromSnapshot(value.snapshot);
                });
              });
            });
          }
        });
      });
    }
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

  void getTeammates() {
    writtenTeam.clear();
    fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(writtenTeamID).child("users").onChildAdded.listen((event) {
      fb.database().ref("users").child(event.snapshot.val()).once("value").then((value) {
        setState(() {
          writtenTeam.add(new User.fromSnapshot(value.snapshot));
        });
      });
    });
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
                    child: new Text("Back to ${conference.fullName}", style: TextStyle(color: mainColor, fontSize: 15),),
                    onPressed: () {
                      router.navigateTo(context, '/conferences/${conference.conferenceID}', transition: TransitionType.fadeIn);
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
                            Expanded(
                                child: EasyWebView(
                                    src: writtenUrl,
                                    onLoaded: () {
                                      print('$key: Loaded: $writtenUrl');
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
                        padding: EdgeInsets.only(left: 25, right: 25, top: 8, bottom: 25),
                        child: SingleChildScrollView(
                          child: new Column(
                            children: [
                              new Card(
                                child: new Container(
                                  padding: EdgeInsets.all(16),
                                  child: new Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      new Text(mockConferenceEvent, style: TextStyle(fontFamily: "Montserrat", fontSize: 25),),
                                      new Padding(padding: EdgeInsets.all(4),),
                                      new Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          new Text("$selectedWritten – $eventName", style: TextStyle(fontSize: 20),),
                                        ],
                                      ),
                                      new Padding(padding: EdgeInsets.all(8),),
                                      new Text("$eventDesc", style: TextStyle(fontSize: 17)),
                                      new Padding(padding: EdgeInsets.all(4),),
                                      new FlatButton(
                                        child: new Text("VIEW EVENT GUIDELINES"),
                                        onPressed: () => launch(guidelinesUrl),
                                        textColor: mainColor,
                                      ),
                                      new Padding(padding: EdgeInsets.all(8),),
                                      new Text("Team ID: $writtenTeamID", style: TextStyle(fontSize: 17)),
                                      new Padding(padding: EdgeInsets.all(4),),
                                      Row(
                                        children: writtenTeam.map((k) => Container(
                                          padding: EdgeInsets.only(right: 8),
                                          child: new Chip(
                                            label: new Text(k.firstName + " " + k.lastName, style: TextStyle(color: Colors.white)),
                                            backgroundColor: mainColor,
                                          ),
                                        )).toList(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              new Padding(padding: EdgeInsets.all(4),),
                              new Card(
                                child: new Container(
                                  padding: EdgeInsets.all(16),
                                  child: new Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              new Text("JUDGING", style: TextStyle(fontFamily: "Montserrat", fontSize: 25),),
                                              new Padding(padding: EdgeInsets.all(8),),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  new CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor: student.roles.length != 0 ? roleColors[student.roles.first] : currTextColor,
                                                    child: new ClipRRect(
                                                      borderRadius: new BorderRadius.all(Radius.circular(45)),
                                                      child: new CachedNetworkImage(
                                                        imageUrl: student.profileUrl,
                                                        height: 35,
                                                        width: 35,
                                                      ),
                                                    ),
                                                  ),
                                                  new Padding(padding: EdgeInsets.all(8),),
                                                  new Text("${student.firstName} ${student.lastName}", style: TextStyle(fontSize: 20),)
                                                ],
                                              ),
                                              new Text("${DateFormat("MMMd").format(startTime)} (${DateFormat("jm").format(startTime)} - ${DateFormat("jm").format(startTime.add(Duration(minutes: 10)))})", style: TextStyle(fontSize: 20, color: mainColor)),
                                            ],
                                          ),
                                          new Text("94/100", style: TextStyle(fontFamily: "Gotham", fontSize: 60, color: mainColor))
                                        ],
                                      ),
                                      new Padding(padding: EdgeInsets.all(8),),
                                      new Text("Judge Feedback:", style: TextStyle(fontSize: 20),),
                                      new Padding(padding: EdgeInsets.all(4),),
                                      new Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam egestas est ac efficitur tempus. Donec ac dictum nulla, ut dignissim nibh. Nunc iaculis purus ultrices nunc malesuada euismod.", style: TextStyle(fontSize: 17),),
                                      new Padding(padding: EdgeInsets.all(8),),
                                      new Text("Joining Instructions:\n\nWhen you join the zoom room, you will need to send a message similar to the following in the chat so that you can be moved into the correct breakout room for your judge.\n", style: TextStyle(fontSize: 17)),
                                      new SelectableText("Team ID: ${writtenTeamID} [${selectedWritten}] ${currUser.firstName} ${currUser.lastName}, Judge: ${student.firstName} ${student.lastName} @ ${DateFormat("jm").format(startTime)}", style: TextStyle(fontFamily: "Courier New", fontSize: 17),),
                                      new Padding(padding: EdgeInsets.all(8),),
                                      new Card(
                                        color: mainColor,
                                        child: new InkWell(
                                          onTap: () {

                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: new Center(
                                              child: new Text("JOIN JUDGING ROOM", style: TextStyle(color: Colors.white),),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    ),
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

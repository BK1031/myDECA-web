import 'dart:async';
import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:flutter/services.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:intl/intl.dart';
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/mock_conference_team.dart';
import 'package:mydeca_web/models/mock_conference_user.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'dart:math';
import 'package:mydeca_web/pages/conference/conference_media_page.dart';
import 'package:mydeca_web/pages/conference/conference_overview_page.dart';
import 'package:mydeca_web/pages/conference/conference_schedule_page.dart';
import 'package:mydeca_web/pages/conference/conference_winner_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';

import 'event_teammate_dialog.dart';

class MockConferenceDetailsPage extends StatefulWidget {
  String id;
  MockConferenceDetailsPage(this.id);
  @override
  _MockConferenceDetailsPageState createState() => _MockConferenceDetailsPageState(this.id);
}

class _MockConferenceDetailsPageState extends State<MockConferenceDetailsPage> {

  PageController _controller = PageController(initialPage: 0);
  int currPage = 0;
  final Storage _localStorage = html.window.localStorage;
  User currUser = User.plain();

  Conference conference = new Conference.plain();

  bool writtenRegistered = false;
  bool roleplayRegistered = false;
  String selectedRoleplay = "0";
  String selectedExam = "";
  String selectedWritten = "0";

  String writtenTeamID = "";
  String roleplayTeamID = "";

  String writtenUrl = "";
  bool examOpen = false;

  DateTime writtenTime = DateTime.now();
  DateTime roleplayTime = DateTime.now();

  String activeRegistrationTab = "Users";
  List<MockConferenceUser> usersTable = new List();
  List<MockConferenceTeam> teamsTable = new List();

  String activeTrackingTab = "Log";
  List<Widget> logWidgetList = new List();
  List<MockConferenceUser> userTracking = new List();
  List<MockConferenceTeam> rankTracking = new List();
  List<Widget> rankDisplayWidgets = new List();

  List<MockConferenceTeam> judgeTeams = new List();
  String judgeRoomUrl = "";

  Map<String, int> eventTotals = new Map();

  double uploadProgress = 0;

  _MockConferenceDetailsPageState(String id) {
    conference.conferenceID = id;
  }

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          writtenTeam.clear();
          roleplayTeam.clear();
          print(currUser);
        });
        fb.database().ref("conferences").child(conference.conferenceID).once("value").then((value) {
          setState(() {
            conference = new Conference.fromSnapshot(value.snapshot);
          });
        });
        getUsersTracking();
        fb.database().ref("conferences").child(conference.conferenceID).child("users").onChildAdded.listen((event) {
          MockConferenceUser mcUser = new MockConferenceUser();
          fb.database().ref("users").child(event.snapshot.key).once("value").then((value) async {
            mcUser.user = User.fromSnapshot(value.snapshot);
            if (event.snapshot.val()["written"] != null) {
              mcUser.writtenTeamID = event.snapshot.val()["written"];
              await fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(mcUser.writtenTeamID).once("value").then((value) {
                if (value.snapshot.val()["written"] != null) {
                  mcUser.writtenEvent = value.snapshot.val()["written"];
                  mockConferenceEvents.forEach((key, value) {
                    if (value.contains(mcUser.writtenEvent)) mcUser.writtenEvent += " - $key";
                  });
                }
                if (value.snapshot.val()["writtenUrl"] != null) {
                  mcUser.writtenUrl = value.snapshot.val()["writtenUrl"];
                }
              });
            }
            if (event.snapshot.val()["roleplay"] != null) {
              mcUser.roleplayTeamID = event.snapshot.val()["roleplay"];
              await fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(event.snapshot.val()["roleplay"]).once("value").then((value) {
                if (value.snapshot.val()["roleplay"] != null) {
                  mcUser.roleplayEvent = value.snapshot.val()["roleplay"];
                  mockConferenceEvents.forEach((key, value) {
                    if (value.contains(mcUser.roleplayEvent)) mcUser.roleplayEvent += " - $key";
                  });
                }
              });
            }
            setState(() {
              usersTable.add(mcUser);
              usersTable.sort((a, b) => a.user.firstName.compareTo(b.user.firstName));
            });
          });
        });
        fb.database().ref("conferences").child(conference.conferenceID).child("teams").onChildAdded.listen((team) async {
          MockConferenceTeam mcTeam = new MockConferenceTeam();
          mcTeam.teamID = team.snapshot.key;
          List<String> ids = team.snapshot.val()["users"].keys.toList();
          ids.forEach((element) {
            fb.database().ref("users").child(element).once("value").then((value) {
              mcTeam.users.add(new User.fromSnapshot(value.snapshot));
            });
          });
          fb.database().ref("conferences").child(conference.conferenceID).child("eventSchedule").child(mcTeam.teamID).once("value").then((value) {
            if (value.snapshot.val() != null) {
              fb.database().ref("users").child(value.snapshot.val()["judge"]).once("value").then((value) {
                mcTeam.judge = new User.fromSnapshot(value.snapshot);
              });
            }
          });
          if (team.snapshot.val()["written"] != null) {
            mcTeam.type = "Written";
            mcTeam.event = team.snapshot.val()["written"];
            mockConferenceEvents.forEach((key, value) {
              if (value.contains(mcTeam.event)) {
                mcTeam.event += " - $key";
                eventTotals[key] != null ? eventTotals[key]++ : eventTotals[key] = 1;
              }
            });
            if (team.snapshot.val()["writtenUrl"] != null) {
              mcTeam.writtenUrl = team.snapshot.val()["writtenUrl"];
            }
            if (team.snapshot.val()["scores"] != null) {
              mcTeam.score = team.snapshot.val()["scores"]["total"];
            }
          }
          else if (team.snapshot.val()["roleplay"] != null) {
            mcTeam.type = "Roleplay";
            mcTeam.event = team.snapshot.val()["roleplay"];
            mockConferenceEvents.forEach((key, value) {
              if (value.contains(mcTeam.event)) {
                mcTeam.event += " - $key";
                eventTotals[key] != null ? eventTotals[key]++ : eventTotals[key] = 1;
              }
            });
            if (team.snapshot.val()["scores"] != null) {
              mcTeam.score = team.snapshot.val()["scores"]["total"];
            }
          }
          setState(() {
            teamsTable.add(mcTeam);
          });
        });
        fb.database().ref("conferences").child(conference.conferenceID).child("examOpen").onValue.listen((event) {
          print("TEST OPEN: ${event.snapshot.val()}");
          setState(() {
            examOpen = event.snapshot.val();
          });
        });
        if (!currUser.roles.contains("Judge")) {
          fb.database().ref("conferences").child(conference.conferenceID).child("users").child(currUser.userID).once("value").then((value) {
            if (value.snapshot.val()["written"] != null) {
              setState(() {
                writtenRegistered = true;
                writtenTeamID = value.snapshot.val()["written"];
                print(writtenTeamID);
              });
              fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(writtenTeamID).once("value").then((value) {
                if (value.snapshot.val()["written"] != null) {
                  setState(() {
                    selectedWritten = value.snapshot.val()["written"];
                    print(selectedWritten);
                  });
                  // getTeammates("written");
                }
                if (value.snapshot.val()["writtenUrl"] != null) {
                  setState(() {
                    writtenUrl = value.snapshot.val()["writtenUrl"];
                  });
                }
              });
              getSchedule();
            }
            if (value.snapshot.val()["roleplay"] != null) {
              setState(() {
                roleplayRegistered = true;
                roleplayTeamID = value.snapshot.val()["roleplay"];
                print(roleplayTeamID);
              });
              fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(roleplayTeamID).once("value").then((value) {
                if (value.snapshot.val()["roleplay"] != null) {
                  setState(() {
                    selectedRoleplay = value.snapshot.val()["roleplay"];
                    print(selectedRoleplay);
                    roleplayExams.forEach((key, value) {
                      if (value.contains(selectedRoleplay)) selectedExam = key;
                    });
                  });
                  // getTeammates("roleplay");
                }
              });
              getSchedule();
            }
          });
        }
        else {
          fb.database().ref("conferences").child(conference.conferenceID).child("eventSchedule").onChildAdded.listen((event) {
            if (event.snapshot.val()["judge"] == currUser.userID) {
              print(event.snapshot.key);
              judgeRoomUrl = event.snapshot.val()["url"];
              MockConferenceTeam mcTeam = new MockConferenceTeam();
              mcTeam.judge = currUser;
              mcTeam.teamID = event.snapshot.key;
              mcTeam.startTime = DateTime.parse(event.snapshot.val()["time"]);
              fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(mcTeam.teamID).once("value").then((value) {
                List<String> ids = value.snapshot.val()["users"].keys.toList();
                ids.forEach((element) {
                  fb.database().ref("users").child(element).once("value").then((value) {
                    mcTeam.users.add(new User.fromSnapshot(value.snapshot));
                  });
                });
                if (value.snapshot.val()["written"] != null) {
                  mcTeam.type = "Written";
                  mcTeam.event = value.snapshot.val()["written"];
                  if (value.snapshot.val()["writtenUrl"] != null) {
                    mcTeam.writtenUrl = value.snapshot.val()["writtenUrl"];
                  }
                }
                else if (value.snapshot.val()["roleplay"] != null) {
                  mcTeam.type = "Roleplay";
                  mcTeam.event = value.snapshot.val()["roleplay"];
                }
                if (value.snapshot.val()["scores"] != null) {
                  mcTeam.score = value.snapshot.val()["scores"]["total"];
                }
                setState(() {
                 judgeTeams.add(mcTeam);
                 judgeTeams.sort((a, b) => a.startTime.compareTo(b.startTime));
                });
              });
            }
          });
        }
      });
    }
  }

  void getTeammates(String type) {
    if (type == "written") {
      writtenTeam.clear();
      fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(writtenTeamID).child("users").onChildAdded.listen((event) {
        fb.database().ref("users").child(event.snapshot.val()).once("value").then((value) {
          setState(() {
            writtenTeam.add(new User.fromSnapshot(value.snapshot));
          });
        });
      });
    }
    else if (type == "roleplay") {
      roleplayTeam.clear();
      fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(roleplayTeamID).child("users").onChildAdded.listen((event) {
        fb.database().ref("users").child(event.snapshot.val()).once("value").then((value) {
          setState(() {
            roleplayTeam.add(new User.fromSnapshot(value.snapshot));
          });
        });
      });
    }
  }

  void getSchedule() {
    if (writtenTeamID != "") {
      fb.database().ref("conferences").child(conference.conferenceID).child("eventSchedule").child(writtenTeamID).once("value").then((value) {
        setState(() {
          writtenTime = DateTime.parse(value.snapshot.val()["time"]);
        });
      });
    }
    if (roleplayTeamID != "") {
      fb.database().ref("conferences").child(conference.conferenceID).child("eventSchedule").child(roleplayTeamID).once("value").then((value) {
        setState(() {
          roleplayTime = DateTime.parse(value.snapshot.val()["time"]).subtract(Duration(minutes: 15));
        });
      });
    }
  }

  void getUsersTracking() {
    userTracking.clear();
    fb.database().ref("conferences").child(conference.conferenceID).child("users").onChildAdded.listen((event) {
      MockConferenceUser mcUser = new MockConferenceUser();
      fb.database().ref("users").child(event.snapshot.key).once("value").then((value) async {
        mcUser.user = User.fromSnapshot(value.snapshot);
        if (event.snapshot.val()["written"] != null) {
          mcUser.writtenTeamID = event.snapshot.val()["written"];
          await fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(mcUser.writtenTeamID).once("value").then((team) {
            if (team.snapshot.val()["written"] != null) {
              mcUser.writtenEvent = team.snapshot.val()["written"];
              mockConferenceEvents.forEach((key, value) {
                if (value.contains(mcUser.writtenEvent)) mcUser.writtenEvent += " - $key";
              });
              List<String> ids = team.snapshot.val()["users"].keys.toList();
              ids.forEach((element) {
                fb.database().ref("users").child(element).once("value").then((value) {
                  mcUser.writtenTeam.add(new User.fromSnapshot(value.snapshot));
                });
              });
            }
            if (team.snapshot.val()["writtenUrl"] != null) {
              mcUser.writtenUrl = team.snapshot.val()["writtenUrl"];
            }
            if (team.snapshot.val()["scores"] != null) {
              mcUser.writtenScore = team.snapshot.val()["scores"]["total"];
            }
          });
        }
        if (event.snapshot.val()["roleplay"] != null) {
          mcUser.roleplayTeamID = event.snapshot.val()["roleplay"];
          await fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(event.snapshot.val()["roleplay"]).once("value").then((team) {
            if (team.snapshot.val()["roleplay"] != null) {
              mcUser.roleplayEvent = team.snapshot.val()["roleplay"];
              roleplayExams.forEach((key, value) {
                if (value.contains(mcUser.roleplayEvent)) mcUser.testName = key;
              });
              mockConferenceEvents.forEach((key, value) {
                if (value.contains(mcUser.roleplayEvent)) mcUser.roleplayEvent += " - $key";
              });
              List<String> ids = team.snapshot.val()["users"].keys.toList();
              ids.forEach((element) {
                fb.database().ref("users").child(element).once("value").then((value) {
                  mcUser.roleplayTeam.add(new User.fromSnapshot(value.snapshot));
                });
              });
            }
            if (team.snapshot.val()["scores"] != null) {
              mcUser.roleplayScore = team.snapshot.val()["scores"]["total"];
            }
          });
          await fb.database().ref("conferences").child(conference.conferenceID).child("examScores").child(mcUser.user.userID).once("value").then((value) {
            if (value.snapshot.val() != null) {
              mcUser.testScore = value.snapshot.val()["score"];
            }
          });
        }
        setState(() {
          userTracking.add(mcUser);
          userTracking.sort((a, b) => a.user.firstName.compareTo(b.user.firstName));
        });
      });
    });
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
  
  void addTeammate(String type) {
    showDialog(
        context: context,
        child: new AlertDialog(
          backgroundColor: currCardColor,
          title: new Text("Add Teammate", style: TextStyle(color: currTextColor),),
          content: new EventTeammateDialog(type, currUser)
        )
    );
  }

  void confirmRegistration() {
    showDialog(
        context: context,
        child: new AlertDialog(
          backgroundColor: currCardColor,
          title: new Text("Confirm Registration", style: TextStyle(color: currTextColor),),
          content: new Text("Are you sure you want to register with the following events?\n\nWritten: $selectedWritten\nRoleplay: $selectedRoleplay\n\nYou will not be able to change events after you register.", style: TextStyle(color: currTextColor)),
          actions: [
            new FlatButton(
                child: new Text("CANCEL"),
                textColor: mainColor,
                onPressed: () {
                  router.pop(context);
                }
            ),
            new FlatButton(
                child: new Text("REGISTER"),
                textColor: mainColor,
                onPressed: () {
                  if (!writtenRegistered) {
                    fb.database().ref("conferences").child(conference.conferenceID).child("users").child(currUser.userID).update({
                      "written": writtenTeamID
                    });
                    fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(writtenTeamID).update({"written": selectedWritten});
                    writtenTeam.forEach((element) {
                      fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(writtenTeamID).child("users").child(element.userID).set(element.userID);
                      fb.database().ref("conferences").child(conference.conferenceID).child("users").child(element.userID).update({
                        "written": writtenTeamID
                      });
                    });
                    setState(() {
                      writtenRegistered = true;
                    });
                  }
                  if (!roleplayRegistered) {
                    fb.database().ref("conferences").child(conference.conferenceID).child("users").child(currUser.userID).update({
                      "roleplay": roleplayTeamID
                    });
                    fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(roleplayTeamID).update({"roleplay": selectedRoleplay});
                    roleplayTeam.forEach((element) {
                      fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(roleplayTeamID).child("users").child(element.userID).set(element.userID);
                      fb.database().ref("conferences").child(conference.conferenceID).child("users").child(element.userID).update({
                        "roleplay": roleplayTeamID
                      });
                    });
                    setState(() {
                      roleplayRegistered = true;
                    });
                  }
                  router.pop(context);
                }
            )
          ],
        )
    );
  }

  void exportTeamsCsv() {
    String teamsCsv = "Team ID,Team Members,Type,Event\n";
    teamsTable.forEach((element) {
      teamsCsv += "${element.teamID},";
      element.users.forEach((user) {
        teamsCsv += "${user.firstName} ${user.lastName} - ";
      });
      teamsCsv += ",${element.type},${element.event}\n";
    });
    print(teamsCsv);
    Clipboard.setData(new ClipboardData(text: teamsCsv));
  }

  void exportUserTrackingCsv() {
    String teamsCsv = "First Name,Last Name,Email,Written Event,Written Team,Written Score,Roleplay Event,Roleplay Team,Roleplay Score,Test,Test Score\n";
    userTracking.forEach((element) {
      teamsCsv += "${element.user.firstName},${element.user.lastName},${element.user.email},${element.writtenEvent},";
      element.writtenTeam.forEach((user) {
        teamsCsv += "${user.firstName} ${user.lastName} - ";
      });
      teamsCsv += ",${element.writtenScore},${element.roleplayEvent},";
      element.roleplayTeam.forEach((user) {
        teamsCsv += "${user.firstName} ${user.lastName} - ";
      });
      teamsCsv += ",${element.roleplayScore},${element.testName},${element.testScore}\n";
    });
    print(teamsCsv);
    Clipboard.setData(new ClipboardData(text: teamsCsv));
  }

  void exportRankings() {
    String teamsCsv = "Team ID,Judge,Members,Type,Event,Score\n";
    rankTracking.forEach((element) {
      teamsCsv += "${element.teamID},${element.judge.firstName} ${element.judge.lastName},";
      element.users.forEach((user) {
        teamsCsv += "${user.firstName} ${user.lastName} - ";
      });
      teamsCsv += ",${element.type},${element.event},${element.score}\n";
    });
    print(teamsCsv);
    Clipboard.setData(new ClipboardData(text: teamsCsv));
  }

  _startFilePicker() async {
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files.length == 1) {
        final file = files[0];
        final reader = new FileReader();
        reader.onLoadEnd.listen((e) async {
          setState(() {
            uploadProgress = 20;
          });
          await fb.storage().ref("conferences/2020-VC-Mock/writtens/$writtenTeamID.pdf").put(file).future.then((fb.UploadTaskSnapshot snapshot) async {
            await Future.delayed(const Duration(seconds: 1));
            var downUrl = await snapshot.ref.getDownloadURL();
            setState(() {
              writtenUrl = downUrl.toString();
              uploadProgress = 100;
            });
            print(writtenUrl);
            fb.database().ref("conferences").child(conference.conferenceID).child("teams").child(writtenTeamID).child("writtenUrl").set(writtenUrl);
          });
        });
        reader.readAsDataUrl(file);
      }
      else {
        alert("Please make sure that the file you are submitting is less than 25mb and is a PDF.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        child: new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HomeNavbar(),
              new Stack(
                fit: StackFit.passthrough,
                alignment: Alignment.center,
                children: <Widget>[
                  new ClipRRect(
                    child: new CachedNetworkImage(
                      placeholder: (context, url) => new Container(
                        child: new GlowingProgressIndicator(
                          child: new Image.asset('images/deca-diamond.png', height: 75.0,),
                        ),
                      ),
                      imageUrl: conference.imageUrl,
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  new Container(
                    width: MediaQuery.of(context).size.width,
                    height: 400,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  new Container(
                    height: 350,
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new FlatButton(
                                child: new Text("Back to Conferences", style: TextStyle(color: mainColor, fontSize: 15),),
                                onPressed: () {
                                  router.navigateTo(context, '/conferences', transition: TransitionType.fadeIn);
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.all(16),
                            child: new Text(
                              "${conference.fullName.toUpperCase()}",
                              style: TextStyle(fontFamily: "Montserrat", fontSize: 40, color: Colors.white),
                            )
                        ),
                      ],
                    ),
                  )
                ],
              ),
              new Padding(padding: EdgeInsets.all(8.0)),
              Container(
                  padding: EdgeInsets.only(top: 8),
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: Row(
                    children: [
                      new Expanded(
                        child: Container(
                          child: new Text(
                            "${conference.desc}",
                            style: TextStyle(fontSize: 17, color: currTextColor),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            new Icon(Icons.event, size: 80, color: mainColor,),
                            new Text(
                              "${conference.date}",
                              style: TextStyle(fontFamily: "Montserrat",fontSize: 25, color: currTextColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
              ),
              new Padding(padding: EdgeInsets.only(bottom: 8.0)),
              new Visibility(
                visible: !(writtenRegistered || roleplayRegistered) && !currUser.roles.contains("Judge"),
                child: new Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Card(
                    child: new Container(
                      padding: EdgeInsets.all(16),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text("Sorry, you just missed it!", style: TextStyle(fontFamily: "Montserrat", fontSize: 25),),
                          new Padding(padding: EdgeInsets.all(4),),
                          new Text("Registration for this mock conference has closed, and you are not registered. If you believe this is an error, please contact us.", style: TextStyle(fontSize: 17))
                        ]
                      ),
                    ),
                  ),
                ),
              ),
              new Visibility(
                visible: currUser.roles.contains("Judge"),
                child: new Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Card(
                    child: new Container(
                      padding: EdgeInsets.all(16),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              new Row(
                                children: [
                                  new Icon(Icons.dashboard),
                                  new Padding(padding: EdgeInsets.all(4)),
                                  new Text("DASHBOARD", style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor),)
                                ],
                              ),
                              new RaisedButton(
                                child: new Text("JOIN JUDGING ROOM"),
                                color: mainColor,
                                textColor: Colors.white,
                                onPressed: () {
                                  launch(judgeRoomUrl);
                                },
                              ),
                            ],
                          ),
                          new Padding(padding: EdgeInsets.only(top: 8, bottom: 16), child: new Divider(color: currDividerColor, height: 8)),
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: judgeTeams.map((team) => Container(
                              padding: EdgeInsets.only(bottom: 8),
                              width: double.infinity,
                              child: new Card(
                                child: new InkWell(
                                  onTap: () {
                                    if (team.type == "Written") {
                                      router.navigateTo(context, "/conferences/${conference.conferenceID}/written/${team.teamID}/judging", transition: TransitionType.fadeIn);
                                    }
                                    else {
                                      router.navigateTo(context, "/conferences/${conference.conferenceID}/roleplay/${team.teamID}/judging", transition: TransitionType.fadeIn);
                                    }
                                  },
                                  child: new Container(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        new Expanded(
                                          child: new Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              new Text("${DateFormat("jm").format(team.startTime)} - ${DateFormat("jm").format(team.startTime.add(Duration(minutes: 10)))}", style: TextStyle(fontSize: 25, color: mainColor)),
                                              new Padding(padding: EdgeInsets.all(4),),
                                              new Text("Team ID: ${team.teamID}  •  ${team.event} (${team.type})", style: TextStyle(fontSize: 17),),
                                              new Padding(padding: EdgeInsets.all(4),),
                                              new Row(
                                                children: team.users.map((k) => Container(
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
                                        new Visibility(
                                          visible: team.score != null,
                                          child: new Container(
                                            padding: EdgeInsets.all(16),
                                            child: new Text("${team.score}/100", style: TextStyle(color: mainColor, fontSize: 25, fontFamily: "Gotham"),),
                                          ),
                                        ),
                                        new Icon(Icons.arrow_forward_ios, color: mainColor,)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )).toList()
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              new Visibility(
                visible: (writtenRegistered || roleplayRegistered),
                child: new Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Card(
                    child: new Container(
                      padding: EdgeInsets.all(16),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Row(
                            children: [
                              new Icon(Icons.dashboard),
                              new Padding(padding: EdgeInsets.all(4)),
                              new Text("DASHBOARD", style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor),)
                            ],
                          ),
                          new Padding(padding: EdgeInsets.only(top: 8, bottom: 16), child: new Divider(color: currDividerColor, height: 8)),
                          new ListTile(
                            title: new Text(selectedExam),
                            leading: new Text("11:00 AM", style: TextStyle(color: mainColor, fontFamily: "Gotham"),),
                            trailing: new Text(examOpen ? "START NOW" : "NOT OPEN", style: TextStyle(color: examOpen ? mainColor : Colors.grey),),
                            onTap: examOpen ? () {
                              router.navigateTo(context, "/conferences/${conference.conferenceID}/testing", replace: true, clearStack: true, transition: TransitionType.fadeIn);
                            } : null,
                          ),
                          new Visibility(
                            visible: writtenTeamID != "" && writtenTime.isBefore(roleplayTime),
                            child: new ListTile(
                              title: new Text("Written Presentation – " + selectedWritten),
                              leading: new Text(DateFormat("jm").format(writtenTime), style: TextStyle(color: mainColor, fontFamily: "Gotham"),),
                              trailing: new Icon(Icons.arrow_forward_ios, color: mainColor,),
                              onTap: () {
                                router.navigateTo(context, "/conferences/${conference.conferenceID}/written", transition: TransitionType.fadeIn);
                              },
                            ),
                          ),
                          new Visibility(
                            visible: roleplayTeamID != "" ,
                            child: new ListTile(
                              title: new Text("Roleplay Presentation – " + selectedRoleplay),
                              leading: new Text(DateFormat("jm").format(roleplayTime), style: TextStyle(color: mainColor, fontFamily: "Gotham"),),
                              trailing: new Icon(Icons.arrow_forward_ios, color: mainColor,),
                              onTap: () {
                                router.navigateTo(context, "/conferences/${conference.conferenceID}/roleplay", transition: TransitionType.fadeIn);
                              },
                            ),
                          ),
                          new Visibility(
                            visible: writtenTeamID != ""  && writtenTime.isAfter(roleplayTime),
                            child: new ListTile(
                              title: new Text("Written Presentation – " + selectedWritten),
                              leading: new Text(DateFormat("jm").format(writtenTime), style: TextStyle(color: mainColor, fontFamily: "Gotham"),),
                              trailing: new Icon(Icons.arrow_forward_ios, color: mainColor,),
                              onTap: () {
                                router.navigateTo(context, "/conferences/${conference.conferenceID}/written", transition: TransitionType.fadeIn);
                              },
                            ),
                          ),
                          new Visibility(
                            visible: writtenTeamID != ""  && writtenTime.isAtSameMomentAs(roleplayTime),
                            child: new ListTile(
                              title: new Text("Written Presentation – " + selectedWritten + " (conflict with roleplay)", style: TextStyle(color: Colors.red)),
                              leading: new Text(DateFormat("jm").format(writtenTime), style: TextStyle(color: Colors.red, fontFamily: "Gotham"),),
                              trailing: new Icon(Icons.arrow_forward_ios, color: mainColor,),
                              onTap: () {
                                router.navigateTo(context, "/conferences/${conference.conferenceID}/written", transition: TransitionType.fadeIn);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              new Visibility(
                visible: (writtenRegistered || roleplayRegistered),
                child: new Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Card(
                    child: new Container(
                      padding: EdgeInsets.all(16),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new Text("You're all set!", style: TextStyle(fontSize: 30, fontFamily: "Montserrat"),),
                          new Padding(padding: EdgeInsets.all(4),),
                          Center(
                            child: Row(
                              children: [
                                new Icon(Icons.check_circle_outline, size: 30, color: mainColor,),
                                new Padding(padding: EdgeInsets.all(4),),
                                new Text("Register for conference", style: TextStyle(fontSize: 17),)
                              ],
                            ),
                          ),
                          new Padding(padding: EdgeInsets.all(4),),
                          new Visibility(
                            visible: writtenUrl != "",
                            child: Center(
                              child: Row(
                                children: [
                                  new Icon(Icons.check_circle_outline, size: 30, color: mainColor,),
                                  new Padding(padding: EdgeInsets.all(4),),
                                  new Text("Submit written report", style: TextStyle(fontSize: 17),),
                                  new Padding(padding: EdgeInsets.all(8),),
                                  new RaisedButton(
                                    child: new Text("VIEW SUBMISSION"),
                                    color: mainColor,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      launch(writtenUrl);
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                          new Visibility(
                            visible: uploadProgress != 100 && uploadProgress != 0,
                            child: new Container(
                                padding: EdgeInsets.all(16.0),
                                child: new HeartbeatProgressIndicator(
                                  child: new Image.asset(
                                    'images/deca-diamond.png',
                                    height: 20.0,
                                  ),
                                )
                            ),
                          ),
                          new OutlineButton(
                            onPressed: () {
                              if (writtenUrl != "") alert("Are you sure you want to upload another file? This will overwrite your current submission.");
                              setState(() {
                                uploadProgress = 0;
                              });
                              _startFilePicker();
                            },
                            child: Container(
                              width: 150,
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new Icon(Icons.file_upload),
                                  new Text("Upload Written"),
                                ],
                              ),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          ),
                          new Padding(padding: EdgeInsets.all(4),),
                          Container(width: 350, child: Center(child: new Text("You are registered for this conference! Don't forget to turn in your written here by Nov 10, 11:59 pm. Your written report must be a PDF file and less than 25mb in size.", style: TextStyle(fontSize: 17), textAlign: TextAlign.center,))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              new Padding(padding: EdgeInsets.only(bottom: 8.0)),
              new Visibility(
                visible: currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("Officer"),
                // visible: false,
                child: new Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Card(
                    child: new Container(
                      padding: EdgeInsets.all(16),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Row(
                            children: [
                              new Icon(Icons.track_changes),
                              new Padding(padding: EdgeInsets.all(4)),
                              new Text("CONFERENCE TRACKER", style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor),)
                            ],
                          ),
                          new Padding(padding: EdgeInsets.only(top: 8, bottom: 16), child: new Divider(color: currDividerColor, height: 8)),
                          Container(
                              padding: EdgeInsets.only(top: 8),
                              width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: new FlatButton(
                                      child: new Text("AUDIT LOG", style: TextStyle(fontFamily: "Montserrat", color: activeTrackingTab == "Log" ? Colors.white : currTextColor)),
                                      color: activeTrackingTab == "Log" ? mainColor : null,
                                      onPressed: () {
                                        setState(() {
                                          activeTrackingTab = "Log";
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: new FlatButton(
                                      child: new Text("USERS (${userTracking.length})", style: TextStyle(fontFamily: "Montserrat", color: activeTrackingTab == "User" ? Colors.white : currTextColor)),
                                      color: activeTrackingTab == "User" ? mainColor : null,
                                      onPressed: () {
                                        getUsersTracking();
                                        setState(() {
                                          activeTrackingTab = "User";
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )
                          ),
                          new Padding(padding: EdgeInsets.all(8)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              new FlatButton(
                                child: new Text("REFRESH"),
                                textColor: mainColor,
                                onPressed: () {
                                  if (activeTrackingTab == "User") {
                                    getUsersTracking();
                                  }
                                }
                              ),
                              new FlatButton(
                                child: new Text("COPY CSV"),
                                textColor: mainColor,
                                onPressed: () {
                                  if (activeTrackingTab == "User") {
                                    exportUserTrackingCsv();
                                  }
                                },
                              ),
                            ],
                          ),
                          activeTrackingTab == "User" ? new Scrollbar(
                            child: new SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: new DataTable(
                                  columns: [
                                    DataColumn(label: Text('First Name', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Last Name', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Written Event', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Written Team', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Written Score', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Roleplay Event', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Roleplay Team', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Roleplay Score', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Exam Name', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Exam Score', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                  ],
                                  rows: userTracking.map((e) => DataRow(cells: [
                                    DataCell(Text(e.user.firstName, style: TextStyle(fontSize: 17))),
                                    DataCell(Text(e.user.lastName, style: TextStyle(fontSize: 17))),
                                    DataCell(Text(e.writtenEvent != "" ? e.writtenEvent : "Not Registered", style: TextStyle(fontSize: 17, color: e.writtenEvent != "" ? currTextColor : Colors.red))),
                                    DataCell(Row(
                                      children: e.writtenTeam.map((k) => Container(
                                        padding: EdgeInsets.only(right: 8),
                                        child: new Chip(
                                          label: new Text(k.firstName + " " + k.lastName, style: TextStyle(color: Colors.white)),
                                          backgroundColor: mainColor,
                                        ),
                                      )).toList(),
                                    )),
                                    DataCell(Text("${e.writtenScore}/100", style: TextStyle(fontSize: 17, color: currTextColor))),
                                    DataCell(Text(e.roleplayEvent != "" ? e.roleplayEvent : "Not Registered", style: TextStyle(fontSize: 17, color: e.roleplayEvent != "" ? currTextColor : Colors.red))),
                                    DataCell(Row(
                                      children: e.roleplayTeam.map((k) => Container(
                                        padding: EdgeInsets.only(right: 8),
                                        child: new Chip(
                                          label: new Text(k.firstName + " " + k.lastName, style: TextStyle(color: Colors.white)),
                                          backgroundColor: mainColor,
                                        ),
                                      )).toList(),
                                    )),
                                    DataCell(Text("${e.roleplayScore}/100", style: TextStyle(fontSize: 17, color: currTextColor))),
                                    DataCell(Text(e.testName, style: TextStyle(fontSize: 17))),
                                    DataCell(Text("${e.testScore}/50", style: TextStyle(fontSize: 17))),
                                  ])).toList()
                              ),
                            ),
                          ) : activeRegistrationTab == "Ranking" ? new Scrollbar(
                            child: new Column(
                              children: rankDisplayWidgets,
                            ),
                          ) : new Container(
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                new Text("Total Users: ${usersTable.length}", style: TextStyle(fontSize: 17),),
                                new Text("Total Teams: ${teamsTable.length}", style: TextStyle(fontSize: 17),),
                                new Padding(padding: EdgeInsets.all(4)),
                                new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: eventTotals.entries.map((entry) => new Text(
                                    "${entry.key}: ${entry.value}", style: TextStyle(fontSize: 17),
                                  )).toList(),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              new Padding(padding: EdgeInsets.only(bottom: 8.0)),
              new Visibility(
                visible: currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("Officer"),
                // visible: false,
                child: new Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Card(
                    child: new Container(
                      padding: EdgeInsets.all(16),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Row(
                            children: [
                              new Icon(Icons.analytics),
                              new Padding(padding: EdgeInsets.all(4)),
                              new Text("REGISTRATION", style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor),)
                            ],
                          ),
                          new Padding(padding: EdgeInsets.only(top: 8, bottom: 16), child: new Divider(color: currDividerColor, height: 8)),
                          Container(
                              padding: EdgeInsets.only(top: 8),
                              width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: new FlatButton(
                                      child: new Text("USERS (${usersTable.length})", style: TextStyle(fontFamily: "Montserrat", color: activeRegistrationTab == "Users" ? Colors.white : currTextColor)),
                                      color: activeRegistrationTab == "Users" ? mainColor : null,
                                      onPressed: () {
                                        setState(() {
                                          activeRegistrationTab = "Users";
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: new FlatButton(
                                      child: new Text("TEAMS (${teamsTable.length})", style: TextStyle(fontFamily: "Montserrat", color: activeRegistrationTab == "Teams" ? Colors.white : currTextColor)),
                                      color: activeRegistrationTab == "Teams" ? mainColor : null,
                                      onPressed: () {
                                        setState(() {
                                          activeRegistrationTab = "Teams";
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: new FlatButton(
                                      child: new Text("BREAKDOWN", style: TextStyle(fontFamily: "Montserrat", color: activeRegistrationTab == "Breakdown" ? Colors.white : currTextColor)),
                                      color: activeRegistrationTab == "Breakdown" ? mainColor : null,
                                      onPressed: () {
                                        setState(() {
                                          activeRegistrationTab = "Breakdown";
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              )
                          ),
                          new Padding(padding: EdgeInsets.all(8)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              new FlatButton(
                                child: new Text("COPY CSV"),
                                textColor: mainColor,
                                onPressed: () {
                                  exportTeamsCsv();
                                },
                              ),
                            ],
                          ),
                          activeRegistrationTab == "Users" ? new Scrollbar(
                            child: new SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: new DataTable(
                                columns: [
                                  DataColumn(label: Text('First Name', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                  DataColumn(label: Text('Last Name', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                  DataColumn(label: Text('Written Event', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                  DataColumn(label: Text(' ', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                  DataColumn(label: Text('Roleplay Event', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                ],
                                rows: usersTable.map((e) => DataRow(cells: [
                                  DataCell(Text(e.user.firstName, style: TextStyle(fontSize: 17))),
                                  DataCell(Text(e.user.lastName, style: TextStyle(fontSize: 17))),
                                  DataCell(Text(e.writtenEvent != "" ? e.writtenEvent : "Not Registered", style: TextStyle(fontSize: 17, color: e.writtenEvent != "" ? currTextColor : Colors.red))),
                                  DataCell(e.writtenUrl != "" ? Tooltip(message: "Written submitted!\n (click to view)", child: new InkWell(onTap: () => launch(e.writtenUrl), child: Icon(Icons.check_circle, color: mainColor))) : new Container()),
                                  DataCell(Text(e.roleplayEvent != "" ? e.roleplayEvent : "Not Registered", style: TextStyle(fontSize: 17, color: e.roleplayEvent != "" ? currTextColor : Colors.red))),
                                ])).toList()
                              ),
                            ),
                          ) : activeRegistrationTab == "Teams" ? new Scrollbar(
                            child: new SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: new DataTable(
                                  columns: [
                                    DataColumn(label: Text('Team ID', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Team Members', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Type', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text('Event', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                    DataColumn(label: Text(' ', style: TextStyle(fontFamily: "Montserrat", fontSize: 17))),
                                  ],
                                  rows: teamsTable.map((e) => DataRow(cells: [
                                    DataCell(Text(e.teamID, style: TextStyle(fontSize: 17))),
                                    DataCell(Row(
                                      children: e.users.map((k) => Container(
                                        padding: EdgeInsets.only(right: 8),
                                        child: new Chip(
                                          label: new Text(k.firstName + " " + k.lastName, style: TextStyle(color: Colors.white)),
                                          backgroundColor: mainColor,
                                        ),
                                      )).toList(),
                                    )),
                                    DataCell(Text(e.type, style: TextStyle(fontSize: 17))),
                                    DataCell(Text(e.event, style: TextStyle(fontSize: 17))),
                                    DataCell(e.writtenUrl != "" ? Tooltip(message: "Written submitted!\n (click to view)", child: new InkWell(onTap: () => launch(e.writtenUrl), child: Icon(Icons.check_circle, color: mainColor))) : new Text(" . ", style: TextStyle(color: Colors.red, fontSize: 17),)),
                                  ])).toList()
                              ),
                            ),
                          ) : new Container(
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                new Text("Total Users: ${usersTable.length}", style: TextStyle(fontSize: 17),),
                                new Text("Total Teams: ${teamsTable.length}", style: TextStyle(fontSize: 17),),
                                new Padding(padding: EdgeInsets.all(4)),
                                new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: eventTotals.entries.map((entry) => new Text(
                                    "${entry.key}: ${entry.value}", style: TextStyle(fontSize: 17),
                                  )).toList(),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              new Padding(padding: EdgeInsets.only(bottom: 8.0)),
              Container(
                  padding: EdgeInsets.only(top: 8),
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: new FlatButton(
                          child: new Text("OVERVIEW", style: TextStyle(fontFamily: "Montserrat", color: currPage == 0 ? Colors.white : currTextColor)),
                          color: currPage == 0 ? mainColor : null,
                          onPressed: () {
                            setState(() {
                              currPage = 0;
                              _controller.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: new FlatButton(
                          child: new Text("SCHEDULE", style: TextStyle(fontFamily: "Montserrat", color: currPage == 1 ? Colors.white : currTextColor)),
                          color: currPage == 1 ? mainColor : null,
                          onPressed: () {
                            setState(() {
                              currPage = 1;
                              _controller.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: new FlatButton(
                          child: new Text("WINNERS", style: TextStyle(fontFamily: "Montserrat", color: currPage == 2 ? Colors.white : currTextColor)),
                          color: currPage == 2 ? mainColor : null,
                          onPressed: () {
                            setState(() {
                              currPage = 2;
                              _controller.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: new FlatButton(
                          child: new Text("MEDIA", style: TextStyle(fontFamily: "Montserrat", color: currPage == 3 ? Colors.white : currTextColor)),
                          color: currPage == 3 ? mainColor : null,
                          onPressed: () {
                            setState(() {
                              currPage = 3;
                              _controller.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                            });
                          },
                        ),
                      ),
                    ],
                  )
              ),
              Container(
                  padding: EdgeInsets.only(top: 16),
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  height: 500,
                  child: new PageView(
                    controller: _controller,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Container(
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  padding: new EdgeInsets.only(top: 4.0, bottom: 4.0),
                                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                                  child: new Text(
                                      "RESOURCES",
                                      style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                                  )
                              ),
                              new InkWell(
                                onTap: () {
                                  html.window.open("https://mydeca.org/#/home/announcements", "Alerts");
                                },
                                child: new ListTile(
                                  title: new Text("Announcements", style: TextStyle(color: currTextColor, fontSize: 18),),
                                  trailing: new Icon(
                                    Icons.arrow_forward_ios,
                                    color: mainColor,
                                  ),
                                ),
                              ),
                              new InkWell(
                                onTap: () {
                                  html.window.open("https://docs.google.com/document/d/1hXVtGV3eb3DJrUKrudHDLG8Ro-G6YS4hhChv0sZpyQk/edit?usp=sharing", "Communication Document");
                                },
                                child: new ListTile(
                                  title: new Text("Communication Document", style: TextStyle(color: currTextColor, fontSize: 18),),
                                  trailing: new Icon(
                                    Icons.arrow_forward_ios,
                                    color: mainColor,
                                  ),
                                ),
                              ),
                              new InkWell(
                                onTap: () {
                                  html.window.open("https://docs.mydeca.org/user/mock-conference", "Documentation");
                                },
                                child: new ListTile(
                                  title: new Text("Documentation", style: TextStyle(color: currTextColor, fontSize: 18),),
                                  trailing: new Icon(
                                    Icons.arrow_forward_ios,
                                    color: mainColor,
                                  ),
                                ),
                              ),
                              new InkWell(
                                onTap: () {
                                  html.window.open("https://us02web.zoom.us/j/81202379649?pwd=dHFxYjB6YkRyN3pkbTR4OUN4VFlkUT09", "Support Room");
                                },
                                child: new ListTile(
                                  title: new Text("Support Room", style: TextStyle(color: currTextColor, fontSize: 18),),
                                  trailing: new Icon(
                                    Icons.arrow_forward_ios,
                                    color: mainColor,
                                  ),
                                ),
                              ),
                            ],
                          )
                      ),
                      ConferenceSchedulePage(conference.conferenceID),
                      ConferenceWinnersPage(conference.conferenceID),
                      ConferenceMediaPage(conference.conferenceID)
                    ],
                  )
              ),
              new Container(height: 50)
            ],
          ),
        ),
      ),
    );
  }
}

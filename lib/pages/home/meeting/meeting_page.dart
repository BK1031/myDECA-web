import 'dart:html';
import 'dart:html' as html;
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mydeca_web/models/meeting.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingPage extends StatefulWidget {
  @override
  _MeetingPageState createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {

  final Storage _localStorage = html.window.localStorage;
  User currUser = User.plain();

  List<Widget> currentMeetingList = new List();
  List<Widget> pastMeetingList = new List();
  List<Widget> upcomingMeetingList = new List();

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
        getMeetings();
      });
    }
  }

  void getMeetings() {
    fb.database().ref("chapters").child(currUser.chapter.chapterID).child("meetings").onChildAdded.listen((event) {
      Meeting meeting = new Meeting.fromSnapshot(event.snapshot);
      if (meeting.startTime.isAfter(DateTime.now())) {
        // Meeting upcoming
        setState(() {
          upcomingMeetingList.add(new Container(
            padding: EdgeInsets.only(bottom: 8),
            child: new Card(
              child: new InkWell(
                onTap: () {
                  router.navigateTo(context, "/home/meetings/details?id=${meeting.id}", transition: TransitionType.fadeIn);
                },
                child: new Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  child: Row(
                    children: [
                      new Expanded(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            new Text(
                              meeting.name,
                              style: TextStyle(fontSize: 18, fontFamily: "Montserrat"),
                            ),
                            new Text(
                              "${DateFormat().add_yMMMd().format(meeting.startTime)} @ ${DateFormat().add_jm().format(meeting.startTime)}",
                              style: TextStyle(fontSize: 17, color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: new Icon(Icons.arrow_forward_ios, color: mainColor,)
                      )
                    ],
                  ),
                ),
              ),
            ),
          ));
        });
      }
      else if (meeting.startTime.isBefore(DateTime.now()) && meeting.endTime.isAfter(DateTime.now()) ) {
        // Meeting ongoing
        setState(() {
          currentMeetingList.add(new Container(
            padding: EdgeInsets.only(bottom: 8),
            child: new Card(
              shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: new BorderSide(color: mainColor, width: 2.0)),
              child: new InkWell(
                onTap: () {
                  router.navigateTo(context, "/home/meetings/details?id=${meeting.id}", transition: TransitionType.fadeIn);
                },
                child: new Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  child: Row(
                    children: [
                      new Expanded(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            new Text(
                              meeting.name,
                              style: TextStyle(fontSize: 18, fontFamily: "Montserrat"),
                            ),
                            new Text(
                              "${DateFormat().add_yMMMd().format(meeting.startTime)} @ ${DateFormat().add_jm().format(meeting.startTime)}",
                              style: TextStyle(fontSize: 17, color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                      new Visibility(
                        visible: meeting.url != "",
                        child: Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: new RaisedButton(
                            child: new Text("JOIN"),
                            textColor: Colors.white,
                            color: mainColor,
                            onPressed: () {
                              launch(meeting.url);
                            },
                          ),
                        ),
                      ),
                      new Visibility(
                        visible: meeting.url == "",
                        child: Container(
                            padding: EdgeInsets.only(left: 8, right: 8),
                            child: new Icon(Icons.arrow_forward_ios, color: mainColor,)
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ));
        });
      }
      else {
        // Meeting past
        setState(() {
          pastMeetingList.add(new Container(
            padding: EdgeInsets.only(bottom: 8),
            child: new Card(
              child: new InkWell(
                onTap: () {
                  router.navigateTo(context, "/home/meetings/details?id=${meeting.id}", transition: TransitionType.fadeIn);
                },
                child: new Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  child: Row(
                    children: [
                      new Expanded(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            new Text(
                              meeting.name,
                              style: TextStyle(fontSize: 18, fontFamily: "Montserrat"),
                            ),
                            new Text(
                              "${DateFormat().add_yMMMd().format(meeting.startTime)} @ ${DateFormat().add_jm().format(meeting.startTime)}",
                              style: TextStyle(fontSize: 17, color: Colors.grey),
                            )
                          ],
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: new Icon(Icons.arrow_forward_ios, color: mainColor,)
                      )
                    ],
                  ),
                ),
              ),
            ),
          ));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorage["userID"] != null) {
      return new Scaffold(
        floatingActionButton: new Visibility(
          visible: currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("Officer"),
          child: new FloatingActionButton(
            child: new Icon(Icons.add),
            onPressed: () {
              router.navigateTo(context, "/home/meetings/new", transition: TransitionType.fadeIn);
            },
          ),
        ),
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
                        child: new Text("Back to Home", style: TextStyle(color: mainColor, fontSize: 15),),
                        onPressed: () {
                          router.navigateTo(context, '/home', transition: TransitionType.fadeIn);
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: new EdgeInsets.all(4.0),
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Text(
                        "CURRENT",
                        style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                    )
                ),
                new Padding(padding: EdgeInsets.only(bottom: 16.0)),
                new Visibility(
                    visible: currentMeetingList.isEmpty,
                    child: new Text("Nothing to see here!\nCheck back later for more meetings.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
                ),
                Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: currentMeetingList,
                  ),
                ),
                Container(
                    padding: new EdgeInsets.all(4.0),
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Text(
                        "UPCOMING",
                        style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                    )
                ),
                new Padding(padding: EdgeInsets.only(bottom: 16.0)),
                new Visibility(
                    visible: upcomingMeetingList.isEmpty,
                    child: new Text("Nothing to see here!\nCheck back later for more meetings.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
                ),
                Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: upcomingMeetingList,
                  ),
                ),
                Container(
                    padding: new EdgeInsets.all(4.0),
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Text(
                        "PAST",
                        style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                    )
                ),
                new Padding(padding: EdgeInsets.only(bottom: 16.0)),
                new Visibility(
                    visible: pastMeetingList.isEmpty,
                    child: new Text("Nothing to see here!\nCheck back later for more meetings.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
                ),
                Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: pastMeetingList,
                  ),
                ),
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

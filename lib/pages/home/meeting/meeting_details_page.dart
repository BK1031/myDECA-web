import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:mydeca_web/models/announcement.dart';
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/meeting.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/pages/home/announcement/announcement_confirm_dialog.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

class MeetingDetailsPage extends StatefulWidget {
  @override
  _MeetingDetailsPageState createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  final Storage _localStorage = html.window.localStorage;
  Meeting meeting = new Meeting();

  User currUser = User.plain();

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
        });
        if (html.window.location.toString().contains("?id=")) {

        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorage["userID"] != null) {
      return new Scaffold(
        floatingActionButton: new FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: new Text("CREATE"),
          onPressed: () {
            if (fb.auth().currentUser != null) {
              if (meeting.name != "" && meeting.startTime != null && meeting.endTime != null) {
                fb.database().ref("chapters").child(currUser.chapter.chapterID).child("meetings").push().set({
                  "name": meeting.name,
                  "startTime": meeting.startTime.toString(),
                  "endTime": meeting.endTime.toString(),
                  "url": meeting.url
                });
                router.navigateTo(context, '/home/meetings', transition: TransitionType.fadeIn);
              }
              else {
                html.window.alert("Please make sure that you fill out all the fields!");
              }
            }
            else {
              html.window.alert("AuthToken expired. Please login again.");
            }
          },
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
                        child: new Text("Back to Meetings", style: TextStyle(color: mainColor, fontSize: 15),),
                        onPressed: () {
                          router.navigateTo(context, '/home/meetings', transition: TransitionType.fadeIn);
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new TextField(
                    maxLines: 1,
                    onChanged: (input) {
                      setState(() {
                        meeting.name = input;
                      });
                    },
                    decoration: InputDecoration(
                        labelText: "Meeting Name",
                        border: InputBorder.none
                    ),
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 30, color: currTextColor),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    height: 1000,
                    child: new Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 8),
                              child: new Text(
                                "Start Time",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            new Expanded(
                              child: DateTimeField(
                                format: DateFormat("yyyy-MM-dd HH:mm"),
                                onChanged: (date) {
                                  print("Set start $date");
                                  meeting.startTime = date;
                                },
                                onShowPicker: (context, currentValue) async {
                                  final date = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(1900),
                                      initialDate: currentValue ?? DateTime.now(),
                                      lastDate: DateTime(2100));
                                  if (date != null) {
                                    final time = await showTimePicker(
                                      initialEntryMode: TimePickerEntryMode.input,
                                      context: context,
                                      initialTime:
                                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                    );
                                    return DateTimeField.combine(date, time);
                                  } else {
                                    return currentValue;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 8),
                              child: new Text(
                                "End Time",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            new Expanded(
                              child: DateTimeField(
                                format: DateFormat("yyyy-MM-dd HH:mm"),
                                onChanged: (date) {
                                  print("Set end $date");
                                  meeting.endTime = date;
                                },
                                onShowPicker: (context, currentValue) async {
                                  final date = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(1900),
                                      initialDate: currentValue ?? DateTime.now(),
                                      lastDate: DateTime(2100));
                                  if (date != null) {
                                    final time = await showTimePicker(
                                      initialEntryMode: TimePickerEntryMode.input,
                                      context: context,
                                      initialTime:
                                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                    );
                                    return DateTimeField.combine(date, time);
                                  } else {
                                    return currentValue;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        new Padding(padding: EdgeInsets.all(4)),
                        Container(
                          child: new TextField(
                            decoration: InputDecoration(
                                hintText: "Meeting URL (optional)"
                            ),
                            onChanged: (input) {
                              meeting.url = input;
                            },
                          ),
                        ),
                      ],
                    )
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
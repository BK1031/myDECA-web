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
import 'package:flutter/src/painting/text_style.dart' as ts;
class NewMeetingPage extends StatefulWidget {
  @override
  _NewMeetingPageState createState() => _NewMeetingPageState();
}

class _NewMeetingPageState extends State<NewMeetingPage> {
  final Storage _localStorage = html.window.localStorage;
  Meeting meeting = new Meeting();
  List<String> topics = [];
  double visibilityBoxHeight = 0.0;
  User currUser = User.plain();

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

  @override
  Widget build(BuildContext context) {
    if (_localStorage["userID"] != null) {
      return new Scaffold(
        floatingActionButton: new FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: new Text("CREATE"),
          onPressed: () {
            if (fb.auth().currentUser != null) {
              if (meeting.name != "" &&
                  meeting.startTime != null &&
                  meeting.endTime != null &&
                  topics.isNotEmpty) {
                fb
                    .database()
                    .ref("chapters")
                    .child(currUser.chapter.chapterID)
                    .child("meetings")
                    .push()
                    .set({
                  "name": meeting.name,
                  "startTime": meeting.startTime.toString(),
                  "endTime": meeting.endTime.toString(),
                  "url": meeting.url,
                  "topics": topics,
                  "attendance": "",
                });
                router.navigateTo(context, '/home/meetings',
                    transition: TransitionType.fadeIn);
              } else {
                alert(
                    "Please make sure that you fill out all the fields! Don't forget to select the meeting recipients.");
              }
            } else {
              alert("AuthToken expired. Please login again.");
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
                  width: (MediaQuery.of(context).size.width > 1300)
                      ? 1100
                      : MediaQuery.of(context).size.width - 50,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new FlatButton(
                        child: new Text(
                          "Back to Meetings",
                          style: TextStyle(color: mainColor, fontSize: 15),
                        ),
                        onPressed: () {
                          router.navigateTo(context, '/home/meetings',
                              transition: TransitionType.fadeIn);
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  width: (MediaQuery.of(context).size.width > 1300)
                      ? 1100
                      : MediaQuery.of(context).size.width - 50,
                  child: new TextField(
                    maxLines: 1,
                    onChanged: (input) {
                      setState(() {
                        meeting.name = input;
                      });
                    },
                    decoration: InputDecoration(
                        labelText: "Meeting Name", border: InputBorder.none),
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 30,
                        color: currTextColor),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                    width: (MediaQuery.of(context).size.width > 1300)
                        ? 1100
                        : MediaQuery.of(context).size.width - 50,
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
                                      initialDate:
                                          currentValue ?? DateTime.now(),
                                      lastDate: DateTime(2100));
                                  if (date != null) {
                                    final time = await showTimePicker(
                                      initialEntryMode:
                                          TimePickerEntryMode.input,
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          currentValue ?? DateTime.now()),
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
                                      initialDate:
                                          currentValue ?? DateTime.now(),
                                      lastDate: DateTime(2100));
                                  if (date != null) {
                                    final time = await showTimePicker(
                                      initialEntryMode:
                                          TimePickerEntryMode.input,
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          currentValue ?? DateTime.now()),
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
                                hintText: "Meeting URL (optional)"),
                            onChanged: (input) {
                              meeting.url = input;
                            },
                          ),
                        ),
                        new Padding(padding: EdgeInsets.all(4)),
                        new ListTile(
                          leading: new Icon(Icons.group_add),
                          title: new Text("Select Recipients"),
                          onTap: () {
                            setState(() {
                              if (visibilityBoxHeight == 0.0) {
                                visibilityBoxHeight = 400;
                              } else {
                                visibilityBoxHeight = 0.0;
                              }
                            });
                          },
                        ),
                        new AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: visibilityBoxHeight,
                            child: new Scrollbar(
                              child: new ListView(
                                padding:
                                    EdgeInsets.only(right: 16.0, left: 16.0),
                                children: <Widget>[
                                  new Text(
                                      "Only users with the roles selected below will receive this meeting."),
                                  new ListTile(
                                    leading: topics.contains("Member")
                                        ? Icon(Icons.check_box,
                                            color: mainColor)
                                        : Icon(Icons.check_box_outline_blank,
                                            color: Colors.grey),
                                    title: new Text("Member"),
                                    onTap: () {
                                      setState(() {
                                        topics.contains("Member")
                                            ? topics.remove("Member")
                                            : topics.add("Member");
                                      });
                                    },
                                  ),
                                  new ListTile(
                                    leading: topics.contains("Officer")
                                        ? Icon(Icons.check_box,
                                            color: mainColor)
                                        : Icon(Icons.check_box_outline_blank,
                                            color: Colors.grey),
                                    title: new Text("Officer"),
                                    onTap: () {
                                      setState(() {
                                        topics.contains("Officer")
                                            ? topics.remove("Officer")
                                            : topics.add("Officer");
                                      });
                                    },
                                  ),
                                  new ListTile(
                                    leading: topics.contains("President")
                                        ? Icon(Icons.check_box,
                                            color: mainColor)
                                        : Icon(Icons.check_box_outline_blank,
                                            color: Colors.grey),
                                    title: new Text("President"),
                                    onTap: () {
                                      setState(() {
                                        topics.contains("President")
                                            ? topics.remove("President")
                                            : topics.add("President");
                                      });
                                    },
                                  ),
                                  new ListTile(
                                    leading: topics.contains("Advisor")
                                        ? Icon(Icons.check_box,
                                            color: mainColor)
                                        : Icon(Icons.check_box_outline_blank,
                                            color: Colors.grey),
                                    title: new Text("Advisor"),
                                    onTap: () {
                                      setState(() {
                                        topics.contains("Advisor")
                                            ? topics.remove("Advisor")
                                            : topics.add("Advisor");
                                      });
                                    },
                                  ),
                                  new ListTile(
                                    leading: topics.contains("Developer")
                                        ? Icon(Icons.check_box,
                                            color: mainColor)
                                        : Icon(Icons.check_box_outline_blank,
                                            color: Colors.grey),
                                    title: new Text("Developer"),
                                    onTap: () {
                                      setState(() {
                                        topics.contains("Developer")
                                            ? topics.remove("Developer")
                                            : topics.add("Developer");
                                      });
                                    },
                                  ),
                                  new Visibility(
                                    visible: topics.contains("Member") &&
                                        !topics.contains("Advisor"),
                                    child: new Card(
                                      color: Color(0xFFffebba),
                                      child: new Container(
                                        padding: EdgeInsets.all(8),
                                        child: new Row(
                                          children: [
                                            new Icon(
                                              Icons.warning,
                                              color: Colors.orangeAccent,
                                            ),
                                            new Padding(
                                                padding: EdgeInsets.all(4)),
                                            new Text(
                                              "Advisors are not given the\nMember role by default, so\nyour advisors may not recieve\nthis announcement.",
                                              style: TextStyle(
                                                  color: Colors.orangeAccent),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    )),
              ],
            ),
          ),
        ),
      );
    } else {
      return LoginPage();
    }
  }
}

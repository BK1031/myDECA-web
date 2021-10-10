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

import 'package:url_launcher/url_launcher.dart';

class MeetingDetailsPage extends StatefulWidget {
  @override
  _MeetingDetailsPageState createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  final Storage _localStorage = html.window.localStorage;
  Meeting meeting = new Meeting();
  User currUser = User.plain();
  String dropdownValue = "";
  bool editing = false;

  TextEditingController nameController = new TextEditingController();
  TextEditingController urlController = new TextEditingController();

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
          setDropDown();
        });
      });
    } else {
      dropdownValue = "Not Present";
    }
  }

  void setDropDown() {
    if (html.window.location.toString().contains("?id=")) {
      fb
          .database()
          .ref("chapters")
          .child(currUser.chapter.chapterID)
          .child("meetings")
          .child(html.window.location.toString().split("?id=")[1])
          .once("value")
          .then((value) {
        setState(() {
          meeting = new Meeting.fromSnapshot(value.snapshot);
          nameController.text = meeting.name;
          urlController.text = meeting.url;
          if (meeting.attendance.contains(currUser.email)) {
            int index = meeting.attendance.indexOf(currUser.email);
            index += (currUser.email.length + 1);
            while (meeting.attendance[index] != ",") {
              dropdownValue += meeting.attendance[index];
              index++;
            }
          } else {
            dropdownValue = "Not Present";
          }
        });
      });
    } else {
      dropdownValue = "Not Present";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorage["userID"] != null) {
      return new Scaffold(
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
                      new TextButton(
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
                new Visibility(
                  visible: !editing,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: (MediaQuery.of(context).size.width > 1300)
                        ? 1100
                        : MediaQuery.of(context).size.width - 50,
                    child: new Text(
                      meeting.name,
                      style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: 30,
                          color: currTextColor),
                    ),
                  ),
                ),
                new Visibility(
                  visible: editing,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: (MediaQuery.of(context).size.width > 1300)
                        ? 1100
                        : MediaQuery.of(context).size.width - 50,
                    child: new TextField(
                      controller: nameController,
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
                ),
                Container(
                    padding: EdgeInsets.only(left: 16),
                    width: (MediaQuery.of(context).size.width > 1300)
                        ? 1100
                        : MediaQuery.of(context).size.width - 50,
                    child: Row(
                      children: [
                        new Visibility(
                          visible: DateTime.now().isAfter(meeting.startTime) &&
                              DateTime.now().isBefore(meeting.endTime),
                          child: new Tooltip(
                            message: "This meeting is currently ongoing",
                            child: new Card(
                              color: mainColor,
                              child: new Container(
                                padding: EdgeInsets.only(
                                    left: 8, top: 4, bottom: 4, right: 8),
                                child: new Text(
                                  "LIVE",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        new Visibility(
                            visible: currUser.roles.contains("Developer") ||
                                currUser.roles.contains("Advisor") ||
                                currUser.roles.contains("Officer"),
                            child: new TextButton(
                              child: new Text("EDIT MEETING"),
                              style: TextButton.styleFrom(
                                primary: mainColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  editing = true;
                                });
                              },
                            ))
                      ],
                    )),
                new Visibility(
                  visible: !editing,
                  child: Container(
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
                                  "Start Time:",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              new Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(right: 8),
                                  child: new Text(
                                    DateFormat().format(meeting.startTime),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 8),
                                child: new Text(
                                  "End Time:",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              new Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(right: 8),
                                  child: new Text(
                                    DateFormat().format(meeting.endTime),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 8),
                                child: new Text(
                                  "Meeting URL:",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              new Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(right: 8),
                                  child: new InkWell(
                                    onTap: () => launch(meeting.url),
                                    child: new Text(
                                      meeting.url,
                                      style: TextStyle(
                                          fontSize: 17, color: mainColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(children: [
                            Visibility(
                              visible:
                                  DateTime.now().isAfter(meeting.startTime) &&
                                      DateTime.now().isBefore(meeting.endTime),
                              child: Container(
                                padding: EdgeInsets.only(top: 8),
                                child: DropdownButton<String>(
                                  value: dropdownValue,
                                  icon: const Icon(Icons.arrow_downward),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(
                                      color: (dropdownValue == "Not Present"
                                          ? Colors.red
                                          : Colors.blue)),
                                  underline: Container(
                                    height: 2,
                                    color: (dropdownValue == "Not Present"
                                        ? Colors.redAccent
                                        : Colors.blueAccent),
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      if (dropdownValue == 'Not Present') {
                                        dropdownValue = newValue;
                                        fb
                                            .database()
                                            .ref("chapters")
                                            .child(currUser.chapter.chapterID)
                                            .child("meetings")
                                            .child(meeting.id)
                                            .update({
                                          "attendance": meeting.attendance +
                                              currUser.email +
                                              ":" +
                                              dropdownValue +
                                              ","
                                        });
                                      }
                                    });
                                  },
                                  items: <String>[
                                    'Football Stadium',
                                    'G106',
                                    'G107',
                                    'G110',
                                    'Not Present'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ])
                        ],
                      )),
                ),
                new Visibility(
                  visible: editing,
                  child: Container(
                      padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                      width: (MediaQuery.of(context).size.width > 1300)
                          ? 1100
                          : MediaQuery.of(context).size.width - 50,
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
                                  initialValue: meeting.startTime,
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
                                  initialValue: meeting.endTime,
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
                          new Visibility(
                            visible: editing,
                            child: Container(
                              child: new TextField(
                                controller: urlController,
                                decoration: InputDecoration(
                                    hintText: "Meeting URL (optional)"),
                                onChanged: (input) {
                                  meeting.url = input;
                                },
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
                new Visibility(
                    visible: editing,
                    child: Container(
                        padding: EdgeInsets.all(16),
                        width: (MediaQuery.of(context).size.width > 1300)
                            ? 1100
                            : MediaQuery.of(context).size.width - 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            new TextButton(
                              child: new Text("DELETE MEETING"),
                              style: TextButton.styleFrom(primary: Colors.red),
                              onPressed: () {
                                setState(() {
                                  editing = false;
                                });
                                fb
                                    .database()
                                    .ref("chapters")
                                    .child(currUser.chapter.chapterID)
                                    .child("meetings")
                                    .child(html.window.location
                                        .toString()
                                        .split("?id=")[1])
                                    .remove();
                                router.navigateTo(context, "/home/meetings",
                                    transition: TransitionType.fadeIn,
                                    replace: true);
                              },
                            ),
                            Row(
                              children: [
                                new TextButton(
                                  child: new Text("CANCEL"),
                                  style: TextButton.styleFrom(
                                    primary: mainColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      editing = false;
                                    });
                                    router.navigateTo(context,
                                        "/home/meetings/details?id=${html.window.location.toString().split("?id=")[1]}",
                                        transition: TransitionType.fadeIn,
                                        replace: true);
                                  },
                                ),
                                new ElevatedButton(
                                  child: new Text("SAVE CHANGES"),
                                  style: ElevatedButton.styleFrom(
                                    primary: mainColor,
                                    onPrimary: Colors.white,
                                  ),
                                  onPressed: () {
                                    fb
                                        .database()
                                        .ref("chapters")
                                        .child(currUser.chapter.chapterID)
                                        .child("meetings")
                                        .child(html.window.location
                                            .toString()
                                            .split("?id=")[1])
                                        .set({
                                      "name": meeting.name,
                                      "startTime": meeting.startTime.toString(),
                                      "endTime": meeting.endTime.toString(),
                                      "url": meeting.url
                                    });
                                    setState(() {
                                      editing = false;
                                    });
                                    router.navigateTo(context,
                                        "/home/meetings/details?id=${html.window.location.toString().split("?id=")[1]}",
                                        transition: TransitionType.fadeIn,
                                        replace: true);
                                  },
                                )
                              ],
                            ),
                          ],
                        ))),
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

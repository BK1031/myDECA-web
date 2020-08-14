import 'dart:html';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:intl/intl.dart';
import 'package:mydeca_web/models/announcement.dart';
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/handbook.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

class ManageHandbookPage extends StatefulWidget {
  @override
  _ManageHandbookPageState createState() => _ManageHandbookPageState();
}

class _ManageHandbookPageState extends State<ManageHandbookPage> {

  final Storage _localStorage = html.window.localStorage;
  List<Widget> handbookWidgetList = new List();
  List<Widget> taskWidgetList = new List();
  User currUser = User.plain();
  bool editing = false;
  bool editingTask = false;

  Handbook newHandbook = new Handbook.plain();
  String tempTask = "";

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
      });
      fb.database().ref("chapters").child(currUser.chapter.chapterID).child("handbooks").onValue.listen((event) {
        updateHandbooks();
      });
    }
  }

  void updateNewHandbook() {
    setState(() {
      taskWidgetList.clear();
    });
    for (int i = 0; i < newHandbook.tasks.length; i++) {
      setState(() {
        taskWidgetList.add(
            new ListTile(
              leading: Icon(Icons.check_box_outline_blank),
              title: new Text(newHandbook.tasks[i]),
              trailing: new IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  newHandbook.tasks.removeAt(i);
                  updateNewHandbook();
                },
              )
            )
        );
      });
    }
  }

  void updateHandbooks() {
    setState(() {
      handbookWidgetList.clear();
    });
    fb.database().ref("chapters").child(currUser.chapter.chapterID).child("handbooks").onChildAdded.listen((event) {
      Handbook handbook = new Handbook.fromSnapshot(event.snapshot);
      List<Widget> taskList = new List();
      for (int i = 0; i < handbook.tasks.length; i++) {
        taskList.add(
            new ListTile(
                leading: Icon(Icons.check_box_outline_blank),
                title: new Text(handbook.tasks[i]),
            )
        );
      }
      setState(() {
        handbookWidgetList.add(
          new Card(
            child: Container(
              padding: EdgeInsets.all(16),
              child: new Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      new Text(
                        handbook.name,
                        style: TextStyle(fontSize: 18),
                      ),
                      new RaisedButton(
                        color: Colors.red,
                        child: Text("DELETE"),
                        onPressed: () {
                          if (currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("President")) {
                            fb.database().ref("chapters").child(currUser.chapter.chapterID).child("handbooks").child(handbook.handbookID).remove();
                          }
                        },
                      )
                    ],
                  ),
                  Column(
                    children: taskList,
                  ),
                ],
              ),
            ),
          ),
        );
      });
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
              router.navigateTo(context, "/home/announcements/new", transition: TransitionType.fadeIn);
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
                        "HANDBOOKS",
                        style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                    )
                ),
                new Padding(padding: EdgeInsets.only(bottom: 16.0)),
                new Visibility(
                  visible: editing,
                  child: Container(
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Card(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: new Column(
                          children: [
                            new TextField(
                              decoration: InputDecoration(
                                  labelText: "Handbook Name"
                              ),
                              style: TextStyle(fontSize: 18),
                              onChanged: (input) {
                                newHandbook.name = input;
                              },
                            ),
                            Column(
                              children: taskWidgetList,
                            ),
                            new Visibility(
                              visible: editingTask,
                              child: Container(
                                height: 75,
                                child: new Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    new Expanded(
                                      child: new TextField(
                                        decoration: InputDecoration(
                                            labelText: "Task Name"
                                        ),
                                        autofocus: true,
                                        onChanged: (input) {
                                          tempTask = input;
                                          print(tempTask);
                                        },
                                      ),
                                    ),
                                    Container(
                                      child: new RaisedButton(
                                        color: mainColor,
                                        child: new Text("ADD"),
                                        textColor: Colors.white,
                                        onPressed: () {
                                          setState(() {
                                            newHandbook.tasks.add(tempTask);
                                            editingTask = false;
                                          });
                                          updateNewHandbook();
                                        },
                                      ),
                                    ),
                                    new IconButton(
                                      icon: new Icon(Icons.clear, color: Colors.grey,),
                                      onPressed: () {
                                        setState(() {
                                          editingTask = false;
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ),
                            new Visibility(
                              visible: !editingTask,
                              child: new ListTile(
                                onTap: () {
                                  setState(() {
                                    editingTask = true;
                                  });
                                },
                                leading: new Icon(Icons.add, color: mainColor,),
                                title: new Text("New Item", style: TextStyle(color: mainColor),),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                new FlatButton(
                                  child: new Text("CANCEL", style: TextStyle(color: mainColor),),
                                  onPressed: () {
                                    setState(() {
                                      editing = false;
                                    });
                                  },
                                ),
                                new FlatButton(
                                  child: new Text("CREATE", style: TextStyle(color: mainColor),),
                                  onPressed: () {
                                    if (currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("President")) {
                                      fb.database().ref("chapters").child(currUser.chapter.chapterID).child("handbooks").push().set({
                                        "name": newHandbook.name,
                                        "tasks": newHandbook.tasks
                                      });
                                      // Reset new handbook
                                      setState(() {
                                        editingTask = false;
                                        editing = false;
                                      });
                                      newHandbook = new Handbook.plain();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                new Visibility(
                    visible: (handbookWidgetList.length == 0 && !editing),
                    child: new Text("Nothing to see here!\nCreate a new handbook below.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
                ),
                Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: handbookWidgetList,
                  ),
                ),
                new Padding(padding: EdgeInsets.only(bottom: 16.0)),
                new Visibility(
                  visible: !editing,
                  child: Container(
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Card(
                      child: new ListTile(
                        onTap: () {
                          setState(() {
                            editing = true;
                          });
                        },
                        leading: new Icon(Icons.add, color: mainColor,),
                        title: new Text("New Handbook", style: TextStyle(color: mainColor),),
                      ),
                    ),
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

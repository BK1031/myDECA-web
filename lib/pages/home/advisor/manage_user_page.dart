import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/pages/home/advisor/manage_group_dialog.dart';
import 'package:mydeca_web/pages/home/advisor/manage_user_roles_dialog.dart';
import 'package:mydeca_web/pages/home/advisor/new_group_dialog.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;
import 'package:progress_indicators/progress_indicators.dart';

class ManageUserPage extends StatefulWidget {
  @override
  _ManageUserPageState createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {

  final Storage _localStorage = html.window.localStorage;
  User currUser = User.plain();

  List<Widget> usersWidgetList = new List();
  List<Widget> groupsWidgetList = new List();

  void manageRolesDialog(User user, User currUser) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Update Roles", style: TextStyle(color: currTextColor),),
            backgroundColor: currCardColor,
            content: new ManageUserRolesDialog(user, currUser),
          );
        }
    );
  }

  void manageGroupDialog(User currUser, String id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Update Group", style: TextStyle(color: currTextColor),),
            backgroundColor: currCardColor,
            content: new ManageGroupDialog(id, currUser),
          );
        }
    );
  }

  void newGroupDialog(User currUser) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Create Group", style: TextStyle(color: currTextColor),),
            backgroundColor: currCardColor,
            content: new NewGroupDialog(currUser),
          );
        }
    );
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
        fb.database().ref("users").onValue.listen((event) {
          updateUsers();
        });
        fb.database().ref("chapters").child(currUser.chapter.chapterID).child("groups").onValue.listen((event) {
          updateGroups();
        });
      });
    }
  }
  
  void updateUsers() {
    setState(() {
      usersWidgetList.clear();
    });
    fb.database().ref("users").onChildAdded.listen((event) {
      User user = new User.fromSnapshot(event.snapshot);
      if (user.chapter.chapterID == currUser.chapter.chapterID) {
        // In same chapter
        List<Widget> rolesList = new List();
        user.roles.forEach((element) {
          rolesList.add(new Card(
            color: roleColors[element],
            child: new Container(
              padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
              child: new Text(element, style: TextStyle(color: Colors.white),),
            ),
          ));
        });
        setState(() {
          usersWidgetList.add(new Container(
            padding: EdgeInsets.only(bottom: 8),
            child: new InkWell(
              onTap: () {
                manageRolesDialog(user, currUser);
              },
              child: new Card(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: new Row(
                    children: [
                      new CircleAvatar(
                        radius: 25,
                        backgroundColor: roleColors[user.roles.first],
                        child: new ClipRRect(
                          borderRadius: new BorderRadius.all(Radius.circular(45)),
                          child: new CachedNetworkImage(
                            imageUrl: user.profileUrl,
                            height: 45,
                            width: 45,
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(8),),
                      new Column(
                        children: [
                          new Text(
                              user.firstName + " " + user.lastName
                          ),
                          new Text(
                              user.email
                          )
                        ],
                      ),
                      new Padding(padding: EdgeInsets.all(8),),
                      new Wrap(
                        direction: Axis.horizontal,
                        children: rolesList
                      ),
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
  
  void updateGroups() {
    setState(() {
      groupsWidgetList.clear();
    });
    fb.database().ref("chapters").child(currUser.chapter.chapterID).child("groups").onChildAdded.listen((event) {
      setState(() {
        groupsWidgetList.add(new Card(
          child: new ListTile(
            onTap: () {
              manageGroupDialog(currUser, event.snapshot.key);
            },
            title: new Text(event.snapshot.val(), style: TextStyle(color: currTextColor),),
            subtitle: new Text(event.snapshot.key),
          ),
        ));
      });
    });
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
                new Container(
                  padding: new EdgeInsets.only(top: 4.0, bottom: 4.0),
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Expanded(
                        flex: 2,
                        child: new Column(
                          children: [
                            new Container(
                              padding: new EdgeInsets.only(left: 16),
                              child: new Card(
                                elevation: 2.0,
                                child: new Container(
                                  color: currCardColor,
                                  padding: new EdgeInsets.all(16),
                                  child: new Column(
                                    children: [
                                      new Row(
                                        children: [
                                          new Icon(Icons.person),
                                          new Padding(padding: EdgeInsets.all(4)),
                                          new Text("USERS", style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor),)
                                        ],
                                      ),
                                      new Container(padding: EdgeInsets.only(top: 8, bottom: 16), child: new Divider(color: currDividerColor, height: 8)),
                                      new Column(
                                        children: usersWidgetList,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(8)),
                      new Expanded(
                        flex: 1,
                        child: new Column(
                          children: [
                            new Container(
                              padding: new EdgeInsets.only(right: 16),
                              child: new Card(
                                elevation: 2.0,
                                child: new Container(
                                  color: currCardColor,
                                  padding: new EdgeInsets.all(16),
                                  child: new Column(
                                    children: [
                                      new Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          new Icon(Icons.group),
                                          new Padding(padding: EdgeInsets.all(4)),
                                          new Text("MENTOR GROUPS", style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor),)
                                        ],
                                      ),
                                      new Container(padding: EdgeInsets.only(top: 8, bottom: 16), child: new Divider(color: currDividerColor, height: 8)),
                                      new Column(
                                        children: groupsWidgetList,
                                      ),
                                      new Visibility(
                                        visible: currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("President"),
                                        child: new Card(
                                          child: new ListTile(
                                            onTap: () {
                                              newGroupDialog(currUser);
                                            },
                                            leading: new Icon(Icons.add, color: mainColor,),
                                            title: new Text("New Group", style: TextStyle(color: mainColor),),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
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

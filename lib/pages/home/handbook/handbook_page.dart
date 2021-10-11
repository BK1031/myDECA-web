import 'dart:html';
import 'dart:html' as html;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:intl/intl.dart';
import 'package:mydeca_web/models/handbook_item.dart';
import 'package:mydeca_web/models/user_handbook.dart';
import '../../../models/handbook.dart';
import '../../../models/user.dart';
import '../../../navbars/home_navbar.dart';
import '../../../utils/config.dart';
import '../../../utils/theme.dart';
import '../../auth/login_page.dart';
import 'package:flutter/src/painting/text_style.dart' as ts;
class HandbookPage extends StatefulWidget {
  @override
  _HandbookPageState createState() => _HandbookPageState();
}

class _HandbookPageState extends State<HandbookPage> {

  final Storage _localStorage = html.window.localStorage;

  User currUser = User.plain();

  double height = 0.0;
  String selectedGroupID = "";
  String selectedGroup = "";
  bool hasHandbook = false;
  List<Widget> groupsList = new List();
  List<UserHandbook> handbookList = new List();

  @override
  void initState() {
    super.initState();
    if (_localStorage.containsKey("userID")) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
        });
        updateGroups();
      });
    }
  }

  void updateGroups() {
    fb.database().ref("chapters").child(currUser.chapter.chapterID).child("groups").onChildAdded.listen((event) {
      if (currUser.roles.contains("Advisor") || currUser.roles.contains("President") || currUser.roles.contains("Developer") || currUser.groups.contains(event.snapshot.key)) {
        setState(() {
          groupsList.add(new ListTile(
            leading: new Icon(selectedGroup == event.snapshot.val()["name"] ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: mainColor,),
            title: new Text(event.snapshot.val()["name"], style: TextStyle(color: currTextColor)),
            onTap: () {
              setState(() {
                selectedGroupID = event.snapshot.key;
                selectedGroup = event.snapshot.val()["name"];
                height = 0;
              });
              updateHandbookView();
            },
          ));
          if (currUser.groups.contains(event.snapshot.key)) {
            selectedGroupID = event.snapshot.key;
            selectedGroup = event.snapshot.val()["name"];
            height = 0;
            updateHandbookView();
          }
        });
      }
    });
  }

  Future<void> updateHandbookView() async {
    setState(() {
      handbookList.clear();
    });
    // Check if group has handbook
    fb.database().ref("chapters").child(currUser.chapter.chapterID).child("groups").child(selectedGroupID).child("handbook").once("value").then((value) async {
      if (value.snapshot.val() != null) {
        print("Group has handbook");
        setState(() {
          hasHandbook = true;
        });
        String handbookID = value.snapshot.val();
        if (currUser.roles.contains("Advisor") || currUser.roles.contains("President") || currUser.roles.contains("Developer") || currUser.roles.contains("Officer")) {
          // Show all users
          await fb.database().ref("chapters").child(currUser.chapter.chapterID).child("handbooks").child(handbookID).once("value").then((value) {
            Handbook handbook = new Handbook.fromSnapshot(value.snapshot);
            fb.database().ref("users").onChildAdded.listen((event) {
              User user = User.fromSnapshot(event.snapshot);
              if (user.chapter.chapterID == currUser.chapter.chapterID && user.groups.contains(selectedGroupID)) {
                UserHandbook userHandbook = new UserHandbook();
                userHandbook.handbookID = handbook.handbookID;
                userHandbook.name = handbook.name;
                userHandbook.user = user;
                for (int i = 0; i < handbook.tasks.length; i++) {
                  HandbookItem item = new HandbookItem();
                  item.index = i;
                  item.task = handbook.tasks[i];
                  userHandbook.items.add(item);
                }
                setState(() {
                  handbookList.add(userHandbook);
                });
                fb.database().ref("users").child(user.userID).child("handbooks").child(handbookID).onChildAdded.listen((event) {
                  UserHandbook tempHandbook = handbookList[handbookList.indexWhere((element) => element.user.userID == user.userID)];
                  fb.database().ref("users").child(event.snapshot.val()["checkedBy"]).once("value").then((value) {
                    User tempUser = new User.fromSnapshot(value.snapshot);
                    tempHandbook.items[int.parse(event.snapshot.key)].checkedBy = tempUser;
                    tempHandbook.items[int.parse(event.snapshot.key)].timestamp = DateTime.parse(event.snapshot.val() ["date"]);
                    setState(() {
                      handbookList[handbookList.indexWhere((element) => element.user.userID == user.userID)] = tempHandbook;
                    });
                  });
                });
                fb.database().ref("users").child(user.userID).child("handbooks").child(handbookID).onChildRemoved.listen((event) {
                  UserHandbook tempHandbook = handbookList[handbookList.indexWhere((element) => element.user.userID == user.userID)];
                  tempHandbook.items[int.parse(event.snapshot.key)].timestamp = null;
                  setState(() {
                    handbookList[handbookList.indexWhere((element) => element.user.userID == user.userID)] = tempHandbook;
                  });
                });
              }
            });
          });
        }
        else {
          // Show just user
          await fb.database().ref("chapters").child(currUser.chapter.chapterID).child("handbooks").child(handbookID).once("value").then((value) async {
            Handbook handbook = new Handbook.fromSnapshot(value.snapshot);
            UserHandbook userHandbook = new UserHandbook();
            userHandbook.handbookID = handbook.handbookID;
            userHandbook.name = handbook.name;
            userHandbook.user = currUser;
            for (int i = 0; i < handbook.tasks.length; i++) {
              HandbookItem item = new HandbookItem();
              item.index = i;
              item.task = handbook.tasks[i];
              userHandbook.items.add(item);
            }
            setState(() {
              handbookList.add(userHandbook);
            });
            fb.database().ref("users").child(currUser.userID).child("handbooks").child(handbookID).onChildAdded.listen((event) {
              UserHandbook tempHandbook = handbookList[handbookList.indexWhere((element) => element.user.userID == currUser.userID)];
              fb.database().ref("users").child(event.snapshot.val()["checkedBy"]).once("value").then((value) {
                User tempUser = new User.fromSnapshot(value.snapshot);
                tempHandbook.items[int.parse(event.snapshot.key)].checkedBy = tempUser;
                tempHandbook.items[int.parse(event.snapshot.key)].timestamp = DateTime.parse(event.snapshot.val()["date"]);
                setState(() {
                  handbookList[handbookList.indexWhere((element) => element.user.userID == currUser.userID)] = tempHandbook;
                });
              });
            });
            fb.database().ref("users").child(currUser.userID).child("handbooks").child(handbookID).onChildRemoved.listen((event) {
              UserHandbook tempHandbook = handbookList[handbookList.indexWhere((element) => element.user.userID == currUser.userID)];
              tempHandbook.items[int.parse(event.snapshot.key)].timestamp = null;
              setState(() {
                handbookList[handbookList.indexWhere((element) => element.user.userID == currUser.userID)] = tempHandbook;
              });
            });
          });
        }
      }
      else {
        print("Group has no handbook");
        setState(() {
          hasHandbook = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorage["userID"] != null) {
      if (MediaQuery.of(context).size.width > 800) {
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
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Card(
                          elevation: selectedGroupID == "" ? 0 : 1,
                          color: selectedGroupID == "" ? currCardColor : mainColor,
                          child: new InkWell(
                            onTap: () {
                              if (height == 0) {
                                setState(() {
                                  height = 250;
                                });
                              }
                              else {
                                setState(() {
                                  height = 0;
                                });
                              }
                            },
                            child: new ListTile(
                              title: new Text(selectedGroupID == "" ? "Select Group" : selectedGroup, style: TextStyle(color: selectedGroupID == "" ? mainColor : Colors.white),),
                            ),
                          ),
                        ),
                        new AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: height,
                          child: new SingleChildScrollView(
                            child: new Column(
                              children: groupsList,
                            ),
                          ),
                        ),
                        new Visibility(
                          visible: !hasHandbook,
                          child: new Container(
                            padding: EdgeInsets.all(16),
                            child: new Center(child: Text("No handbook has been added to this group.\nPlease check again later!", style: TextStyle(color: currTextColor, fontSize: 17), textAlign: TextAlign.center,),),
                          ),
                        ),
                        new Padding(padding: EdgeInsets.all(4)),
                        new Column(
                          children: handbookList.map((handbook) => new Container(
                              child: new Card(
                                color: currCardColor,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: new Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      new Text(
                                        "${handbook.user.firstName} – ${handbook.name}",
                                        style: TextStyle(color: currTextColor, fontSize: 18),
                                      ),
                                      Column(
                                        children: handbook.items.map((item) {
                                          if (item.timestamp != null) {
                                            return new ExpansionTile(
                                              leading: InkWell(
                                                child: Icon(Icons.check_box, color: mainColor,),
                                                onTap: () {
                                                  if (currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("Officer")) {
                                                    fb.database().ref("users").child(handbook.user.userID).child("handbooks").child(handbook.handbookID).child(item.index.toString()).remove();
                                                  }
                                                },
                                              ),
                                              title: new Text(item.task, style: TextStyle(color: currTextColor),),
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      new Container(
                                                        child: new CircleAvatar(
                                                          radius: 15,
                                                          backgroundColor: roleColors[item.checkedBy.roles.first],
                                                          child: new ClipRRect(
                                                            borderRadius: new BorderRadius.all(Radius.circular(45)),
                                                            child: new CachedNetworkImage(
                                                                imageUrl: item.checkedBy.profileUrl,
                                                                height: 26,
                                                                width: 26
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      new Padding(padding: EdgeInsets.all(4)),
                                                      new Container(
                                                        child: new Text("${item.checkedBy.firstName} ${item.checkedBy.lastName}  |  ", style: TextStyle(color: Colors.grey, fontSize: 16),),
                                                      ),
                                                      new Container(
                                                        child: new Text("${DateFormat().add_MMMd().format(item.timestamp)} @ ${DateFormat().add_jm().format(item.timestamp)}", style: TextStyle(color: Colors.grey, fontSize: 16),),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            );
                                          }
                                          else {
                                            return new ListTile(
                                              leading: Icon(
                                                Icons.check_box_outline_blank,
                                                color: darkMode ? Colors.grey : Colors.black54,
                                              ),
                                              title: new Text(item.task, style: TextStyle(color: currTextColor),),
                                              onTap: () {
                                                if (currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("Officer")) {
                                                  fb.database().ref("users").child(handbook.user.userID).child("handbooks").child(handbook.handbookID).child(item.index.toString()).set({
                                                    "checkedBy": currUser.userID,
                                                    "date": DateTime.now().toString()
                                                  });
                                                }
                                              },
                                            );
                                          }
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          )).toList(),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      else {
        return Scaffold(
          appBar: new AppBar(
            title: new Text(
              "HANDBOOK",
            ),
          ),
          backgroundColor: currBackgroundColor,
          body: new Container(
            padding: EdgeInsets.only(left: 8, top: 8, right: 8),
            child: new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Card(
                    elevation: selectedGroupID == "" ? 0 : 1,
                    color: selectedGroupID == "" ? currCardColor : mainColor,
                    child: new InkWell(
                      onTap: () {
                        if (height == 0) {
                          setState(() {
                            height = 250;
                          });
                        }
                        else {
                          setState(() {
                            height = 0;
                          });
                        }
                      },
                      child: new ListTile(
                        title: new Text(selectedGroupID == "" ? "Select Group" : selectedGroup, style: TextStyle(color: selectedGroupID == "" ? mainColor : Colors.white),),
                      ),
                    ),
                  ),
                  new AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: height,
                    child: new SingleChildScrollView(
                      child: new Column(
                        children: groupsList,
                      ),
                    ),
                  ),
                  new Visibility(
                    visible: !hasHandbook,
                    child: new Container(
                      padding: EdgeInsets.all(16),
                      child: new Center(child: Text("No handbook has been added to this group.\nPlease check again later!", style: TextStyle(color: currTextColor, fontSize: 17), textAlign: TextAlign.center,),),
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(4)),
                  new Column(
                    children: handbookList.map((handbook) => new Container(
                        child: new Card(
                          color: currCardColor,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                new Text(
                                  "${handbook.user.firstName} – ${handbook.name}",
                                  style: TextStyle(color: currTextColor, fontSize: 18),
                                ),
                                Column(
                                  children: handbook.items.map((item) {
                                    if (item.timestamp != null) {
                                      return new ExpansionTile(
                                        leading: InkWell(
                                          child: Icon(Icons.check_box, color: mainColor,),
                                          onTap: () {
                                            if (currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("Officer")) {
                                              fb.database().ref("users").child(handbook.user.userID).child("handbooks").child(handbook.handbookID).child(item.index.toString()).remove();
                                            }
                                          },
                                        ),
                                        title: new Text(item.task, style: TextStyle(color: currTextColor),),
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                new Container(
                                                  child: new CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor: roleColors[item.checkedBy.roles.first],
                                                    child: new ClipRRect(
                                                      borderRadius: new BorderRadius.all(Radius.circular(45)),
                                                      child: new CachedNetworkImage(
                                                          imageUrl: item.checkedBy.profileUrl,
                                                          height: 26,
                                                          width: 26
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                new Padding(padding: EdgeInsets.all(4)),
                                                new Container(
                                                  child: new Text("${item.checkedBy.firstName} ${item.checkedBy.lastName}  |  ", style: TextStyle(color: Colors.grey, fontSize: 16),),
                                                ),
                                                new Container(
                                                  child: new Text("${DateFormat().add_MMMd().format(item.timestamp)} @ ${DateFormat().add_jm().format(item.timestamp)}", style: TextStyle(color: Colors.grey, fontSize: 16),),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      );
                                    }
                                    else {
                                      return new ListTile(
                                        leading: Icon(
                                          Icons.check_box_outline_blank,
                                          color: darkMode ? Colors.grey : Colors.black54,
                                        ),
                                        title: new Text(item.task, style: TextStyle(color: currTextColor),),
                                        onTap: () {
                                          if (currUser.roles.contains("Developer") || currUser.roles.contains("Advisor") || currUser.roles.contains("Officer")) {
                                            fb.database().ref("users").child(handbook.user.userID).child("handbooks").child(handbook.handbookID).child(item.index.toString()).set({
                                              "checkedBy": currUser.userID,
                                              "date": DateTime.now().toString()
                                            });
                                          }
                                        },
                                      );
                                    }
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        )
                    )).toList(),
                  )
                ],
              ),
            ),
          ),
        );
      }
    }
    else {
      return new LoginPage();
    }
  }
}

import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:intl/intl.dart';
import 'package:mydeca_web/models/announcement.dart';
import 'package:mydeca_web/models/meeting.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/navbars/mobile_sidebar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/pages/home/advisor/advisor_conference_select.dart';
import 'package:mydeca_web/pages/home/advisor/send_notification_dialog.dart';
import 'package:mydeca_web/pages/home/join_group_dialog.dart';
import 'package:mydeca_web/pages/home/welcome_dialog.dart';
import 'package:mydeca_web/utils/button_filled.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;
import 'package:flutter/src/painting/text_style.dart' as ts;
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Storage _localStorage = html.window.localStorage;

  List<Announcement> announcementList = new List();
  int unreadAnnounce = 0;

  List<Widget> roleWidgetList = new List();
  List<Widget> conferenceWidgetList = new List();
  List<Widget> groupsWidgetList = new List();
  List<Widget> currentMeetingsWidgetList = new List();
  List<Widget> meetingsWidgetList = new List();

  User currUser = User.plain();

  @override
  void initState() {
    super.initState();
    if (_localStorage.containsKey("userID")) {
      fb
          .database()
          .ref("users")
          .child(_localStorage["userID"])
          .once("value")
          .then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
          if (!currUser.emailVerified) {
            welcomeDialog();
          }
          for (int i = 0; i < currUser.roles.length; i++) {
            print(currUser.roles[i]);
            roleWidgetList.add(new Card(
              color: roleColors[currUser.roles[i]],
              child: new Container(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                child: new Text(
                  currUser.roles[i],
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ));
          }
          if (currUser.roles.contains("Judge")) {
            router.navigateTo(context, "/conferences/2020-VC-Mock",
                transition: TransitionType.fadeIn,
                clearStack: true,
                replace: true);
          }
        });
        getAnnouncements();
        getMeetings();
        getAdvisorInfo();
        updateUserGroups();
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

  void getAnnouncements() {
    print(DateTime.now());
    // Get Chapter announcements
    fb
        .database()
        .ref("chapters")
        .child(currUser.chapter.chapterID)
        .child("announcements")
        .onChildAdded
        .listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          fb
              .database()
              .ref("users")
              .child(currUser.userID)
              .child("announcements")
              .child(event.snapshot.key)
              .once("value")
              .then((value) {
            setState(() {
              announcementList.add(announcement);
            });
            if (value.snapshot.val() == null) {
              unreadAnnounce++;
            }
          });
          break;
        }
      }
    });
    // Get official announcements
    fb.database().ref("announcements").onChildAdded.listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          fb
              .database()
              .ref("users")
              .child(currUser.userID)
              .child("announcements")
              .child(event.snapshot.key)
              .once("value")
              .then((value) {
            setState(() {
              announcementList.add(announcement);
            });
            if (value.snapshot.val() == null) {
              unreadAnnounce++;
            }
          });
          break;
        }
      }
    });
  }

  void getMeetings() {
    fb
        .database()
        .ref("chapters")
        .child(currUser.chapter.chapterID)
        .child("meetings")
        .onChildAdded
        .listen((event) {
      Meeting meeting = new Meeting.fromSnapshot(event.snapshot);
      for (int i = 0; i < meeting.topics.length; i++) {
        if (currUser.roles.contains(meeting.topics[i])) {
          if (meeting.startTime.isAfter(DateTime.now()) &&
              meetingsWidgetList.length <= 3) {
            // Meeting upcoming
            setState(() {
              meetingsWidgetList.add(new Container(
                padding: EdgeInsets.only(bottom: 8),
                child: new Card(
                  child: new InkWell(
                    onTap: () {
                      router.navigateTo(
                          context, "/home/meetings/details?id=${meeting.id}",
                          transition: TransitionType.fadeIn);
                    },
                    child: new Container(
                      padding: EdgeInsets.all(8),
                      width: double.infinity,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text(
                            meeting.name,
                            style: TextStyle(
                                fontSize: 18, fontFamily: "Montserrat"),
                          ),
                          new Text(
                            "${DateFormat().add_yMMMd().format(meeting.startTime)} @ ${DateFormat().add_jm().format(meeting.startTime)}",
                            style: TextStyle(fontSize: 17, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ));
            });
          } else if (meeting.startTime.isBefore(DateTime.now()) &&
              meeting.endTime.isAfter(DateTime.now())) {
            // Meeting ongoing
            setState(() {
              currentMeetingsWidgetList.add(new Container(
                padding: EdgeInsets.only(bottom: 8),
                child: new Card(
                  shape: new RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: new BorderSide(color: mainColor, width: 2.0)),
                  child: new InkWell(
                    onTap: () {
                      router.navigateTo(
                          context, "/home/meetings/details?id=${meeting.id}",
                          transition: TransitionType.fadeIn);
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
                                  style: TextStyle(
                                      fontSize: 18, fontFamily: "Montserrat"),
                                ),
                                new Text(
                                  "${DateFormat().add_yMMMd().format(meeting.startTime)} @ ${DateFormat().add_jm().format(meeting.startTime)}",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                          new Visibility(
                            visible: meeting.url != "",
                            child: Container(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: new ButtonFilled(
                                child: new Text(
                                  "JOIN",
                                  style: TextStyle(color: Colors.white),
                                ),
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 8, bottom: 8),
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
                                child: new Icon(
                                  Icons.arrow_forward_ios,
                                  color: mainColor,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ));
            });
          }
          break;
        }
      }
    });
  }

  void getAdvisorInfo() {
    if (currUser.roles.contains("Developer") ||
        currUser.roles.contains("Advisor")) {
      fb
          .database()
          .ref("chapters")
          .child(currUser.chapter.chapterID)
          .child("conferences")
          .onValue
          .listen((event) {
        print("value");
        updateSelectedConferences();
      });
    } else {
      print("Not authorized");
    }
  }

  void updateSelectedConferences() {
    setState(() {
      conferenceWidgetList.clear();
    });
    fb
        .database()
        .ref("chapters")
        .child(currUser.chapter.chapterID)
        .child("conferences")
        .onChildAdded
        .listen((event) {
      print("${event.snapshot.key} – ${event.snapshot.val()["enabled"]}");
      if (event.snapshot.val()["enabled"]) {
        fb
            .database()
            .ref("conferences")
            .child(event.snapshot.key)
            .child("past")
            .once("value")
            .then((value) {
          if (value.snapshot.val()) {
            print("Event has already past");
          } else {
            setState(() {
              conferenceWidgetList.add(new Card(
                color: mainColor,
                child: new Container(
                  padding:
                      EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                  child: new Text(
                    event.snapshot.key,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ));
            });
          }
        });
      }
    });
  }

  void welcomeDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              "Welcome to myDECA!",
              style: TextStyle(color: currTextColor),
            ),
            backgroundColor: currCardColor,
            content: new WelcomeDialog(),
          );
        });
  }

  void selectConferenceDialog(User user) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              "Select Conferences",
              style: TextStyle(color: currTextColor),
            ),
            backgroundColor: currCardColor,
            content: new AdvisorConferenceSelect(user),
            actions: [
              new TextButton(
                child: new Text("DONE"),
                onPressed: () {
                  router.pop(context);
                },
              )
            ],
          );
        });
  }

  void updateUserGroups() {
    fb
        .database()
        .ref("users")
        .child(_localStorage["userID"])
        .onValue
        .listen((value) {
      setState(() {
        groupsWidgetList.clear();
        currUser = User.fromSnapshot(value.snapshot);
      });
      for (int i = 0; i < currUser.groups.length; i++) {
        print(currUser.groups[i]);
        fb
            .database()
            .ref("chapters")
            .child(currUser.chapter.chapterID)
            .child("groups")
            .child(currUser.groups[i])
            .child("name")
            .once("value")
            .then((value) {
          if (value.snapshot.val() != null) {
            setState(() {
              groupsWidgetList.add(new Card(
                color: mainColor,
                child: new Container(
                  padding:
                      EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                  child: new Text(
                    value.snapshot.val(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ));
            });
          }
        });
      }
    });
  }

  void selectGroupDialog(User user) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              "My Groups",
              style: TextStyle(color: currTextColor),
            ),
            backgroundColor: currCardColor,
            content: new JoinGroupDialog(user),
            actions: [
              new TextButton(
                child: new Text("DONE"),
                onPressed: () {
                  router.pop(context);
                },
              )
            ],
          );
        });
  }

  sendNotificationDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              "Send Notification",
              style: TextStyle(color: currTextColor),
            ),
            backgroundColor: currCardColor,
            content: new SendNotificationDialog(currUser),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorage["userID"] != null) {
      if (MediaQuery.of(context).size.width > 800) {
        return new Title(
          title: "myDECA",
          color: mainColor,
          child: new Scaffold(
            body: Container(
              child: new SingleChildScrollView(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    HomeNavbar(),
                    new Container(
                      padding: new EdgeInsets.all(16.0),
                      width: (MediaQuery.of(context).size.width > 1300)
                          ? 1100
                          : MediaQuery.of(context).size.width - 50,
                      child: new Text(
                        "Welcome back, ${currUser.firstName}.",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            color: currTextColor,
                            fontSize: 35),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    new Container(
                      padding: new EdgeInsets.only(top: 4.0, bottom: 4.0),
                      width: (MediaQuery.of(context).size.width > 1300)
                          ? 1100
                          : MediaQuery.of(context).size.width - 50,
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              new Row(
                                                children: [
                                                  new Icon(Icons.dashboard),
                                                  new Padding(
                                                      padding:
                                                          EdgeInsets.all(4)),
                                                  new Text(
                                                    "DASHBOARD",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontSize: 20,
                                                        color: currTextColor),
                                                  )
                                                ],
                                              ),
                                              new IconButton(
                                                icon: Icon(
                                                  Icons.settings,
                                                  color: currCardColor,
                                                ),
                                              )
                                            ],
                                          ),
                                          new Padding(
                                              padding: EdgeInsets.only(
                                                  top: 8, bottom: 16),
                                              child: new Divider(
                                                  color: currDividerColor,
                                                  height: 8)),
                                          new Container(
                                            width: double.infinity,
                                            height: 100.0,
                                            child: new Row(
                                              children: <Widget>[
                                                new Expanded(
                                                  flex: 5,
                                                  child: new Card(
                                                    elevation: 2.0,
                                                    color: currCardColor,
                                                    child: new InkWell(
                                                      onTap: () {
                                                        alert(
                                                            "No favorite events selected! Please select your favorite events from the competitive event browser first.");
                                                      },
                                                      child: new Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: <Widget>[
                                                          new Icon(Icons.event,
                                                              size: 35.0,
                                                              color: darkMode
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .black54),
                                                          new Text(
                                                            "My Events",
                                                            style: TextStyle(
                                                                fontSize: 13.0,
                                                                color:
                                                                    currTextColor),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                new Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0)),
                                                new Expanded(
                                                  flex: 3,
                                                  child: new Card(
                                                    elevation: 2.0,
                                                    color: currCardColor,
                                                    child: new InkWell(
                                                      onTap: () {
                                                        router.navigateTo(
                                                            context,
                                                            '/home/announcements',
                                                            transition:
                                                                TransitionType
                                                                    .fadeIn);
                                                      },
                                                      child: new Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: <Widget>[
                                                          new Text(
                                                            unreadAnnounce > 0
                                                                ? unreadAnnounce
                                                                    .toString()
                                                                : announcementList
                                                                    .length
                                                                    .toString(),
                                                            style: TextStyle(
                                                                fontSize: 35.0,
                                                                color: unreadAnnounce >
                                                                        0
                                                                    ? mainColor
                                                                    : Colors
                                                                        .grey),
                                                          ),
                                                          new Text(
                                                            unreadAnnounce > 0
                                                                ? "New Announcements"
                                                                : "Announcements",
                                                            style: TextStyle(
                                                                fontSize: 13.0,
                                                                color: unreadAnnounce >
                                                                        0
                                                                    ? mainColor
                                                                    : currTextColor),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          new Padding(
                                              padding: EdgeInsets.all(4.0)),
                                          new Container(
                                            width: double.infinity,
                                            height: 100.0,
                                            child: new Row(
                                              children: <Widget>[
                                                new Expanded(
                                                  flex: 3,
                                                  child: new Card(
                                                    elevation: 2.0,
                                                    color: currCardColor,
                                                    child: new InkWell(
                                                      onTap: () {
                                                        if (currUser.groups
                                                            .isNotEmpty) {
                                                          router.navigateTo(
                                                              context,
                                                              '/home/handbook',
                                                              transition:
                                                                  TransitionType
                                                                      .fadeIn);
                                                        } else {
                                                          alert(
                                                              "You are not a part of any groups. Please join a group to get access to your handbook.");
                                                        }
                                                      },
                                                      child: new Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: <Widget>[
                                                          new Icon(
                                                              Icons
                                                                  .library_books,
                                                              size: 35.0,
                                                              color: darkMode
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .black54),
                                                          new Text(
                                                            "My Handbook",
                                                            style: TextStyle(
                                                                fontSize: 13.0,
                                                                color:
                                                                    currTextColor),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                new Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0)),
                                                new Expanded(
                                                  flex: 5,
                                                  child: new Card(
                                                    elevation: 2.0,
                                                    color: currCardColor,
                                                    child: new InkWell(
                                                      onTap: () {
                                                        selectGroupDialog(
                                                            currUser);
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          new ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                    minHeight:
                                                                        100),
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 16,
                                                                      right:
                                                                          16),
                                                              child: new Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceEvenly,
                                                                children: <
                                                                    Widget>[
                                                                  new Icon(
                                                                      Icons
                                                                          .group,
                                                                      size:
                                                                          35.0,
                                                                      color: darkMode
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .black54),
                                                                  new Text(
                                                                    "My Groups",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13.0,
                                                                        color:
                                                                            currTextColor),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          new Expanded(
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 8,
                                                                      bottom:
                                                                          8),
                                                              child: new Wrap(
                                                                direction: Axis
                                                                    .horizontal,
                                                                children:
                                                                    groupsWidgetList,
                                                              ),
                                                            ),
                                                          ),
                                                          new Visibility(
                                                            visible:
                                                                groupsWidgetList
                                                                    .isEmpty,
                                                            child: Container(
                                                              child: new Text(
                                                                "It looks like you are not part of any groups.\nClick on this card to join a group.",
                                                                style: TextStyle(
                                                                    color:
                                                                        currTextColor),
                                                              ),
                                                            ),
                                                          ),
                                                          new Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          new Padding(
                                              padding: EdgeInsets.all(4.0)),
                                          new Visibility(
                                            visible: currUser.roles
                                                    .contains("Developer") ||
                                                currUser.roles
                                                    .contains("Officer"),
                                            child: new Container(
                                              width: double.infinity,
                                              height: 100.0,
                                              child: new Row(
                                                children: <Widget>[
                                                  new Expanded(
                                                    flex: 5,
                                                    child: new Card(
                                                      color: currCardColor,
                                                      elevation: 2.0,
                                                      child: new InkWell(
                                                        onTap: () {
                                                          sendNotificationDialog();
                                                        },
                                                        child: new Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: <Widget>[
                                                            new Icon(
                                                              Icons
                                                                  .notifications_active,
                                                              size: 35.0,
                                                              color: darkMode
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .black54,
                                                            ),
                                                            new Text(
                                                              "Send Notification",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      13.0,
                                                                  color:
                                                                      currTextColor),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  new Padding(
                                                      padding:
                                                          EdgeInsets.all(4.0)),
                                                  new Expanded(
                                                    flex: 3,
                                                    child: new Card(
                                                      elevation: 2.0,
                                                      color: currCardColor,
                                                      child: new InkWell(
                                                        onTap: () {
                                                          router.navigateTo(
                                                              context,
                                                              "/home/manage-users",
                                                              transition:
                                                                  TransitionType
                                                                      .fadeIn);
                                                        },
                                                        child: new Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: <Widget>[
                                                            new Icon(
                                                                Icons
                                                                    .supervised_user_circle,
                                                                size: 35.0,
                                                                color: darkMode
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black54),
                                                            new Text(
                                                              "Manage Users",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      13.0,
                                                                  color:
                                                                      currTextColor),
                                                            )
                                                          ],
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
                                    ),
                                  ),
                                ),
                                new Padding(padding: EdgeInsets.all(8)),
                                new Visibility(
                                  visible:
                                      currUser.roles.contains("Developer") ||
                                          currUser.roles.contains("Advisor"),
                                  child: new Container(
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
                                                new Icon(
                                                    Icons.admin_panel_settings),
                                                new Padding(
                                                    padding: EdgeInsets.all(4)),
                                                new Text(
                                                  "ADVISOR PANEL",
                                                  style: TextStyle(
                                                      fontFamily: "Montserrat",
                                                      fontSize: 20,
                                                      color: currTextColor),
                                                )
                                              ],
                                            ),
                                            new Padding(
                                                padding: EdgeInsets.only(
                                                    top: 8, bottom: 16),
                                                child: new Divider(
                                                    color: currDividerColor,
                                                    height: 8)),
                                            new Container(
                                              width: double.infinity,
                                              height: 100.0,
                                              child: new Row(
                                                children: <Widget>[
                                                  new Expanded(
                                                    flex: 5,
                                                    child: new Card(
                                                      elevation: 2.0,
                                                      color: currCardColor,
                                                      child: new InkWell(
                                                        onTap: () {
                                                          selectConferenceDialog(
                                                              currUser);
                                                        },
                                                        child: Row(
                                                          children: [
                                                            new ConstrainedBox(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      minHeight:
                                                                          100),
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            16,
                                                                        right:
                                                                            16),
                                                                child:
                                                                    new Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: <
                                                                      Widget>[
                                                                    new Icon(
                                                                        Icons
                                                                            .event,
                                                                        size:
                                                                            35.0,
                                                                        color: darkMode
                                                                            ? Colors.grey
                                                                            : Colors.black54),
                                                                    new Text(
                                                                      "My Conferences",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13.0,
                                                                          color:
                                                                              currTextColor),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            new Expanded(
                                                              child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 8,
                                                                        bottom:
                                                                            8),
                                                                child: new Wrap(
                                                                  direction: Axis
                                                                      .horizontal,
                                                                  children:
                                                                      conferenceWidgetList,
                                                                ),
                                                              ),
                                                            ),
                                                            new Visibility(
                                                              visible:
                                                                  conferenceWidgetList
                                                                      .isEmpty,
                                                              child: Container(
                                                                child: new Text(
                                                                  "No conferences selected for this\nchapter. Click on this card to add\na conference.",
                                                                  style: TextStyle(
                                                                      color:
                                                                          currTextColor),
                                                                ),
                                                              ),
                                                            ),
                                                            new Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  new Padding(
                                                      padding:
                                                          EdgeInsets.all(4.0)),
                                                  new Expanded(
                                                    flex: 3,
                                                    child: new Card(
                                                      elevation: 2.0,
                                                      color: currCardColor,
                                                      child: new InkWell(
                                                        onTap: () {
                                                          router.navigateTo(
                                                              context,
                                                              "/home/manage-users",
                                                              transition:
                                                                  TransitionType
                                                                      .fadeIn);
                                                        },
                                                        child: new Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: <Widget>[
                                                            new Icon(
                                                                Icons
                                                                    .supervised_user_circle,
                                                                size: 35.0,
                                                                color: darkMode
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black54),
                                                            new Text(
                                                              "Manage Users",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      13.0,
                                                                  color:
                                                                      currTextColor),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            new Padding(
                                                padding: EdgeInsets.all(4.0)),
                                            new Container(
                                              width: double.infinity,
                                              height: 100.0,
                                              child: new Row(
                                                children: <Widget>[
                                                  new Expanded(
                                                    flex: 3,
                                                    child: new Card(
                                                      color: currCardColor,
                                                      elevation: 2.0,
                                                      child: new InkWell(
                                                        onTap: () {
                                                          sendNotificationDialog();
                                                        },
                                                        child: new Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: <Widget>[
                                                            new Icon(
                                                              Icons
                                                                  .notifications_active,
                                                              size: 35.0,
                                                              color: darkMode
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .black54,
                                                            ),
                                                            new Text(
                                                              "Send Notification",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      13.0,
                                                                  color:
                                                                      currTextColor),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  new Padding(
                                                      padding:
                                                          EdgeInsets.all(4.0)),
                                                  new Expanded(
                                                    flex: 5,
                                                    child: new Card(
                                                      elevation: 2.0,
                                                      color: currCardColor,
                                                      child: new InkWell(
                                                        onTap: () {
                                                          router.navigateTo(
                                                              context,
                                                              '/home/handbook/manage',
                                                              transition:
                                                                  TransitionType
                                                                      .fadeIn);
                                                        },
                                                        child: new Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: <Widget>[
                                                            new Icon(
                                                                Icons
                                                                    .library_books,
                                                                size: 35.0,
                                                                color: darkMode
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black54),
                                                            new Text(
                                                              "Manage Handbooks",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      13.0,
                                                                  color:
                                                                      currTextColor),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
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
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              new Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  new Icon(Icons.person),
                                                  new Padding(
                                                      padding:
                                                          EdgeInsets.all(4)),
                                                  new Text(
                                                    "PROFILE",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            "Montserrat",
                                                        fontSize: 20,
                                                        color: currTextColor),
                                                  )
                                                ],
                                              ),
                                              new IconButton(
                                                icon: Icon(Icons.settings),
                                                color: Colors.grey,
                                                onPressed: () {
                                                  router.navigateTo(
                                                      context, '/settings',
                                                      transition: TransitionType
                                                          .fadeIn);
                                                },
                                              )
                                            ],
                                          ),
                                          new Container(
                                              padding: EdgeInsets.only(
                                                  top: 8, bottom: 16),
                                              child: new Divider(
                                                  color: currDividerColor,
                                                  height: 8)),
                                          new ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100)),
                                            child: new CachedNetworkImage(
                                              imageUrl: currUser.profileUrl,
                                              height: 100,
                                            ),
                                          ),
                                          new Padding(
                                              padding: EdgeInsets.all(8)),
                                          new Text(
                                            currUser.firstName +
                                                " " +
                                                currUser.lastName,
                                            style: TextStyle(fontSize: 25),
                                          ),
                                          new Padding(
                                              padding: EdgeInsets.all(8)),
                                          new Wrap(
                                              direction: Axis.horizontal,
                                              children: roleWidgetList),
                                          new ListTile(
                                            leading: new Icon(
                                                currUser.emailVerified
                                                    ? Icons.verified_user
                                                    : Icons.mail),
                                            title: new Text(currUser.email),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                new Padding(padding: EdgeInsets.all(8)),
                                new Container(
                                  padding: new EdgeInsets.only(right: 16),
                                  child: new Card(
                                    elevation: 2.0,
                                    child: new Container(
                                      color: currCardColor,
                                      padding: new EdgeInsets.only(
                                          left: 16, top: 16, right: 16),
                                      child: new Column(
                                        children: [
                                          new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              new Icon(Icons.event),
                                              new Padding(
                                                  padding: EdgeInsets.all(4)),
                                              new Text(
                                                "MEETINGS",
                                                style: TextStyle(
                                                    fontFamily: "Montserrat",
                                                    fontSize: 20,
                                                    color: currTextColor),
                                              )
                                            ],
                                          ),
                                          new Container(
                                              padding: EdgeInsets.only(
                                                  top: 8, bottom: 16),
                                              child: new Divider(
                                                color: currDividerColor,
                                                height: 8,
                                              )),
                                          new Visibility(
                                              visible:
                                                  meetingsWidgetList.isEmpty &&
                                                      currentMeetingsWidgetList
                                                          .isEmpty,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: new Text(
                                                    "There are no upcoming meetings."),
                                              )),
                                          new Column(
                                            children: currentMeetingsWidgetList,
                                          ),
                                          new Column(
                                            children: meetingsWidgetList,
                                          ),
                                          new FlatButton(
                                            child: new Text("VIEW ALL"),
                                            padding: EdgeInsets.only(
                                                left: 20,
                                                top: 16,
                                                bottom: 16,
                                                right: 20),
                                            textColor: mainColor,
                                            onPressed: () {
                                              router.navigateTo(
                                                  context, "/home/meetings",
                                                  transition:
                                                      TransitionType.fadeIn);
                                            },
                                          ),
                                          new Padding(
                                            padding: EdgeInsets.all(4),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
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
          ),
        );
      } else {
        return Scaffold(
          appBar: new AppBar(
            title: new Text(
              "HOME",
            ),
          ),
          drawer: new MobileSidebar(),
          backgroundColor: currBackgroundColor,
          body: new Container(
            padding: EdgeInsets.only(left: 8, top: 8, right: 8),
            child: new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Text(
                    "Welcome back, ${currUser.firstName}",
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 35,
                        fontWeight: FontWeight.normal,
                        color: currTextColor),
                  ),
                  new Padding(padding: EdgeInsets.all(8)),
                  new Visibility(
                    visible: unreadAnnounce > 0,
                    child: new Container(
                      width: double.infinity,
                      height: 100.0,
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new Card(
                              shape: new RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: new BorderSide(
                                      color: mainColor, width: 2.0)),
                              elevation: 2.0,
                              color: currCardColor,
                              child: new InkWell(
                                onTap: () {
                                  router.navigateTo(
                                      context, '/home/announcements',
                                      transition: TransitionType.native);
                                },
                                child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new Text(
                                      unreadAnnounce > 0
                                          ? unreadAnnounce.toString()
                                          : announcementList.length.toString(),
                                      style: TextStyle(
                                          fontSize: 35.0,
                                          color: unreadAnnounce > 0
                                              ? mainColor
                                              : Colors.grey),
                                    ),
                                    new Text(
                                      unreadAnnounce > 0
                                          ? "New Announcements"
                                          : "Announcements",
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          color: unreadAnnounce > 0
                                              ? mainColor
                                              : currTextColor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  new Container(
                    width: double.infinity,
                    child: new Card(
                      elevation: 2.0,
                      color: currCardColor,
                      child: new Container(
                        padding: new EdgeInsets.only(left: 8, top: 8, right: 8),
                        child: new Column(
                          children: [
                            new Visibility(
                                visible: meetingsWidgetList.isEmpty &&
                                    currentMeetingsWidgetList.isEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: new Text(
                                      "There are no upcoming meetings."),
                                )),
                            new Column(
                              children: currentMeetingsWidgetList,
                            ),
                            new Column(
                              children: meetingsWidgetList,
                            ),
                            new FlatButton(
                              child: new Text("VIEW ALL MEETINGS"),
                              padding: EdgeInsets.only(
                                  left: 20, top: 16, bottom: 16, right: 20),
                              textColor: mainColor,
                              onPressed: () {
                                router.navigateTo(context, "/home/meetings",
                                    transition: TransitionType.fadeIn);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  new Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: new Divider(color: currDividerColor, height: 8)),
                  new Container(
                    width: double.infinity,
                    height: 100.0,
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          flex: 5,
                          child: new Card(
                            elevation: 2.0,
                            color: currCardColor,
                            child: new InkWell(
                              onTap: () {
                                alert(
                                    "No favorite events selected! Please select your favorite events from the competitive event browser first.");
                              },
                              child: new Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new Icon(Icons.event,
                                      size: 35.0,
                                      color: darkMode
                                          ? Colors.grey
                                          : Colors.black54),
                                  new Text(
                                    "My Events",
                                    style: TextStyle(
                                        fontSize: 13.0, color: currTextColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        new Padding(padding: EdgeInsets.all(2.0)),
                        new Expanded(
                          flex: 3,
                          child: new Card(
                            elevation: 2.0,
                            color: currCardColor,
                            child: new InkWell(
                              onTap: () {
                                if (currUser.groups.isNotEmpty) {
                                  router.navigateTo(context, '/home/handbook',
                                      transition: TransitionType.native);
                                } else {
                                  alert(
                                      "You are not a part of any groups. Please join a group to get access to your handbook.");
                                }
                              },
                              child: new Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new Icon(Icons.library_books,
                                      size: 35.0,
                                      color: darkMode
                                          ? Colors.grey
                                          : Colors.black54),
                                  new Text(
                                    "My Handbook",
                                    style: TextStyle(
                                        fontSize: 13.0, color: currTextColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        new Padding(padding: EdgeInsets.all(2.0)),
                      ],
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(2.0)),
                  new Container(
                    width: double.infinity,
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          flex: 5,
                          child: new Card(
                            elevation: 2.0,
                            color: currCardColor,
                            child: new InkWell(
                              onTap: () {
                                selectGroupDialog(currUser);
                              },
                              child: Row(
                                children: [
                                  new ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: 100),
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(left: 16, right: 16),
                                      child: new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          new Icon(Icons.group,
                                              size: 35.0,
                                              color: darkMode
                                                  ? Colors.grey
                                                  : Colors.black54),
                                          new Text(
                                            "My Groups",
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                color: currTextColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  new Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(top: 8, bottom: 8),
                                      child: new Wrap(
                                          direction: Axis.horizontal,
                                          children: groupsWidgetList),
                                    ),
                                  ),
                                  new Visibility(
                                    visible: currUser.groups.isEmpty,
                                    child: Container(
                                      child: new Text(
                                        "It looks like you are not part of any\ngroups. Click on this card to join a group.",
                                        style: TextStyle(color: currTextColor),
                                      ),
                                    ),
                                  ),
                                  new Padding(padding: EdgeInsets.all(8))
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(2.0)),
                  new Visibility(
                    visible: currUser.roles.contains("Developer") ||
                        currUser.roles.contains("Officer"),
                    child: new Container(
                      width: double.infinity,
                      height: 100.0,
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            flex: 3,
                            child: new Card(
                              color: currCardColor,
                              elevation: 2.0,
                              child: new InkWell(
                                onTap: () {
                                  sendNotificationDialog();
                                },
                                child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new Icon(
                                      Icons.notifications_active,
                                      size: 35.0,
                                      color: darkMode
                                          ? Colors.grey
                                          : Colors.black54,
                                    ),
                                    new Text(
                                      "Send Notification",
                                      style: TextStyle(
                                          fontSize: 13.0, color: currTextColor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          new Padding(padding: EdgeInsets.all(2.0)),
                          new Expanded(
                            flex: 5,
                            child: new Card(
                              elevation: 2.0,
                              color: currCardColor,
                              child: new InkWell(
                                onTap: () {
                                  router.navigateTo(
                                      context, "/home/manage-users",
                                      transition: TransitionType.native);
                                },
                                child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new Icon(Icons.supervised_user_circle,
                                        size: 35.0,
                                        color: darkMode
                                            ? Colors.grey
                                            : Colors.black54),
                                    new Text(
                                      "Manage Users",
                                      style: TextStyle(
                                          fontSize: 13.0, color: currTextColor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(2)),
                  new Visibility(
                      visible: currUser.roles.contains("Developer") ||
                          currUser.roles.contains("Advisor"),
                      child: new Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child:
                              new Divider(color: currDividerColor, height: 8))),
                  new Visibility(
                    visible: currUser.roles.contains("Developer") ||
                        currUser.roles.contains("Advisor"),
                    child: new Container(
                      width: double.infinity,
                      height: 100.0,
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            flex: 5,
                            child: new Card(
                              elevation: 2.0,
                              color: currCardColor,
                              child: new InkWell(
                                onTap: () {
                                  selectConferenceDialog(currUser);
                                },
                                child: Row(
                                  children: [
                                    new ConstrainedBox(
                                      constraints:
                                          BoxConstraints(minHeight: 100),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 16, right: 16),
                                        child: new Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            new Icon(Icons.event,
                                                size: 35.0,
                                                color: darkMode
                                                    ? Colors.grey
                                                    : Colors.black54),
                                            new Text(
                                              "My Conferences",
                                              style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: currTextColor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    new Expanded(
                                      child: Container(
                                        padding:
                                            EdgeInsets.only(top: 8, bottom: 8),
                                        child: new Wrap(
                                          direction: Axis.horizontal,
                                          children: conferenceWidgetList,
                                        ),
                                      ),
                                    ),
                                    new Visibility(
                                      visible: conferenceWidgetList.isEmpty,
                                      child: Container(
                                        child: new Text(
                                          "No conferences selected for this\nchapter. Click on this card to add\na conference.",
                                          style:
                                              TextStyle(color: currTextColor),
                                        ),
                                      ),
                                    ),
                                    new Padding(padding: EdgeInsets.all(8))
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(2.0)),
                  new Visibility(
                    visible: currUser.roles.contains("Developer") ||
                        currUser.roles.contains("Advisor"),
                    child: new Container(
                      width: double.infinity,
                      height: 100.0,
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            flex: 5,
                            child: new Card(
                              elevation: 2.0,
                              color: currCardColor,
                              child: new InkWell(
                                onTap: () {
                                  router.navigateTo(
                                      context, '/home/handbook/manage',
                                      transition: TransitionType.native);
                                },
                                child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new Icon(Icons.library_books,
                                        size: 35.0,
                                        color: darkMode
                                            ? Colors.grey
                                            : Colors.black54),
                                    new Text(
                                      "Manage Handbooks",
                                      style: TextStyle(
                                          fontSize: 13.0, color: currTextColor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          new Padding(padding: EdgeInsets.all(2.0)),
                          new Expanded(
                            flex: 3,
                            child: new Card(
                              elevation: 2.0,
                              color: currCardColor,
                              child: new InkWell(
                                onTap: () {
                                  router.navigateTo(
                                      context, "/home/manage-users",
                                      transition: TransitionType.native);
                                },
                                child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new Icon(Icons.supervised_user_circle,
                                        size: 35.0,
                                        color: darkMode
                                            ? Colors.grey
                                            : Colors.black54),
                                    new Text(
                                      "Manage Users",
                                      style: TextStyle(
                                          fontSize: 13.0, color: currTextColor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(2.0)),
                  new Visibility(
                    visible: currUser.roles.contains("Developer") ||
                        currUser.roles.contains("Advisor"),
                    child: new Container(
                      width: double.infinity,
                      height: 100.0,
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            flex: 3,
                            child: new Card(
                              color: currCardColor,
                              elevation: 2.0,
                              child: new InkWell(
                                onTap: () {
                                  sendNotificationDialog();
                                },
                                child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new Icon(
                                      Icons.notifications_active,
                                      size: 35.0,
                                      color: darkMode
                                          ? Colors.grey
                                          : Colors.black54,
                                    ),
                                    new Text(
                                      "Send Notification",
                                      style: TextStyle(
                                          fontSize: 13.0, color: currTextColor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          new Padding(padding: EdgeInsets.all(2.0)),
                          new Expanded(
                            flex: 5,
                            child: new Card(),
                          )
                        ],
                      ),
                    ),
                  ),
                  new Padding(padding: EdgeInsets.all(16))
                ],
              ),
            ),
          ),
        );
      }
    } else {
      return LoginPage();
    }
  }
}

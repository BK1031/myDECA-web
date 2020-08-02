import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:intl/intl.dart';
import 'package:mydeca_web/models/announcement.dart';
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

class AnnouncementsPage extends StatefulWidget {
  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {

  final Storage _localStorage = html.window.localStorage;

  List<Announcement> announcementList = new List();
  List<String> readAnnounceIds = new List();
  List<Widget> announcementWidgetList = new List();
  int unreadAnnounce = 0;

  User currUser = User.plain();

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
        getAnnouncements();
        fb.database().ref("users").child(currUser.userID).child("announcements").onChildAdded.listen((event) {
          print(event.snapshot.val());
          readAnnounceIds.add(event.snapshot.key);
          updateWidgetList();
        });
      });
    }
  }

  void getAnnouncements() {
    print(DateTime.now());
    // Get Chapter announcements
    fb.database().ref("chapters").child(currUser.chapter.chapterID).child("announcements").onChildAdded.listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      print("+ " + announcement.announcementID + announcement.topics.toString());
      // Check if user can see announcement
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          print("User in topic");
          fb.database().ref("users").child(announcement.author.userID).once("value").then((value) {
            announcement.author = new User.fromSnapshot(value.snapshot);
            fb.database().ref("users").child(currUser.userID).child("announcements").child(event.snapshot.key).once("value").then((value) {
              if (value.snapshot.val() != null) {
                announcement.read = true;
              }
              setState(() {
                announcementList.add(announcement);
              });
              updateWidgetList();
            });
          });
          break;
        }
      }
    });
    fb.database().ref("chapters").child(currUser.chapter.chapterID).child("announcements").onChildRemoved.listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      print("- " + announcement.announcementID);
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          var oldEntry = announcementList.singleWhere((entry) {
            return entry.announcementID == event.snapshot.key;
          });
          announcementList.removeAt(announcementList.indexOf(oldEntry));
          updateWidgetList();
        }
      }
    });
    // Get official announcements
    fb.database().ref("announcements").onChildAdded.listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      print("+ " + announcement.announcementID + announcement.topics.toString());
      // Check if user can see announcement
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          print("User in topic");
          fb.database().ref("users").child(announcement.author.userID).once("value").then((value) {
            announcement.author = new User.fromSnapshot(value.snapshot);
            fb.database().ref("users").child(currUser.userID).child("announcements").child(event.snapshot.key).once("value").then((value) {
              announcement.official = true;
              if (value.snapshot.val() != null) {
                announcement.read = true;
              }
              setState(() {
                announcementList.add(announcement);
              });
              updateWidgetList();
            });
          });
          break;
        }
      }
    });
    fb.database().ref("announcements").onChildRemoved.listen((event) {
      Announcement announcement = new Announcement.fromSnapshot(event.snapshot);
      print("- " + announcement.announcementID);
      for (int i = 0; i < currUser.roles.length; i++) {
        if (announcement.topics.contains(currUser.roles[i])) {
          var oldEntry = announcementList.singleWhere((entry) {
            return entry.announcementID == event.snapshot.key;
          });
          announcementList.removeAt(announcementList.indexOf(oldEntry));
          updateWidgetList();
        }
      }
    });
  }

  void updateWidgetList() {
    announcementList.sort((a,b) {
      return b.date.compareTo(a.date);
    });
    announcementWidgetList.clear();
    print("Rebuilding Announcement Widgets");
    setState(() {
      unreadAnnounce = announcementList.length;
      print(unreadAnnounce);
      for (int i = 0; i < announcementList.length; i++) {
        if (readAnnounceIds.contains(announcementList[i].announcementID)) unreadAnnounce--;
        announcementWidgetList.add(Container(
          padding: EdgeInsets.only(bottom: 8),
          child: new Card(
            color: currCardColor,
            child: new InkWell(
              onTap: () {
                print(announcementList[i].announcementID);
                router.navigateTo(context, '/home/announcements/details?id=${announcementList[i].announcementID}', transition: TransitionType.fadeIn);
              },
              child: new Container(
                padding: EdgeInsets.all(16.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.only(left: 8, right: 16),
                      child: new Icon(
                        Icons.notifications_active,
                        color: readAnnounceIds.contains(announcementList[i].announcementID) ? Colors.grey : mainColor,
                      )
                    ),
                    new Tooltip(
                      message: "${announcementList[i].author.firstName} ${announcementList[i].author.lastName}\n${announcementList[i].author.roles.first}\n${announcementList[i].author.email}",
                      child: new CircleAvatar(
                        radius: 25,
                        backgroundColor: roleColors[announcementList[i].author.roles.first],
                        child: new ClipRRect(
                          borderRadius: new BorderRadius.all(Radius.circular(45)),
                          child: new CachedNetworkImage(
                            imageUrl: announcementList[i].author.profileUrl,
                            height: 45,
                            width: 45,
                          ),
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(8.0)),
                    new Expanded(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              new Container(
                                child: new Text(
                                  announcementList[i].title,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold,
                                    color: readAnnounceIds.contains(announcementList[i].announcementID) ? currTextColor : mainColor,
                                  ),
                                ),
                              ),
                              new Padding(padding: EdgeInsets.all(4)),
                              new Visibility(
                                visible: announcementList[i].official,
                                child: new Tooltip(
                                  message: "Official DECA Communication",
                                  child: new Card(
                                    color: mainColor,
                                    child: new Container(
                                      padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                                      child: new Text("✓  VERIFIED", style: TextStyle(color: Colors.white),),
                                    ),
                                  ),
                                ),
                              ),
                              new Padding(padding: EdgeInsets.all(4)),
                              new Text(
                                "•   ${DateFormat("MMMd").format(announcementList[i].date)}",
                                style: TextStyle(color: Colors.grey, fontSize: 17),
                              )
                            ],
                          ),
                          new Padding(padding: EdgeInsets.all(4.0)),
                          new Container(
                            child: new Text(
                              announcementList[i].desc,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 17.0,
                                  color: currTextColor
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    new Container(
                      width: 50,
                      child: new Icon(
                        Icons.arrow_forward_ios,
                        color: readAnnounceIds.contains(announcementList[i].announcementID) ? Colors.grey : mainColor,
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
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
                new Padding(padding: EdgeInsets.only(bottom: 8.0)),
                Container(
                    padding: new EdgeInsets.only(top: 4.0, bottom: 4.0),
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Text(
                        "ANNOUNCEMENTS ($unreadAnnounce)",
                        style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                    )
                ),
                new Visibility(
                    visible: (announcementWidgetList.length == 0),
                    child: new Text("Nothing to see here!\nCheck back later for more announcements.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
                ),
                Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: announcementWidgetList,
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

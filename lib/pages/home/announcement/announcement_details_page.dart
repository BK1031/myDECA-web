import 'package:flutter/material.dart';
import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:mydeca_web/models/announcement.dart';
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

import 'package:url_launcher/url_launcher.dart';

class AnnouncementDetailsPage extends StatefulWidget {
  @override
  _AnnouncementDetailsPageState createState() =>
      _AnnouncementDetailsPageState();
}

class _AnnouncementDetailsPageState extends State<AnnouncementDetailsPage> {
  final Storage _localStorage = html.window.localStorage;
  Announcement announcement = new Announcement.plain();
  int unreadAnnounce = 0;

  User currUser = User.plain();

  final controller = ScrollController();

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
          print(currUser);
        });
        // Check for id
        if (html.window.location.toString().contains("?id=")) {
          fb
              .database()
              .ref("announcements")
              .child(html.window.location.toString().split("?id=")[1])
              .once("value")
              .then((value) {
            if (value.snapshot.val() != null) {
              print("Official Announcement");
              setState(() {
                announcement = new Announcement.fromSnapshot(value.snapshot);
                announcement.official = true;
              });
              fb
                  .database()
                  .ref("users")
                  .child(announcement.author.userID)
                  .once("value")
                  .then((value) {
                setState(() {
                  announcement.author = new User.fromSnapshot(value.snapshot);
                });
                print("Announcement by " + announcement.author.toString());
              });
            } else {
              print("Chapter Announcement");
              fb
                  .database()
                  .ref("chapters")
                  .child(currUser.chapter.chapterID)
                  .child("announcements")
                  .child(html.window.location.toString().split("?id=")[1])
                  .once("value")
                  .then((value) {
                setState(() {
                  announcement = new Announcement.fromSnapshot(value.snapshot);
                });
                fb
                    .database()
                    .ref("users")
                    .child(announcement.author.userID)
                    .once("value")
                    .then((value) {
                  setState(() {
                    announcement.author = new User.fromSnapshot(value.snapshot);
                  });
                  print("Announcement by " + announcement.author.toString());
                });
              });
            }
          });
          fb
              .database()
              .ref("users")
              .child(currUser.userID)
              .child("announcements")
              .child(html.window.location.toString().split("?id=")[1])
              .set(DateTime.now().toString());
        } else {
          router.navigateTo(context, "/home/announcements",
              transition: TransitionType.fadeIn);
        }
      });
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
                      new FlatButton(
                        child: new Text(
                          "Back to Announcements",
                          style: TextStyle(color: mainColor, fontSize: 15),
                        ),
                        onPressed: () {
                          router.navigateTo(context, '/home/announcements',
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
                  child: new Text(
                    announcement.title,
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 40,
                        color: currTextColor),
                    textAlign: TextAlign.start,
                  ),
                ),
                new Container(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  width: (MediaQuery.of(context).size.width > 1300)
                      ? 1100
                      : MediaQuery.of(context).size.width - 50,
                  child: new Row(
                    children: [
                      new CircleAvatar(
                        radius: 25,
                        backgroundColor: announcement.author.roles.length != 0
                            ? roleColors[announcement.author.roles.first]
                            : currTextColor,
                        child: new ClipRRect(
                          borderRadius:
                              new BorderRadius.all(Radius.circular(45)),
                          child: new CachedNetworkImage(
                            imageUrl: announcement.author.profileUrl,
                            height: 45,
                            width: 45,
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(8)),
                      new Tooltip(
                        message: "Topics: ${announcement.topics}",
                        child: new Text(
                          "${announcement.author.firstName} ${announcement.author.lastName} | ${announcement.author.roles.length != 0 ? announcement.author.roles.first : ""}",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 20.0,
                              color: announcement.author.roles.length != 0
                                  ? roleColors[announcement.author.roles.first]
                                  : currTextColor),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(4)),
                      new Visibility(
                        visible: announcement.official,
                        child: new Tooltip(
                          message: "Official DECA Communication",
                          child: new Card(
                            color: mainColor,
                            child: new Container(
                              padding: EdgeInsets.only(
                                  top: 4, bottom: 4, left: 8, right: 8),
                              child: new Text(
                                "✓  VERIFIED",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(4)),
                      new Text(
                        "•   ${DateFormat().format(announcement.date)}",
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                      )
                    ],
                  ),
                ),
                new Container(
                  height: MediaQuery.of(context).size.height * 2 / 3,
                  width: (MediaQuery.of(context).size.width > 1300)
                      ? 1100
                      : MediaQuery.of(context).size.width - 50,
                  child: new Markdown(
                    data: announcement.desc,
                    controller: controller,
                    selectable: true,
                    styleSheet: markdownStyle,
                    onTapLink: (String url, String a, String b) {
                      launch(url);
                    },
                  ),
                )
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

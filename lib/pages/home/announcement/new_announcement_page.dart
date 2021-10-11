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
import 'package:mydeca_web/pages/home/announcement/announcement_confirm_dialog.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;
import 'package:flutter/src/painting/text_style.dart' as ts;
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/theme.dart';

class NewAnnouncementPage extends StatefulWidget {
  @override
  _NewAnnouncementPageState createState() => _NewAnnouncementPageState();
}

class _NewAnnouncementPageState extends State<NewAnnouncementPage> {
  final Storage _localStorage = html.window.localStorage;
  Announcement announcement = new Announcement.plain();

  PageController _controller = PageController(initialPage: 0);
  int currPage = 0;

  User currUser = User.plain();

  double previewWidth = 0.0;
  double targetHeight = 30.0;

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
          announcement.author = currUser;
        });
      });
    }
  }

  void confirmDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              "Select Target",
              style: TextStyle(color: currTextColor),
            ),
            backgroundColor: currCardColor,
            content: new AnnouncementConfirmDialog(announcement),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorage["userID"] != null) {
      return new Scaffold(
        floatingActionButton: new FloatingActionButton.extended(
          icon: Icon(Icons.send),
          label: new Text("PUBLISH"),
          onPressed: () {
            if (fb.auth().currentUser != null) {
              if (announcement.title != "" && announcement.desc != "") {
                confirmDialog();
              } else {
                html.window.alert(
                    "Please make sure that you fill out all the fields!");
              }
            } else {
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
                  child: new TextField(
                    maxLines: 1,
                    onChanged: (input) {
                      setState(() {
                        announcement.title = input;
                      });
                    },
                    decoration: InputDecoration(
                        labelText: "Announcement Title",
                        border: InputBorder.none),
                    style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 30,
                        color: currTextColor),
                  ),
                ),
//                Container(
//                  padding: EdgeInsets.all(16),
//                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
//                  child: new Text(
//                    announcement.title,
//                    style: TextStyle(fontFamily: "Montserrat", fontSize: 40, color: currTextColor),
//                    textAlign: TextAlign.start,
//                  ),
//                ),
                new Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
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
                        visible: currUser.roles.contains("Developer"),
                        child: new Tooltip(
                          message: announcement.official
                              ? "Official DECA Communication"
                              : "",
                          child: new InkWell(
                            onTap: () {
                              setState(() {
                                announcement.official = !announcement.official;
                              });
                            },
                            child: new Card(
                              color: announcement.official
                                  ? mainColor
                                  : Colors.grey,
                              child: new Container(
                                padding: EdgeInsets.only(
                                    top: 4, bottom: 4, left: 8, right: 8),
                                child: new Text(
                                  announcement.official
                                      ? "✓  VERIFIED"
                                      : "UNOFFICIAL",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(4)),
                      new Text(
                        "•   ${DateFormat().format(announcement.date)}",
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                      ),
                      new Padding(padding: EdgeInsets.all(8)),
                      new IconButton(
                        tooltip: "Toggle Preview",
                        icon: new Icon(previewWidth == 0
                            ? Icons.visibility_off
                            : Icons.visibility),
                        color: Colors.grey,
                        onPressed: () {
                          setState(() {
                            if (previewWidth == 0) {
                              previewWidth =
                                  (MediaQuery.of(context).size.width > 1300)
                                      ? 1100 / 2
                                      : (MediaQuery.of(context).size.width -
                                              50) /
                                          2;
                            } else {
                              previewWidth = 0;
                            }
                          });
                        },
                      )
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(top: 16),
                    width: (MediaQuery.of(context).size.width > 1300)
                        ? 1100
                        : MediaQuery.of(context).size.width - 50,
                    height: 1000,
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Expanded(
                          child: new Container(
                            margin: EdgeInsets.all(20),
                            child: TextField(
                              maxLines: null,
                              onChanged: (value) {
                                setState(() {
                                  announcement.desc = value;
                                });
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    '# Heading\n\nWrite your announcement here, markdown is supported!',
                              ),
                            ),
                          ),
                        ),
                        new AnimatedContainer(
                          width: previewWidth,
                          duration: const Duration(milliseconds: 300),
                          child: new Markdown(
                            data: announcement.desc,
                            selectable: true,
                            styleSheet: markdownStyle,
                            onTapLink: (text, url, title) {
                              launch(url);
                            },
                          ),
                        ),
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

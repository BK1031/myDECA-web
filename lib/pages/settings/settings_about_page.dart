import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:intl/intl.dart';
import 'package:mydeca_web/models/announcement.dart';
import 'package:mydeca_web/models/meeting.dart';
import 'package:mydeca_web/models/user.dart';
import 'dart:io' as io;
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/navbars/mobile_sidebar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/pages/home/advisor/advisor_conference_select.dart';
import 'package:mydeca_web/pages/home/advisor/send_notification_dialog.dart';
import 'package:mydeca_web/pages/home/join_group_dialog.dart';
import 'package:mydeca_web/pages/home/welcome_dialog.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;
import 'package:flutter/src/painting/text_style.dart' as ts;
import 'package:url_launcher/url_launcher.dart';

class SettingsAboutPage extends StatefulWidget {
  @override
  _SettingsAboutPageState createState() => _SettingsAboutPageState();
}

class _SettingsAboutPageState extends State<SettingsAboutPage> {

  final Storage _localStorage = html.window.localStorage;

  User currUser = User.plain();

  String devicePlatform = "";
  String deviceName = "";

  @override
  void initState() {
    super.initState();
    if (_localStorage.containsKey("userID")) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
      });
    }
    devicePlatform = "Web";
  }

  launchContributeUrl() async {
    const url = 'https://github.com/equinox-initiative/myDECA-flutter';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchGuidelinesUrl() async {
    const url = 'https://github.com/equinox-initiative/myDECA-flutter/wiki/contributing';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
                    new Padding(padding: EdgeInsets.only(bottom: 16.0)),
                    new Container(
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new FlatButton(
                            child: new Text("Back to Settings", style: TextStyle(color: mainColor, fontSize: 15),),
                            onPressed: () {
                              router.navigateTo(context, '/settings', transition: TransitionType.fadeIn);
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: new Card(
                        color: currCardColor,
                        child: Column(
                          children: <Widget>[
                            new Container(
                              padding: EdgeInsets.only(top: 16.0),
                              child: new Text("device".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 18, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                            ),
                            new ListTile(
                              title: new Text("App Version", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                              trailing: new Text("$appVersion$appStatus", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                            ),
                            new ListTile(
                              title: new Text("Device Name", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                              trailing: new Text("$deviceName", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                            ),
                            new ListTile(
                              title: new Text("Platform", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                              trailing: new Text("$devicePlatform", style: TextStyle(color: currTextColor, fontSize: 17.0)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(4)),
                    Container(
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: new Card(
                        color: currCardColor,
                        child: Column(
                          children: <Widget>[
                            new Container(
                              padding: EdgeInsets.only(top: 16.0),
                              child: new Text("credits".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 18, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                            ),
                            new ListTile(
                              title: new Text("Bharat Kathi", style: TextStyle(color: currTextColor, fontSize: 17,)),
                              subtitle: new Text("App Development", style: TextStyle(color: Colors.grey)),
                              onTap: () {
                                const url = 'https://www.instagram.com/bk1031_official';
                                launch(url);
                              },
                            ),
                            new ListTile(
                              title: new Text("Jennifer Song", style: TextStyle(color: currTextColor, fontSize: 17,)),
                              subtitle: new Text("App Development", style: TextStyle(color: Colors.grey)),
                              onTap: () {
                                const url = 'https://www.instagram.com/jenyfur_soong/';
                                launch(url);
                              },
                            ),
                            new ListTile(
                              title: new Text("Myron Chan", style: TextStyle(color: currTextColor, fontSize: 17)),
                              subtitle: new Text("App Design", style: TextStyle(color: Colors.grey)),
                              onTap: () {
                                const url = 'https://www.instagram.com/myronchan_/';
                                launch(url);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(4)),
                    Container(
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: new Card(
                        color: currCardColor,
                        child: Column(
                          children: <Widget>[
                            new Container(
                              padding: EdgeInsets.only(top: 16.0),
                              child: new Text("contributing".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                            ),
                            new ListTile(
                              title: new Text("View on GitHub", style: TextStyle(color: currTextColor, fontSize: 17,)),
                              trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                              onTap: () {
                                launchContributeUrl();
                              },
                            ),
                            new ListTile(
                              title: new Text("Contributing Guidelines", style: TextStyle(color: currTextColor, fontSize: 17,)),
                              trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                              onTap: () {
                                launchGuidelinesUrl();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(16.0)),
                    new InkWell(
                      child: new Text("© Equinox Initiative 2020", style: TextStyle(color: Colors.grey),),
                      splashColor: currBackgroundColor,
                      highlightColor: currCardColor,
                      onTap: () {
                        launch("https://equinox.bk1031.dev");
                      },
                    ),
                    new InkWell(
                      splashColor: currBackgroundColor,
                      highlightColor: currCardColor,
                      onTap: () {
                        launch("https://equinox.bk1031.dev");
                      },
                      child: new Image.asset(
                        'images/full_black_trans.png',
                        height: 120.0,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }
      else {
        return Container();
      }
    }
    else {
      return LoginPage();
    }
  }
}

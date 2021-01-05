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
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final Storage _localStorage = html.window.localStorage;

  User currUser = User.plain();

  bool mobilePush = true;
  bool webPush = true;
  bool emailPush = true;

  @override
  void initState() {
    super.initState();
    if (_localStorage.containsKey("userID")) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
        getNotificationPrefs();
      });
    }
  }

  void stopNotifDialog(String type) {
    showDialog(
        context: context,
        child: new AlertDialog(
          backgroundColor: currCardColor,
          title: new Text("Stop Receiving ${type == "mobilePush" ? "Push" : (type == "webPush" ? "Web" : "Email")} Notifications?", style: TextStyle(color: currTextColor),),
          content: new Text("Are you sure you want to stop receiving these notifications? You may miss important announcements, meeting updates, and conference information.", style: TextStyle(color: currTextColor)),
          actions: [
            new FlatButton(
                child: new Text("CANCEL"),
                textColor: mainColor,
                onPressed: () {
                  router.pop(context);
                }
            ),
            new FlatButton(
                child: new Text("DISABLE NOTIFICATIONS"),
                textColor: Colors.red,
                onPressed: () {
                  fb.database().ref("users").child(currUser.userID).child(type).set(false);
                  router.pop(context);
                  getNotificationPrefs();
                }
            )
          ],
        )
    );
  }

  getNotificationPrefs() {
    fb.database().ref("users").child(currUser.userID).child("mobilePush").once("value").then((value) {
      if (value.snapshot.val() != null) {
        setState(() {
          mobilePush = false;
        });
      }
      else {
        setState(() {
          mobilePush = true;
        });
      }
    });
    fb.database().ref("users").child(currUser.userID).child("webPush").once("value").then((value) {
      if (value.snapshot.val() != null) {
        setState(() {
          webPush = false;
        });
      }
      else {
        setState(() {
          webPush = true;
        });
      }
    });
    fb.database().ref("users").child(currUser.userID).child("emailPush").once("value").then((value) {
      if (value.snapshot.val() != null) {
        setState(() {
          emailPush = false;
        });
      }
      else {
        setState(() {
          emailPush = true;
        });
      }
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
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: new Card(
                        color: currCardColor,
                        child: new Column(
                          children: <Widget>[
                            new Container(
                              padding: EdgeInsets.only(top: 16.0),
                              child: new Text("${currUser.firstName} ${currUser.lastName}".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                            ),
                            new ListTile(
                              title: new Text("Email", style: TextStyle(fontSize: 17, color: currTextColor),),
                              trailing: new Text(currUser.email, style: TextStyle(fontSize: 17, color: currTextColor)),
                            ),
                            new ListTile(
                              title: new Text("User ID", style: TextStyle(fontSize: 17, color: currTextColor)),
                              trailing: new Text(currUser.userID, style: TextStyle(fontSize: 14.0, color: currTextColor)),
                            ),
                            new ListTile(
                              title: new Text("Update Profile", style: TextStyle(color: mainColor), textAlign: TextAlign.center,),
                              onTap: () {
                                router.navigateTo(context, '/profile', transition: TransitionType.nativeModal);
                              },
                            )
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
                              child: new Text("General".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                            ),
                            new ListTile(
                              title: new Text("About", style: TextStyle(fontSize: 17, color: currTextColor)),
                              trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                              onTap: () {
                                router.navigateTo(context, '/settings/about', transition: TransitionType.native);
                              },
                            ),
                            new ListTile(
                              title: new Text("Help", style: TextStyle(fontSize: 17, color: currTextColor)),
                              trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                              onTap: () async {
                                const url = 'https://docs.mydeca.org';
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                            ),
                            new ListTile(
                                title: new Text("Legal", style: TextStyle(fontSize: 17, color: currTextColor)),
                                trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                                onTap: () {
                                  showLicensePage(
                                      context: context,
                                      applicationVersion: appFull + appStatus,
                                      applicationName: "myDECA App",
                                      applicationLegalese: appLegal,
                                      applicationIcon: new Image.asset(
                                        'images/deca-diamond.png',
                                        height: 35.0,
                                      )
                                  );
                                }
                            ),
                            new ListTile(
                                title: new Text("Terms", style: TextStyle(fontSize: 17, color: currTextColor)),
                                trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                                onTap: () {
                                  launch("https://docs.mydeca.org/tos");
                                }
                            ),
                            new ListTile(
                                title: new Text("Privacy", style: TextStyle(fontSize: 17, color: currTextColor)),
                                trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                                onTap: () {
                                  launch("https://docs.mydeca.org/privacy");
                                }
                            ),
                            new ListTile(
                                title: new Text("Export Personal Information", style: TextStyle(fontSize: 17, color: currTextColor)),
                                trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                      title: new Text("Export My Data"),
                                      content: Container(width: 500, child: new Text("As a part of our commitment to your privacy, you may request a copy of all the personal information we have stored. This information includes, but is not limited to, user data, chapter data, announcement data, meeting data, and chat data.\n\nThis will be sent as a text file to your email within the next 6 hours.")),
                                      actions: [
                                        new FlatButton(
                                          child: new Text("CANCEL"),
                                          onPressed: () {
                                            router.pop(context);
                                          },
                                        ),
                                        new FlatButton(
                                          child: new Text("EXPORT"),
                                          onPressed: () {
                                            fb.database().ref("dataExport").push().set(currUser.userID);
                                            router.pop(context);
                                          },
                                        )
                                      ],
                                    )
                                  );
                                }
                            ),
                            new ListTile(
                              title: new Text("Sign Out", style: TextStyle(fontSize: 17, color: Colors.red),),
                              onTap: () async {
                                await fb.auth().signOut();
                                _localStorage.remove("userID");
                                router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
                              },
                            ),
                            new ListTile(
                              title: new Text("Delete Account", style: TextStyle(color: Colors.red, fontSize: 17),),
                              subtitle: new Text("\nDeleting your myDECA Account will remove all the data linked to your account as well. You will be required to create a new account in order to sign in again.\n", style: TextStyle(color: Colors.grey)),
                              onTap: () {

                              },
                            )
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
                              child: new Text("Preferences".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                            ),
                            new SwitchListTile.adaptive(
                              activeColor: mainColor,
                              activeTrackColor: mainColor,
                              value: mobilePush,
                              onChanged: (val) {
                                if (!val) {
                                  stopNotifDialog("mobilePush");
                                }
                                else {
                                  fb.database().ref("users").child(currUser.userID).child("mobilePush").remove();
                                  setState(() {
                                    mobilePush = val;
                                  });
                                }
                              },
                              title: new Text("Push Notifications", style: TextStyle(fontSize: 17, color: currTextColor)),
                            ),
                            new SwitchListTile.adaptive(
                              activeColor: mainColor,
                              activeTrackColor: mainColor,
                              value: webPush,
                              onChanged: (val) {
                                if (!val) {
                                  stopNotifDialog("webPush");
                                }
                                else {
                                  fb.database().ref("users").child(currUser.userID).child("webPush").remove();
                                  setState(() {
                                    webPush = val;
                                  });
                                }
                              },
                              title: new Text("Web Notifications", style: TextStyle(fontSize: 17, color: currTextColor)),
                            ),
                            new SwitchListTile.adaptive(
                              activeColor: mainColor,
                              activeTrackColor: mainColor,
                              value: emailPush,
                              onChanged: (val) {
                                if (!val) {
                                  stopNotifDialog("emailPush");
                                }
                                else {
                                  fb.database().ref("users").child(currUser.userID).child("emailPush").remove();
                                  setState(() {
                                    emailPush = val;
                                  });
                                }
                              },
                              title: new Text("Email Notifications", style: TextStyle(fontSize: 17, color: currTextColor)),
                            ),
                            new Visibility(
                              visible: (currUser.roles.contains('Developer')),
                              child: new SwitchListTile.adaptive(
                                activeColor: mainColor,
                                activeTrackColor: mainColor,
                                title: new Text("Dark Mode", style: TextStyle(fontSize: 17, color: currTextColor)),
                                value: darkMode,
                                onChanged: (bool value) {
                                  // Toggle Dark Mode
                                  setState(() {
                                    darkMode = value;
                                    if (darkMode) {
                                      currTextColor = darkTextColor;
                                      currBackgroundColor = darkBackgroundColor;
                                      currCardColor = darkCardColor;
                                      currDividerColor = darkDividerColor;
                                    }
                                    else {
                                      currTextColor = lightTextColor;
                                      currBackgroundColor = lightBackgroundColor;
                                      currCardColor = lightCardColor;
                                      currDividerColor = lightDividerColor;
                                    }
                                    fb.database().ref("users").child(currUser.userID).update({"darkMode": darkMode});
                                  });
                                },
                              ),
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
                              child: new Text("Feedback".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                            ),
                            new ListTile(
                              title: new Text("Provide Feedback", style: TextStyle(fontSize: 17, color: currTextColor)),
                              trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                              onTap: () async {
                                const url = 'https://forms.gle/8UMH4V5Ty79qFEnNA';
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                            ),
                            new ListTile(
                              title: new Text("Report a Bug", style: TextStyle(fontSize: 17, color: currTextColor)),
                              trailing: new Icon(Icons.arrow_forward_ios, color: mainColor),
                              onTap: () async {
                                const url = 'https://github.com/Equinox-Initiative/myDECA-flutter/issues';
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(4)),
                    new Visibility(
                      visible: (currUser.roles.contains('Developer')),
                      child: Container(
                        width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                        child: new Column(
                          children: <Widget>[
                            new Card(
                              color: currCardColor,
                              child: Column(
                                children: <Widget>[
                                  new Container(
                                    padding: EdgeInsets.only(top: 16.0),
                                    child: new Text("developer".toUpperCase(), style: TextStyle(color: mainColor, fontSize: 17, fontFamily: "Montserrat", fontWeight: FontWeight.bold),),
                                  ),
                                  new ListTile(
                                    leading: new Icon(Icons.developer_mode, color: darkMode ? Colors.grey : Colors.black54,),
                                    title: new Text("Test Firebase Upload", style: TextStyle(fontSize: 17, color: currTextColor)),
                                    onTap: () {
                                      fb.database().ref("testing").push().set("${currUser.firstName} - ${currUser.roles.first}");
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(16.0))
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

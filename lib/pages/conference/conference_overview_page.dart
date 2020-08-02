import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/chapter.dart';
import 'dart:ui' as ui;
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/pages/conference/conference_media_page.dart';
import 'package:mydeca_web/pages/conference/conference_overview_page.dart';
import 'package:mydeca_web/pages/conference/conference_schedule_page.dart';
import 'package:mydeca_web/pages/conference/conference_winner_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

import 'package:url_launcher/url_launcher.dart';

class ConferenceOverviewPage extends StatefulWidget {
  @override
  _ConferenceOverviewPageState createState() => _ConferenceOverviewPageState();
}

class _ConferenceOverviewPageState extends State<ConferenceOverviewPage> {

  final Storage _localStorage = html.window.localStorage;

  Conference conference = new Conference.plain();

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("conferences").child(html.window.location.toString().split("?id=")[1]).once("value").then((value) {
        setState(() {
          conference = new Conference.fromSnapshot(value.snapshot);
        });
      });
    }
  }

  void missingDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("File Not Found"),
          content: new Text(
            "It looks like this file may not have been added yet. Please check back later.",
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("GOT IT"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              padding: new EdgeInsets.only(top: 4.0, bottom: 4.0),
              width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
              child: new Text(
                  "RESOURCES",
                  style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
              )
          ),
          InkWell(
            onTap: () {
              print(conference.hotelMapUrl);
              if (conference.hotelMapUrl != "") {
                html.window.open(conference.hotelMapUrl, "Hotel Map");
              }
              else {
                missingDataDialog();
              }
            },
            child: new ListTile(
              title: new Text("Hotel Map", style: TextStyle(color: currTextColor, fontSize: 18),),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: mainColor,
              ),
            ),
          ),
          new InkWell(
            onTap: () {
              print(conference.alertsUrl);
              if (conference.alertsUrl != "") {
                html.window.open(conference.alertsUrl, "Alerts");
              }
              else {
                missingDataDialog();
              }
            },
            child: new ListTile(
              title: new Text("Announcements", style: TextStyle(color: currTextColor, fontSize: 18),),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: mainColor,
              ),
            ),
          ),
          new InkWell(
            onTap: () {
              print(conference.eventsUrl);
              if (conference.eventsUrl != "") {
                html.window.open(conference.eventsUrl, "Competitive Event Schedule");
              }
              else {
                missingDataDialog();
              }
            },
            child: new ListTile(
              title: new Text("Competitive Event Schedule", style: TextStyle(color: currTextColor, fontSize: 18),),
              trailing: new Icon(
                Icons.arrow_forward_ios,
                color: mainColor,
              ),
            ),
          ),
          new InkWell(
            onTap: () {
              print(conference.siteUrl);
              if (conference.siteUrl != "") {
                html.window.open(conference.siteUrl, "Conference Site");
              }
              else {
                missingDataDialog();
              }
            },
            child: new ListTile(
              title: new Text("Check out the official conference website", style: TextStyle(color: mainColor), textAlign: TextAlign.center,),
            ),
          )
        ],
      )
    );
  }
}

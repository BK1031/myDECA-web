import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

import 'package:progress_indicators/progress_indicators.dart';

class ConferencesPage extends StatefulWidget {
  @override
  _ConferencesPageState createState() => _ConferencesPageState();
}

class _ConferencesPageState extends State<ConferencesPage> {

  final Storage _localStorage = html.window.localStorage;
  User currUser = User.plain();

  List<Conference> conferenceList = new List();
  List<Conference> pastConferenceList = new List();
  List<Widget> widgetList = new List();
  List<Widget> pastWidgetList = new List();

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("conferences").onChildAdded.listen((event) {
        setState(() {
          Conference conference = new Conference.fromSnapshot(event.snapshot);
          print(conference.conferenceID);
          Widget conferenceCard = new Padding(
            padding: new EdgeInsets.only(bottom: 4.0),
            child: new Card(
              color: Colors.white,
              elevation: 2.0,
              child: Container(
                width: 400,
                child: new InkWell(
                  onTap: () {
                    router.navigateTo(context, 'conferences/details?id=${conference.conferenceID}', transition: TransitionType.fadeIn);
                  },
                  child: new Stack(
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      new ClipRRect(
                        child: new CachedNetworkImage(
                          placeholder: (context, url) => new Container(
                            child: new GlowingProgressIndicator(
                              child: new Image.asset('images/deca-diamond.png', height: 75.0,),
                            ),
                          ),
                          imageUrl: conference.imageUrl,
                          height: 150.0,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      new Container(
                        height: 150.0,
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              conference.conferenceID.split("-")[1],
                              style: TextStyle(fontFamily: "Gotham", fontSize: 35.0, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            new Text(
                              conference.conferenceID.split("-")[0],
                              style: TextStyle(fontSize: 20.0, color: Colors.white, decoration: TextDecoration.overline),
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
          if (conference.past) {
            pastConferenceList.add(conference);
            pastWidgetList.add(conferenceCard);
          }
          else {
            conferenceList.add(conference);
            widgetList.add(conferenceCard);
          }
        });
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
                new Padding(padding: EdgeInsets.only(bottom: 8.0)),
                Container(
                    padding: new EdgeInsets.only(top: 4.0, bottom: 4.0),
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Text(
                        "MY CONFERENCES",
                        style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                    )
                ),
                new Visibility(
                    visible: (conferenceList.length == 0),
                    child: new Text("Nothing to see here!\nCheck back later for conferences.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
                ),
                Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Wrap(
                    direction: Axis.horizontal,
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: widgetList,
                  ),
                ),
                Container(
                  padding: new EdgeInsets.only(top: 4.0, bottom: 4.0),
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Text(
                    "PAST CONFERENCES",
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor)
                  )
                ),
                new Visibility(
                    visible: (pastConferenceList.length == 0),
                    child: new Text("Nothing to see here!\nCheck back later for conferences.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
                ),
                Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Wrap(
                    direction: Axis.horizontal,
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: pastWidgetList,
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

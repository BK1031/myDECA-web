import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/competitive_event.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/navbars/mobile_sidebar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

import '../../utils/theme.dart';
import '../../utils/theme.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  final Storage _localStorage = html.window.localStorage;

  User currUser = User.plain();

  List<Widget> eventsList = new List();

  @override
  void initState() {
    super.initState();
    fb.database().ref("events").onChildAdded.listen((event) {
      CompetitiveEvent competitiveEvent = new CompetitiveEvent.fromSnapshot(event.snapshot);
      bool add = true;
      if (html.window.location.toString().contains("?online") && competitiveEvent.type != "online") {
        add = false;
      }
      if (html.window.location.toString().contains("?written") && competitiveEvent.type != "written") {
        add = false;
      }
      if (html.window.location.toString().contains("?roleplay") && competitiveEvent.type != "roleplay") {
        add = false;
      }
      if (html.window.location.toString().contains("?Business-Management") && competitiveEvent.cluster != "Business Management") {
        add = false;
      }
      if (html.window.location.toString().contains("?Entrepreneurship") && competitiveEvent.cluster != "Entrepreneurship") {
        add = false;
      }
      if (html.window.location.toString().contains("?Finance") && competitiveEvent.cluster != "Finance") {
        add = false;
      }
      if (html.window.location.toString().contains("?Hospitality-Tourism") && competitiveEvent.cluster != "Hospitality + Tourism") {
        add = false;
      }
      if (html.window.location.toString().contains("?Marketing") && competitiveEvent.cluster != "Marketing") {
        add = false;
      }
      if (html.window.location.toString().contains("?Personal-Financial-Literacy") && competitiveEvent.cluster != "Personal Financial Literacy") {
        add = false;
      }
      // Now check if add
      if (add) {
        print("Adding ${competitiveEvent.id}");
        setState(() {
          eventsList.add(new Container(
            padding: EdgeInsets.only(bottom: 8.0),
            child: new Card(
              color: currCardColor,
              child: new ListTile(
                onTap: () {
                  print(competitiveEvent.id);
                  router.navigateTo(context, '/events/details?id=${competitiveEvent.id}', transition: TransitionType.fadeIn);
                },
                leading: Container(
                  width: 200,
                  child: Row(
                    children: [
                      getLeadingPic(competitiveEvent.cluster),
                      new Padding(padding: EdgeInsets.all(4)),
                      new Text(
                        competitiveEvent.id,
                        style: TextStyle(color: getCategoryColor(competitiveEvent.cluster), fontSize: 17.0, fontWeight: FontWeight.bold, fontFamily: "Montserrat"),
                      ),
                    ],
                  ),
                ),
                title: new Text(
                  competitiveEvent.name,
                  textAlign: TextAlign.start,
                  style: TextStyle(color: currTextColor, fontWeight: FontWeight.normal),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: eventColor),
              ),
            )
          ));
        });
      }
    });
  }

  Widget getLeadingPic(String name) {
    String imagePath = "";
    if (name == "Business Management") {
      imagePath = 'images/business.png';
    }
    else if (name == "Entrepreneurship") {
      imagePath = 'images/entrepreneurship.png';
    }
    else if (name == "Finance") {
      imagePath = 'images/finance.png';
    }
    else if (name == "Hospitality + Tourism") {
      imagePath = 'images/hospitality.png';
    }
    else if (name == "Marketing") {
      imagePath = 'images/marketing.png';
    }
    else if (name == "Personal Financial Literacy") {
      imagePath = 'images/personal-finance.png';
    }
    else {
      imagePath = 'images/deca-diamond.png';
    }
    return Image.asset(
      imagePath,
      height: 35.0,
    );
  }

  Color getCategoryColor(String name) {
    if (name == "Business Management") {
      return Color(0xFFfcc414);
      print("YELLOW");
    }
    else if (name == "Entrepreneurship") {
      return Color(0xFF818285);
      print("GREY");
    }
    else if (name == "Finance") {
      return Color(0xFF049e4d);
      print("GREEN");
    }
    else if (name == "Hospitality + Tourism") {
      return Color(0xFF046faf);
      print("INDIGO");
    }
    else if (name == "Marketing") {
      return Color(0xFFe4241c);
      print("RED");
    }
    else if (name == "Personal Financial Literacy") {
      return Color(0xFF7cc242);
      print("LT GREEN");
    }
    else {
      return mainColor;
      print("COLOR NOT FOUND");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localStorage["userID"] != null) {
      if (MediaQuery.of(context).size.width > 600) {
        return new Scaffold(
          body: Container(
            child: new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HomeNavbar(),
                  new Container(
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    padding: EdgeInsets.all(16),
                    child: new Center(
                        child: new Text("Filter events below.", style: TextStyle(color: currTextColor, fontSize: 16))
                    ),
                  ),
                  new Container(
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      padding: EdgeInsets.all(8),
                      child: new Wrap(
                        direction: Axis.horizontal,
                        children: [
                          new RaisedButton(
                            child: new Text("WRITTEN"),
                            textColor: html.window.location.toString().contains("?written") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?written") ? mainColor : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?written") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?written")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?written", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?written", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("ROLEPLAY"),
                            textColor: html.window.location.toString().contains("?roleplay") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?roleplay") ? mainColor : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?roleplay") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?roleplay")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?roleplay", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?roleplay", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("ONLINE"),
                            textColor: html.window.location.toString().contains("?online") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?online") ? mainColor : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?online") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?online")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?online", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?online", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("BUSINESS MANAGEMENT"),
                            textColor: html.window.location.toString().contains("?Business-Management") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Business-Management") ? getCategoryColor("Business Management") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Business-Management") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Business-Management")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Business-Management", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Business-Management", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("Entrepreneurship".toUpperCase()),
                            textColor: html.window.location.toString().contains("?Entrepreneurship") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Entrepreneurship") ? getCategoryColor("Entrepreneurship") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Entrepreneurship") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Entrepreneurship")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Entrepreneurship", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Entrepreneurship", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("Finance".toUpperCase()),
                            textColor: html.window.location.toString().contains("?Finance") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Finance") ? getCategoryColor("Finance") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Finance") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Finance")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Finance", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Finance", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("Hospitality + Tourism".toUpperCase()),
                            textColor: html.window.location.toString().contains("?Hospitality-Tourism") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Hospitality-Tourism") ? getCategoryColor("Hospitality + Tourism") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Hospitality-Tourism") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Hospitality-Tourism")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Hospitality-Tourism", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Hospitality-Tourism", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("Marketing".toUpperCase()),
                            textColor: html.window.location.toString().contains("?Marketing") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Marketing") ? getCategoryColor("Marketing") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Marketing") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Marketing")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Marketing", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Marketing", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("Personal Financial Literacy".toUpperCase()),
                            textColor: html.window.location.toString().contains("?Personal-Financial-Literacy") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Personal-Financial-Literacy") ? getCategoryColor("Personal Financial Literacy") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Personal-Financial-Literacy") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Personal-Financial-Literacy")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Personal-Financial-Literacy", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Personal-Financial-Literacy", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                        ],
                      )
                  ),
                  new Visibility(
                    visible: eventsList.isEmpty,
                    child: new Container(
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      padding: EdgeInsets.all(16),
                      child: new Center(
                          child: new Text("No events found matching that filter.", style: TextStyle(color: currTextColor, fontSize: 16))
                      ),
                    ),
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Column(
                        children: eventsList
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
      else {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Events", style: TextStyle(color: Colors.white, fontFamily: "Montserrat"),),
          ),
          drawer: new Drawer(child: new MobileSidebar(),),
          body: Container(
            child: new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Container(
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    padding: EdgeInsets.all(16),
                    child: new Center(
                        child: new Text("Filter events below.", style: TextStyle(color: currTextColor, fontSize: 16))
                    ),
                  ),
                  new Container(
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      padding: EdgeInsets.all(8),
                      child: new Wrap(
                        direction: Axis.horizontal,
                        children: [
                          new RaisedButton(
                            child: new Text("WRITTEN"),
                            textColor: html.window.location.toString().contains("?written") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?written") ? mainColor : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?written") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?written")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?written", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?written", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("ROLEPLAY"),
                            textColor: html.window.location.toString().contains("?roleplay") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?roleplay") ? mainColor : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?roleplay") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?roleplay")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?roleplay", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?roleplay", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("ONLINE"),
                            textColor: html.window.location.toString().contains("?online") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?online") ? mainColor : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?online") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?online")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?online", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?online", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("BUSINESS MANAGEMENT"),
                            textColor: html.window.location.toString().contains("?Business-Management") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Business-Management") ? getCategoryColor("Business Management") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Business-Management") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Business-Management")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Business-Management", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Business-Management", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("Entrepreneurship".toUpperCase()),
                            textColor: html.window.location.toString().contains("?Entrepreneurship") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Entrepreneurship") ? getCategoryColor("Entrepreneurship") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Entrepreneurship") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Entrepreneurship")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Entrepreneurship", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Entrepreneurship", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("Finance".toUpperCase()),
                            textColor: html.window.location.toString().contains("?Finance") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Finance") ? getCategoryColor("Finance") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Finance") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Finance")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Finance", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Finance", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("Hospitality + Tourism".toUpperCase()),
                            textColor: html.window.location.toString().contains("?Hospitality-Tourism") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Hospitality-Tourism") ? getCategoryColor("Hospitality + Tourism") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Hospitality-Tourism") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Hospitality-Tourism")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Hospitality-Tourism", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Hospitality-Tourism", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("Marketing".toUpperCase()),
                            textColor: html.window.location.toString().contains("?Marketing") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Marketing") ? getCategoryColor("Marketing") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Marketing") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Marketing")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Marketing", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Marketing", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(4)),
                          new RaisedButton(
                            child: new Text("Personal Financial Literacy".toUpperCase()),
                            textColor: html.window.location.toString().contains("?Personal-Financial-Literacy") ? Colors.white : mainColor,
                            color: html.window.location.toString().contains("?Personal-Financial-Literacy") ? getCategoryColor("Personal Financial Literacy") : currBackgroundColor,
                            elevation: html.window.location.toString().contains("?Personal-Financial-Literacy") ? null : 0,
                            onPressed: () {
                              if (html.window.location.toString().contains("?Personal-Financial-Literacy")) {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1].replaceAll("?Personal-Financial-Literacy", ""), transition: TransitionType.fadeIn);
                              }
                              else {
                                router.navigateTo(context, html.window.location.toString().split("/#")[1] + "?Personal-Financial-Literacy", transition: TransitionType.fadeIn);
                              }
                            },
                          ),
                        ],
                      )
                  ),
                  new Visibility(
                    visible: eventsList.isEmpty,
                    child: new Container(
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      padding: EdgeInsets.all(16),
                      child: new Center(
                          child: new Text("No events found matching that filter.", style: TextStyle(color: currTextColor, fontSize: 16))
                      ),
                    ),
                  ),
                  Container(
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Column(
                        children: eventsList
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    }
    else {
      return LoginPage();
    }
  }
}

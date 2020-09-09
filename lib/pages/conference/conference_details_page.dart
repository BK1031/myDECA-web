import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/navbars/mobile_sidebar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/pages/conference/conference_media_page.dart';
import 'package:mydeca_web/pages/conference/conference_overview_page.dart';
import 'package:mydeca_web/pages/conference/conference_schedule_page.dart';
import 'package:mydeca_web/pages/conference/conference_winner_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

import 'package:progress_indicators/progress_indicators.dart';

class ConferenceDetailsPage extends StatefulWidget {
  @override
  _ConferenceDetailsPageState createState() => _ConferenceDetailsPageState();
}

class _ConferenceDetailsPageState extends State<ConferenceDetailsPage> {

  PageController _controller = PageController(initialPage: 0);
  int currPage = 0;
  final Storage _localStorage = html.window.localStorage;
  User currUser = User.plain();

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
                  new Stack(
                    fit: StackFit.passthrough,
                    alignment: Alignment.center,
                    children: <Widget>[
                      new ClipRRect(
                        child: new CachedNetworkImage(
                          placeholder: (context, url) => new Container(
                            child: new GlowingProgressIndicator(
                              child: new Image.asset('images/deca-diamond.png', height: 75.0,),
                            ),
                          ),
                          imageUrl: conference.imageUrl,
                          height: 400,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      new Container(
                        height: 350,
                        width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                        child: new Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new FlatButton(
                                    color: Colors.black.withOpacity(0.7),
                                    child: new Text("Back to Conferences", style: TextStyle(color: Colors.white, fontSize: 15),),
                                    onPressed: () {
                                      router.navigateTo(context, '/conferences', transition: TransitionType.fadeIn);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.all(16),
                                color: Colors.black.withOpacity(0.7),
                                width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                                child: new Text(
                                  "${conference.fullName.toUpperCase()}",
                                  style: TextStyle(fontFamily: "Montserrat", fontSize: 40, color: Colors.white),
                                )
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  new Padding(padding: EdgeInsets.all(8.0)),
                  Container(
                      padding: EdgeInsets.only(top: 8),
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: new Text(
                        "${conference.desc}",
                        style: TextStyle(fontSize: 17, color: currTextColor),
                      )
                  ),
                  Container(
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 8,
                        runSpacing: 4,
                        alignment: WrapAlignment.spaceEvenly,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                new Icon(Icons.event, size: 80, color: mainColor,),
                                new Text(
                                  "${conference.date}",
                                  style: TextStyle(fontFamily: "Montserrat",fontSize: 25, color: currTextColor),
                                ),
                              ],
                            ),
                          ),
                          new InkWell(
                            onTap: () {
                              html.window.open(conference.mapUrl, "Map");
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  new Icon(Icons.location_on, size: 80, color: mainColor,),
                                  new Text(
                                    "${conference.location.toUpperCase()}",
                                    style: TextStyle(fontFamily: "Montserrat",fontSize: 25, color: currTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  new Padding(padding: EdgeInsets.only(bottom: 8.0)),
                  Container(
                      padding: EdgeInsets.only(top: 8),
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: new FlatButton(
                              child: new Text("OVERVIEW", style: TextStyle(fontFamily: "Montserrat", color: currPage == 0 ? Colors.white : currTextColor)),
                              color: currPage == 0 ? mainColor : null,
                              onPressed: () {
                                setState(() {
                                  currPage = 0;
                                  _controller.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: new FlatButton(
                              child: new Text("SCHEDULE", style: TextStyle(fontFamily: "Montserrat", color: currPage == 1 ? Colors.white : currTextColor)),
                              color: currPage == 1 ? mainColor : null,
                              onPressed: () {
                                setState(() {
                                  currPage = 1;
                                  _controller.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: new FlatButton(
                              child: new Text("WINNERS", style: TextStyle(fontFamily: "Montserrat", color: currPage == 2 ? Colors.white : currTextColor)),
                              color: currPage == 2 ? mainColor : null,
                              onPressed: () {
                                setState(() {
                                  currPage = 2;
                                  _controller.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: new FlatButton(
                              child: new Text("MEDIA", style: TextStyle(fontFamily: "Montserrat", color: currPage == 3 ? Colors.white : currTextColor)),
                              color: currPage == 3 ? mainColor : null,
                              onPressed: () {
                                setState(() {
                                  currPage = 3;
                                  _controller.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                });
                              },
                            ),
                          ),
                        ],
                      )
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 16),
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      height: 500,
                      child: new PageView(
                        controller: _controller,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          ConferenceOverviewPage(),
                          ConferenceSchedulePage(),
                          ConferenceWinnersPage(),
                          ConferenceMediaPage()
                        ],
                      )
                  ),
                  new Container(height: 300)
                ],
              ),
            ),
          ),
        );
      }
      else {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Details", style: TextStyle(color: Colors.white, fontFamily: "Montserrat"),),
          ),
          drawer: new Drawer(child: new MobileSidebar(),),
          body: Container(
            child: new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new CachedNetworkImage(
                    imageUrl: conference.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  new Padding(padding: EdgeInsets.only(bottom: 8.0)),
                  new Container(
                    width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new FlatButton(
                          child: new Text("Back to Conferences", style: TextStyle(color: mainColor, fontSize: 15),),
                          onPressed: () {
                            router.navigateTo(context, '/conferences', transition: TransitionType.fadeIn);
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 8),
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: new Text(
                        "${conference.fullName.toUpperCase()}",
                        style: TextStyle(fontFamily: "Montserrat", fontSize: 40, color: currTextColor),
                      )
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 8),
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: new Text(
                        "${conference.desc}",
                        style: TextStyle(fontSize: 17, color: currTextColor),
                      )
                  ),
                  Container(
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 8,
                        runSpacing: 4,
                        alignment: WrapAlignment.spaceEvenly,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                new Icon(Icons.event, size: 80, color: mainColor,),
                                new Text(
                                  "${conference.date}",
                                  style: TextStyle(fontFamily: "Montserrat",fontSize: 25, color: currTextColor),
                                ),
                              ],
                            ),
                          ),
                          new InkWell(
                            onTap: () {
                              html.window.open(conference.mapUrl, "Map");
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  new Icon(Icons.location_on, size: 80, color: mainColor,),
                                  new Text(
                                    "${conference.location.toUpperCase()}",
                                    style: TextStyle(fontFamily: "Montserrat",fontSize: 25, color: currTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  new Padding(padding: EdgeInsets.only(bottom: 8.0)),
                  Container(
                      padding: EdgeInsets.only(top: 8),
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: new FlatButton(
                              child: new Text("OVERVIEW", style: TextStyle(fontFamily: "Montserrat", color: currPage == 0 ? Colors.white : currTextColor)),
                              color: currPage == 0 ? mainColor : null,
                              onPressed: () {
                                setState(() {
                                  currPage = 0;
                                  _controller.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: new FlatButton(
                              child: new Text("SCHEDULE", style: TextStyle(fontFamily: "Montserrat", color: currPage == 1 ? Colors.white : currTextColor)),
                              color: currPage == 1 ? mainColor : null,
                              onPressed: () {
                                setState(() {
                                  currPage = 1;
                                  _controller.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: new FlatButton(
                              child: new Text("WINNERS", style: TextStyle(fontFamily: "Montserrat", color: currPage == 2 ? Colors.white : currTextColor)),
                              color: currPage == 2 ? mainColor : null,
                              onPressed: () {
                                setState(() {
                                  currPage = 2;
                                  _controller.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: new FlatButton(
                              child: new Text("MEDIA", style: TextStyle(fontFamily: "Montserrat", color: currPage == 3 ? Colors.white : currTextColor)),
                              color: currPage == 3 ? mainColor : null,
                              onPressed: () {
                                setState(() {
                                  currPage = 3;
                                  _controller.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                });
                              },
                            ),
                          ),
                        ],
                      )
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 16),
                      width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                      height: 500,
                      child: new PageView(
                        controller: _controller,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          ConferenceOverviewPage(),
                          ConferenceSchedulePage(),
                          ConferenceWinnersPage(),
                          ConferenceMediaPage()
                        ],
                      )
                  ),
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

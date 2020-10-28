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

class MockConferenceDetailsPage extends StatefulWidget {
  String id;
  MockConferenceDetailsPage(this.id);
  @override
  _MockConferenceDetailsPageState createState() => _MockConferenceDetailsPageState(this.id);
}

class _MockConferenceDetailsPageState extends State<MockConferenceDetailsPage> {

  PageController _controller = PageController(initialPage: 0);
  int currPage = 0;
  final Storage _localStorage = html.window.localStorage;
  User currUser = User.plain();

  Conference conference = new Conference.plain();

  bool registered = false;
  String selectedRoleplay = "0";
  String selectedWritten = "0";

  _MockConferenceDetailsPageState(String id) {
    conference.conferenceID = id;
  }

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
        fb.database().ref("conferences").child(conference.conferenceID).once("value").then((value) {
          setState(() {
            conference = new Conference.fromSnapshot(value.snapshot);
          });
        });
        if (conference.conferenceID.contains("Mock")) {
          fb.database().ref("conferences").child(conference.conferenceID).child("users").child(currUser.userID).once("value").then((value) {
            if (value.snapshot.val()["roleplay"] != null) {
              setState(() {
                registered = true;
                selectedRoleplay = value.snapshot.val()["roleplay"];
                selectedWritten = value.snapshot.val()["written"];
              });
            }
          });
        }
      });
    }
  }

  void alert(String alert) {
    showDialog(
        context: context,
        child: new AlertDialog(
          backgroundColor: currCardColor,
          title: new Text("Alert", style: TextStyle(color: currTextColor),),
          content: new Text(alert, style: TextStyle(color: currTextColor)),
          actions: [
            new FlatButton(
                child: new Text("GOT IT"),
                textColor: mainColor,
                onPressed: () {
                  router.pop(context);
                }
            )
          ],
        )
    );
  }

  void confirmRegistration() {
    showDialog(
        context: context,
        child: new AlertDialog(
          backgroundColor: currCardColor,
          title: new Text("Confirm Registration", style: TextStyle(color: currTextColor),),
          content: new Text("Are you sure you want to register with the following events?\n\nWritten: $selectedWritten\nRoleplay: $selectedRoleplay\n\nYou will not be able to change events after you register.", style: TextStyle(color: currTextColor)),
          actions: [
            new FlatButton(
                child: new Text("CANCEL"),
                textColor: mainColor,
                onPressed: () {
                  router.pop(context);
                }
            ),
            new FlatButton(
                child: new Text("REGISTER"),
                textColor: mainColor,
                onPressed: () {
                  fb.database().ref("conferences").child(conference.conferenceID).child("users").child(currUser.userID).update({
                    "roleplay": selectedRoleplay,
                    "written": selectedWritten
                  });
                  setState(() {
                    registered = true;
                  });
                  router.pop(context);
                }
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    width: MediaQuery.of(context).size.width,
                    height: 400,
                    color: Colors.black.withOpacity(0.5),
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
                                child: new Text("Back to Conferences", style: TextStyle(color: mainColor, fontSize: 15),),
                                onPressed: () {
                                  router.navigateTo(context, '/conferences', transition: TransitionType.fadeIn);
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      new Expanded(
                        child: Container(
                          child: new Text(
                            "${conference.desc}",
                            style: TextStyle(fontSize: 17, color: currTextColor),
                          ),
                        ),
                      ),
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
                    ],
                  )
              ),
              new Padding(padding: EdgeInsets.only(bottom: 8.0)),
              new Visibility(
                visible: !registered,
                child: new Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Card(
                    child: new Container(
                      padding: EdgeInsets.all(16),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Text("Register for this conference", style: TextStyle(fontFamily: "Montserrat", fontSize: 25),),
                          new Padding(padding: EdgeInsets.all(4),),
                          new Text("Please select your events below. (Enter the letter code for your event)"),
                          new Padding(padding: EdgeInsets.all(4),),
                          Row(
                            children: [
                              new Text("Written Event:", style: TextStyle(fontSize: 17),),
                              new Padding(padding: EdgeInsets.all(4),),
                              new DropdownButton(
                                value: selectedWritten,
                                hint: new Text("Select Written Event"),
                                onChanged: (value) {
                                  setState(() {
                                    selectedWritten = value;
                                  });
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: "0",
                                    child: new Text("Select Written Event"),
                                  ),
                                  DropdownMenuItem(
                                    value: "1",
                                    child: new Text("Business Adminstration Operations Written Event"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "BOR",
                                    child: new Text("BOR"),
                                  ),
                                  DropdownMenuItem(
                                    value: "BMOR",
                                    child: new Text("BMOR"),
                                  ),
                                  DropdownMenuItem(
                                    value: "FOR",
                                    child: new Text("FOR"),
                                  ),
                                  DropdownMenuItem(
                                    value: "2",
                                    child: new Text("Hospitality/Sports Operations Written Event"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "HTOR",
                                    child: new Text("HTOR"),
                                  ),
                                  DropdownMenuItem(
                                    value: "SEOR",
                                    child: new Text("SEOR"),
                                  ),
                                  DropdownMenuItem(
                                    value: "3",
                                    child: new Text("Entrepreneurship Written Event"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "EIB",
                                    child: new Text("EIB"),
                                  ),
                                  DropdownMenuItem(
                                    value: "IBP",
                                    child: new Text("IBP"),
                                  ),
                                  DropdownMenuItem(
                                    value: "EIP",
                                    child: new Text("EIP"),
                                  ),
                                  DropdownMenuItem(
                                    value: "ESB",
                                    child: new Text("ESB"),
                                  ),
                                  DropdownMenuItem(
                                    value: "EBG",
                                    child: new Text("EBG"),
                                  ),
                                  DropdownMenuItem(
                                    value: "4",
                                    child: new Text("Project Management Written Event"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "PMBS",
                                    child: new Text("PMBS"),
                                  ),
                                  DropdownMenuItem(
                                    value: "PMCD",
                                    child: new Text("PMCD"),
                                  ),
                                  DropdownMenuItem(
                                    value: "PMCA",
                                    child: new Text("PMCA"),
                                  ),
                                  DropdownMenuItem(
                                    value: "PMCG",
                                    child: new Text("PMCG"),
                                  ),
                                  DropdownMenuItem(
                                    value: "PMFL",
                                    child: new Text("PMFL"),
                                  ),
                                  DropdownMenuItem(
                                    value: "PMSP",
                                    child: new Text("PMSP"),
                                  ),
                                  DropdownMenuItem(
                                    value: "5",
                                    child: new Text("Professional Selling Written Event"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "HTPS",
                                    child: new Text("HTPS"),
                                  ),
                                  DropdownMenuItem(
                                    value: "PSE",
                                    child: new Text("PSE"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          new Padding(padding: EdgeInsets.all(4),),
                          Row(
                            children: [
                              new Text("Roleplay Event:", style: TextStyle(fontSize: 17),),
                              new Padding(padding: EdgeInsets.all(4),),
                              new DropdownButton(
                                value: selectedRoleplay,
                                hint: new Text("Select Roleplay Event"),
                                onChanged: (value) {
                                  setState(() {
                                    selectedRoleplay = value;
                                  });
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: "0",
                                    child: new Text("Select Roleplay Event"),
                                  ),
                                  DropdownMenuItem(
                                    value: "PFN",
                                    child: new Text("PFN"),
                                  ),
                                  DropdownMenuItem(
                                    value: "PBM",
                                    child: new Text("PBM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "PHT",
                                    child: new Text("PHT"),
                                  ),
                                  DropdownMenuItem(
                                    value: "PMK",
                                    child: new Text("PMK"),
                                  ),
                                  DropdownMenuItem(
                                    value: "1",
                                    child: new Text("Retail Marketing Roleplay"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "AAM",
                                    child: new Text("AAM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "RMS",
                                    child: new Text("RMS"),
                                  ),
                                  DropdownMenuItem(
                                    value: "2",
                                    child: new Text("Business Law and Ethics Roleplay"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "BLTDM",
                                    child: new Text("BLTDM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "3",
                                    child: new Text("Entrepreneurship Roleplay"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "ETDM",
                                    child: new Text("ETDM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "ENT",
                                    child: new Text("ENT"),
                                  ),
                                  DropdownMenuItem(
                                    value: "4",
                                    child: new Text("Sports Entertainment Roleplay"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "SEM",
                                    child: new Text("SEM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "STDM",
                                    child: new Text("STDM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "5",
                                    child: new Text("Human Resources Management Roleplay"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "HRM",
                                    child: new Text("HRM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "6",
                                    child: new Text("Hospitality Services Roleplay"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "QSRM",
                                    child: new Text("QSRM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "RFSM",
                                    child: new Text("RFSM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "TTDM",
                                    child: new Text("TTDM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "HTDM",
                                    child: new Text("HTDM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "7",
                                    child: new Text("Financial Services Roleplay"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "ACT",
                                    child: new Text("ACT"),
                                  ),
                                  DropdownMenuItem(
                                    value: "BFS",
                                    child: new Text("BFS"),
                                  ),
                                  DropdownMenuItem(
                                    value: "FTDM",
                                    child: new Text("FTDM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "8",
                                    child: new Text("Marketing Services Roleplay"),
                                    onTap: () {},
                                  ),
                                  DropdownMenuItem(
                                    value: "BSM",
                                    child: new Text("BSM"),
                                  ),
                                  DropdownMenuItem(
                                    value: "FMS",
                                    child: new Text("FMS"),
                                  ),
                                  DropdownMenuItem(
                                    value: "MCS",
                                    child: new Text("MCS"),
                                  ),
                                  DropdownMenuItem(
                                    value: "MTDM",
                                    child: new Text("MTDM"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          new Padding(padding: EdgeInsets.all(8),),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              new FlatButton(
                                color: mainColor,
                                textColor: Colors.white,
                                child: new Text("REGISTER"),
                                onPressed: () {
                                  if (selectedWritten == "" || int.tryParse(selectedWritten) != null) {
                                    alert("Please select a written specific event, rather than choosing the mock conference category.");
                                  }
                                  else if (selectedRoleplay == "" || int.tryParse(selectedRoleplay) != null) {
                                    alert("Please select a roleplay specific event, rather than choosing the mock conference category.");
                                  }
                                  else {
                                    confirmRegistration();
                                  }
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              new Visibility(
                visible: registered && currUser.roles.contains("Developer"),
                child: new Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Card(
                    child: new Container(
                      padding: EdgeInsets.all(16),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Row(
                            children: [
                              new Icon(Icons.dashboard),
                              new Padding(padding: EdgeInsets.all(4)),
                              new Text("DASHBOARD", style: TextStyle(fontFamily: "Montserrat", fontSize: 20, color: currTextColor),)
                            ],
                          ),
                          new Padding(padding: EdgeInsets.only(top: 8, bottom: 16), child: new Divider(color: currDividerColor, height: 8)),
                          new ListTile(
                            title: new Text("Business Admin Core Exam"),
                            leading: new Text("11:00 AM", style: TextStyle(color: mainColor, fontFamily: "Gotham"),),
                            trailing: new Text("NOT OPEN", style: TextStyle(color: Colors.grey),),
                          ),
                          new ListTile(
                            title: new Text("Roleplay Presentation – " + selectedRoleplay),
                            leading: new Text("1:00 PM", style: TextStyle(color: mainColor, fontFamily: "Gotham"),),
                            trailing: new Icon(Icons.arrow_forward_ios, color: mainColor,),
                          ),
                          new ListTile(
                            title: new Text("Written Presentation – " + selectedWritten),
                            leading: new Text("2:45 PM", style: TextStyle(color: mainColor, fontFamily: "Gotham"),),
                            trailing: new Icon(Icons.arrow_forward_ios, color: mainColor,),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              new Visibility(
                visible: registered,
                child: new Container(
                  width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                  child: new Card(
                    child: new Container(
                      padding: EdgeInsets.all(16),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new Text("You're all set!", style: TextStyle(fontSize: 30, fontFamily: "Montserrat"),),
                          new Padding(padding: EdgeInsets.all(4),),
                          new Icon(Icons.check_circle_outline, size: 60, color: mainColor,),
                          new Padding(padding: EdgeInsets.all(4),),
                          Container(width: 350, child: Center(child: new Text("You are registered for this conference! Don't forget to turn in your written here by Nov 10. More information will be posted here later.", style: TextStyle(fontSize: 17), textAlign: TextAlign.center,)))
                        ],
                      ),
                    ),
                  ),
                ),
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
                      ConferenceOverviewPage(conference.conferenceID),
                      ConferenceSchedulePage(conference.conferenceID),
                      ConferenceWinnersPage(conference.conferenceID),
                      ConferenceMediaPage(conference.conferenceID)
                    ],
                  )
              ),
              new Container(height: 100)
            ],
          ),
        ),
      ),
    );
  }
}

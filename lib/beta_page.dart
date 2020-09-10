import 'dart:html';
import 'dart:html' as html;
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:url_launcher/url_launcher.dart';
import 'models/chapter.dart';
import 'utils/config.dart';
import 'utils/theme.dart';
import 'utils/theme.dart';

class BetaPage extends StatefulWidget {
  @override
  _BetaPageState createState() => _BetaPageState();
}

class _BetaPageState extends State<BetaPage> {

  final Storage _localStorage = html.window.localStorage;
  List<Widget> chaptersList = new List();

  String newSchool = "";
  String newContact = "";
  String contactEmail = "";
  String contactRole = "";

  void getStarted() {
    if (fb.auth().currentUser != null) {
      print("User logged! Redirect to home");
      _localStorage["userID"] = fb.auth().currentUser.uid;
      router.navigateTo(context, "/home", transition: TransitionType.fadeIn);
    }
    else {
      print("User not logged! Redirect to register");
      _localStorage.remove("userID");
      router.navigateTo(context, '/register', transition: TransitionType.materialFullScreenDialog);
    }
  }

  @override
  void initState() {
    super.initState();
    fb.database().ref("chapters").onChildAdded.listen((event) {
      if (event.snapshot.key != "CC-123456") {
        setState(() {
          chaptersList.add(new Card(
            child: new Container(
              padding: EdgeInsets.all(8),
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new Padding(padding: EdgeInsets.all(4.0),),
                  new Image.asset("images/deca-diamond.png", height: 50,),
                  new Padding(padding: EdgeInsets.all(8.0),),
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Text(event.snapshot.val()["name"] + " DECA", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      new Text(event.snapshot.val()["city"], style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300)),
                      new Text("Advisor: " + (event.snapshot.val()["advisor"] == null ? "Not Set" : event.snapshot.val()["advisor"]), style: TextStyle(fontWeight: FontWeight.w300))
                    ],
                  )
                ],
              ),
            ),
          ));
        });
      }
    });
  }

  void addChapter() {
    showDialog(context: context, child: new AlertDialog(
      backgroundColor: currCardColor,
      title: new Text("Chapter Beta Interest"),
      content: Container(
        width: 400,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            new Text("Thank you for expressing interest in joining our beta! Please fill out the form below with either an officer or advisor's info, and we will get in contact soon."),
            new TextField(
              decoration: InputDecoration(
                labelText: "School Name",
                  hintText: "E.g. Valley Christian High School"
              ),
              onChanged: (input) {
                newSchool = input;
              },
            ),
            new TextField(
              decoration: InputDecoration(
                labelText: "Contact Name",
                  hintText: "E.g. Kashyap Chaturvedula"
              ),
              onChanged: (input) {
                newContact = input;
              },
            ),
            new TextField(
              decoration: InputDecoration(
                labelText: "Contact Email",
                hintText: "E.g. kashyap@gmail.com"
              ),
              onChanged: (input) {
                contactEmail = input;
              },
            ),
            new TextField(
              decoration: InputDecoration(
                labelText: "Contact Role",
                  hintText: "E.g. Officer"
              ),
              onChanged: (input) {
                contactRole = input;
              },
            ),
          ],
        ),
      ),
      actions: [
        new FlatButton(
          child: new Text("CANCEL"),
          onPressed: () => router.pop(context),
        ),
        new FlatButton(
          child: new Text("SUBMIT"),
          onPressed: () {
            fb.database().ref("beta-requests").push().set({
              "school": newSchool,
              "name": newContact,
              "email": contactEmail,
              "role": contactRole
            });
            router.pop(context);
          },
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: mainColor.withOpacity(0.2),
      body: Container(
        child: new SingleChildScrollView(
          child: new Column(
            children: [
              new Container(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Column(
                          children: [
                            new Image.asset(
                              "images/beta-header.png",
                              width: double.infinity,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                            new Container(
                              height: 550,
                            ),
                            new Container(
                              color: mainColor,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 64, right: 64),
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        new FlatButton(
                                          child: new Text("Copyright © 2020 Equinox Initiative"),
                                          textColor: Colors.white,
                                          onPressed: () => launch("https://equinox.bk1031.dev"),
                                        ),
                                        new Row(
                                          children: [
                                            new FlatButton(
                                              child: new Text("v${appVersion.toString()}"),
                                              textColor: Colors.white,
                                              onPressed: () {},
                                            ),
                                            new FlatButton(
                                              child: new Text("Docs"),
                                              textColor: Colors.white,
                                              onPressed: () => launch("https://docs.mydeca.org"),
                                            ),
                                            new FlatButton(
                                              child: new Text("Terms"),
                                              textColor: Colors.white,
                                              onPressed: () => launch("https://docs.mydeca.org/tos"),
                                            ),
                                            new FlatButton(
                                              child: new Text("Privacy"),
                                              textColor: Colors.white,
                                              onPressed: () => launch("https://docs.mydeca.org/privacy"),
                                            ),
                                            new FlatButton(
                                              child: new Text("Status"),
                                              textColor: Colors.white,
                                              onPressed: () => launch("https://status.bk1031.dev"),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        Container(
                          width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          new RaisedButton(
                                            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 16),
                                            elevation: 0.0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                            child: new Text("ADD YOUR CHAPTER", style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 25),),
                                            color: mainColor,
                                            textColor: Colors.white,
                                            onPressed: () {
                                              addChapter();
                                            },
                                          ),
                                        ],
                                      ),
                                      new Padding(padding: EdgeInsets.all(100)),
                                    ],
                                  ),
                                ],
                              ),
                              new Container(
                                child: new Text(
                                  "These chapters already have",
                                  style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 50, color: Colors.white),
                                )
                              ),
                              new Container(
                                child: new Column(
                                  children: chaptersList,
                                ),
                              ),
                              new Padding(padding: EdgeInsets.all(50)),
                              new Container(
                                  child: Center(
                                    child: new Text(
                                      "Don't see your chapter?",
                                      style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 40, color: Colors.white),
                                    ),
                                  )
                              ),
                              new Padding(padding: EdgeInsets.all(16)),
                              new Container(
                                child: Center(
                                  child: new RaisedButton(
                                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 16),
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                    child: new Text("JOIN NOW", style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 25),),
                                    color: mainColor,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      addChapter();
                                    },
                                  ),
                                ),
                              ),
                              new Container(
                                height: 200,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      height: 80.0,
                      padding: EdgeInsets.only(left: 64, right: 64),
                      color: Colors.black.withOpacity(0.5),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                              child: Row(
                                children: [
                                  new Image.asset(
                                    "images/deca-logo.png",
                                    color: Colors.white,
                                    fit: BoxFit.fitHeight,
                                    height: 60,
                                  ),
                                ],
                              )
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new OutlineButton(
                                  highlightElevation: 6.0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
                                  borderSide: BorderSide(color: Colors.grey),
                                  child: new Text("GET STARTED", style: TextStyle(fontFamily: "Montserrat", letterSpacing: 1)),
                                  textColor: Colors.white,
                                  color: mainColor,
                                  onPressed: getStarted
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

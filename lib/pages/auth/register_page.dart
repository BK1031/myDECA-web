import 'dart:convert';
import 'dart:ui';
import 'package:fluro/fluro.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/chapter.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/utils/config.dart';
import 'dart:html' as html;
import 'package:mydeca_web/utils/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final html.Storage _localStorage = html.window.localStorage;
  List<Chapter> chapterList = new List();
  Widget registerWidget = new Container();
  double cardHeight = 315;

  bool chapterExists = false;
  bool advisorExists = false;
  bool advisorCodeExists = false;

  Chapter selectedChapter = new Chapter();

  User currUser = new User.plain();

  String password = "";
  String confirmPassword = "";

  _RegisterPageState() {
    print(html.window.location.toString());
  }

  @override
  void initState() {
    super.initState();
    fb.database().ref("chapters").onChildAdded.listen((event) {
      Chapter chapter = new Chapter();
      chapter.chapterID = event.snapshot.key;
      chapter.name = event.snapshot.val()["name"];
      chapter.advisorCode = event.snapshot.val()["advisorCode"];
      chapter.advisorName = event.snapshot.val()["advisor"];
      chapter.city = event.snapshot.val()["city"];
      print(chapter);
      chapterList.add(chapter);
    });
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
  
  Future<void> testFileUpload() async {
    File file = new File("images/default-male.png");
    fb.storage().ref("test/test.png").put(file);
    print("Uploaded test!");
  }

  void checkChapterCode(String code) {
    setState(() {
      cardHeight = 315;
      chapterExists = false;
      advisorExists = false;
      advisorCodeExists = false;
      registerWidget = new Container();
    });
    for (int i = 0; i < chapterList.length; i++) {
      if (code == chapterList[i].chapterID) {
        setState(() {
          print("Chapter Exists!");
          selectedChapter = chapterList[i];
          cardHeight = 500;
          chapterExists = true;
          if (chapterList[i].advisorName != null && chapterList[i].advisorName != "") {
            // Advisor already exists for selected chapter
            print("Advisor Exists!");
            advisorExists = true;
            cardHeight = MediaQuery.of(context).size.height - 64;
            registerWidget = new Container(
              width: double.infinity,
              child: new RaisedButton(
                child: new Text("CREATE ACCOUNT"),
                textColor: Colors.white,
                color: mainColor,
                onPressed: register
              ),
            );
          }
        });
      }
    }
  }

  void checkAdvisorCode(String code) {
    setState(() {
      cardHeight = 500;
      advisorCodeExists = false;
      registerWidget = new Container();
    });
    if (code == selectedChapter.advisorCode) {
      setState(() {
        cardHeight = 530;
        advisorCodeExists = true;
        registerWidget = new Container(
          width: double.infinity,
          child: new RaisedButton(
            child: new Text("NEXT"),
            textColor: Colors.white,
            color: mainColor,
            onPressed: () {
              router.navigateTo(context, '/register/advisor?${selectedChapter.chapterID}?${selectedChapter.advisorCode}', transition: TransitionType.fadeIn);
            },
          ),
        );
      });
    }
  }

  Future<void> register() async {
    fb.auth().setPersistence("local");
    if (currUser.firstName == "" || currUser.lastName == "") {
      alert("Name cannot be empty!");
    }
    else if (currUser.email == "") {
      alert("Email cannot be empty!");
    }
    else if (password != confirmPassword) {
      alert("Passwords must match!");
    }
    else {
      // All good to create account!
      try {
        setState(() {
          registerWidget = new Container(
            child: new HeartbeatProgressIndicator(
              child: new Image.asset("images/deca-diamong.png", height: 20,),
            ),
          );
        });
        await fb.auth().createUserWithEmailAndPassword(currUser.email, password).then((value) async {
          currUser.userID = value.user.uid;
          currUser.roles.add("Member");
          currUser.chapter = selectedChapter;
          print(currUser.userID);
          print(currUser.chapter.chapterID);
          _localStorage["userID"] = fb.auth().currentUser.uid;
          await fb.database().ref("users").child(currUser.userID).set({
            "firstName": currUser.firstName.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
            "lastName": currUser.lastName.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
            "email": currUser.email,
            "emailVerified": currUser.emailVerified,
            "gender": currUser.gender,
            "roles": currUser.roles,
            "grade": currUser.grade,
            "yearsMember": currUser.yearsMember,
            "shirtSize": currUser.shirtSize,
            "chapterID": currUser.chapter.chapterID,
          });
          if (currUser.gender == "Female") {
            print("Female pic used");
            fb.database().ref("users").child(currUser.userID).child("profileUrl").set("https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/default-female.png?alt=media&token=ad2ae077-6927-4209-893a-e394b368538b");
          }
          else {
            print("Male pic used");
            fb.database().ref("users").child(currUser.userID).child("profileUrl").set("https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/default-male.png?alt=media&token=5b6b4b1c-649c-46b9-be30-b15d3603e358");
          }
          print("Uploaded profile picture!");
          router.navigateTo(context, "/home?new", transition: TransitionType.fadeIn, clearStack: true);
        });
      } catch (e) {
        print(e);
        alert("An error occured while creating your account: ${e.message}");
      }
    }
    setState(() {
      registerWidget = new Container(
        width: double.infinity,
        child: new RaisedButton(
            child: new Text("CREATE ACCOUNT"),
            textColor: Colors.white,
            color: mainColor,
            onPressed: register
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Title(
      title: "myDECA",
      color: mainColor,
      child: new Scaffold(
        backgroundColor: currBackgroundColor,
        body: new Center(
          child: new Card(
            color: currCardColor,
            child: new AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(32.0),
              width: (MediaQuery.of(context).size.width > 500) ? 500.0 : MediaQuery.of(context).size.width - 25,
              height: cardHeight,
              child: new SingleChildScrollView(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text("REGISTER", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, fontFamily: "Gotham"), textAlign: TextAlign.center),
                    new Padding(padding: EdgeInsets.all(8.0),),
                    new Visibility(
                      visible: chapterExists,
                      child: new Card(
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
                                  new Text(selectedChapter.name + " DECA", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                  new Text(selectedChapter.city, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300)),
                                  new Text("Advisor: " + (selectedChapter.advisorName == null ? "Not Set" : selectedChapter.advisorName), style: TextStyle(fontWeight: FontWeight.w300))
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    new Row(
                      children: [
                        new Text(chapterExists ? "Valid Chapter Code!" : "Enter your chapter code below", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: chapterExists ? Colors.green : currTextColor)),
                        new IconButton(icon: Icon(Icons.help), tooltip: "Use the chapter code you recieved from your advisor here.\nIf you do not have a code, contact your advisor.",)
                      ],
                    ),
                    new TextField(
                      decoration: InputDecoration(
                        labelText: "Chapter Code",
                        hintText: "CC-######",
                      ),
                      autocorrect: false,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: checkChapterCode,
                    ),
                    new Visibility(visible: chapterExists, child: new Padding(padding: EdgeInsets.all(8.0))),
                    new Visibility(
                      visible: chapterExists && !advisorExists,
                      child: Row(
                        children: [
                          new Text(advisorCodeExists ? "Valid Advisor Code!" : "Enter your advisor code below", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: advisorCodeExists ? Colors.green : currTextColor),),
                          new IconButton(icon: Icon(Icons.help), tooltip: "An advisor has not been set for this chapter yet. Please ask your advisor to create their\naccount first. If you are an advisor and have not recieved a code, please reach out to us.",)
                        ],
                      )
                    ),
                    new Visibility(
                      visible: chapterExists && !advisorExists,
                      child: new TextField(
                        decoration: InputDecoration(
                          labelText: "Advisor Code",
                          hintText: "AC-######",
                        ),
                        autocorrect: false,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: checkAdvisorCode,
                      ),
                    ),
                    new Visibility(
                      visible: chapterExists && advisorExists,
                      child: Column(
                        children: [
                          new TextField(
                            decoration: InputDecoration(
                              icon: new Icon(Icons.person),
                              labelText: "First Name",
                              hintText: "Enter your first name",
                            ),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (value) {
                              currUser.firstName = value;
                            },
                          ),
                          new TextField(
                            decoration: InputDecoration(
                              icon: new Icon(Icons.person),
                              labelText: "Last Name",
                              hintText: "Enter your last name",
                            ),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (value) {
                              currUser.lastName = value;
                            },
                          ),
                          new TextField(
                            decoration: InputDecoration(
                              icon: new Icon(Icons.email),
                              labelText: "Email",
                              hintText: "Enter your email",
                            ),
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            onChanged: (value) {
                              currUser.email = value;
                            },
                          ),
                          new Row(
                            children: <Widget>[
                              new Expanded(
                                flex: 2,
                                child: new Text(
                                  "Grade",
                                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0),
                                ),
                              ),
                              new Expanded(
                                flex: 1,
                                child: new DropdownButton(
                                  value: currUser.grade,
                                  items: [
                                    DropdownMenuItem(child: new Text("9"), value: 9),
                                    DropdownMenuItem(child: new Text("10"), value: 10),
                                    DropdownMenuItem(child: new Text("11"), value: 11),
                                    DropdownMenuItem(child: new Text("12"), value: 12),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      currUser.grade = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          new Row(
                            children: <Widget>[
                              new Expanded(
                                flex: 2,
                                child: new Text(
                                  "Gender",
                                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0),
                                ),
                              ),
                              new Expanded(
                                flex: 1,
                                child: new DropdownButton(
                                  value: currUser.gender,
                                  items: [
                                    DropdownMenuItem(child: new Text("Male"), value: "Male"),
                                    DropdownMenuItem(child: new Text("Female"), value: "Female"),
                                    DropdownMenuItem(child: new Text("Other"), value: "Other"),
                                    DropdownMenuItem(child: new Text("Prefer not to say"), value: "Opt-Out"),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      currUser.gender = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          new Row(
                            children: <Widget>[
                              new Expanded(
                                flex: 2,
                                child: new Text(
                                  "Shirt Size",
                                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0),
                                ),
                              ),
                              new Expanded(
                                flex: 1,
                                child: new DropdownButton(
                                  value: currUser.shirtSize,
                                  items: [
                                    DropdownMenuItem(child: new Text("S"), value: "S"),
                                    DropdownMenuItem(child: new Text("M"), value: "M"),
                                    DropdownMenuItem(child: new Text("L"), value: "L"),
                                    DropdownMenuItem(child: new Text("XL"), value: "XL"),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      currUser.shirtSize = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          new Row(
                            children: <Widget>[
                              new Expanded(
                                flex: 2,
                                child: new Text(
                                  "Years in DECA",
                                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0),
                                ),
                              ),
                              new Expanded(
                                flex: 1,
                                child: new DropdownButton(
                                  value: currUser.yearsMember,
                                  items: [
                                    DropdownMenuItem(child: new Text("First Year"), value: 0),
                                    DropdownMenuItem(child: new Text("Second Year"), value: 1),
                                    DropdownMenuItem(child: new Text("Third Year"), value: 2),
                                    DropdownMenuItem(child: new Text("Fourth Year"), value: 3),
                                    DropdownMenuItem(child: new Text("Fifth Year"), value: 4),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      currUser.yearsMember = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          new TextField(
                            decoration: InputDecoration(
                              icon: new Icon(Icons.lock),
                              labelText: "Password",
                              hintText: "Enter a password",
                            ),
                            autocorrect: false,
                            obscureText: true,
                            onChanged: (value) {
                              password = value;
                            },
                          ),
                          new TextField(
                            decoration: InputDecoration(
                              icon: new Icon(Icons.lock),
                              labelText: "Confirm Password",
                              hintText: "Confirm your password",
                            ),
                            autocorrect: false,
                            obscureText: true,
                            onChanged: (value) {
                              confirmPassword = value;
                            },
                          ),
                          new Padding(padding: EdgeInsets.all(8.0)),
                          new RichText(
                            text: new TextSpan(
                              children: [
                                new TextSpan(
                                  text: "By creating a myDECA account, you agree to our ",
                                  style: new TextStyle(color: Colors.black),
                                ),
                                new TextSpan(
                                  text: 'Terms of Service',
                                  style: new TextStyle(color: mainColor),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      launch("https://docs.mydeca.org/tos");
                                    },
                                ),
                                new TextSpan(
                                  text: " and ",
                                  style: new TextStyle(color: Colors.black),
                                ),
                                new TextSpan(
                                  text: 'Privacy Policy',
                                  style: new TextStyle(color: mainColor),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      launch("https://docs.mydeca.org/privacy");
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(16.0)),
                    registerWidget,
                    new Visibility(
                      visible: !chapterExists,
                      child: new FlatButton(
                        child: new Text("Already have an account?", style: TextStyle(fontSize: 17),),
                        textColor: mainColor,
                        onPressed: () {
                          router.navigateTo(context, "/login", transition: TransitionType.fadeIn);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:html';
import 'dart:ui';
import 'package:fluro/fluro.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mydeca_web/models/chapter.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/utils/config.dart';
import 'dart:html' as html;
import 'package:mydeca_web/utils/theme.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterAdvisorPage extends StatefulWidget {
  @override
  _RegisterAdvisorPageState createState() => _RegisterAdvisorPageState();
}

class _RegisterAdvisorPageState extends State<RegisterAdvisorPage> {
  final Storage _localStorage = html.window.localStorage;
  List<Chapter> chapterList = new List();
  Widget registerWidget = new Container();
  double cardHeight = 300;

  bool chapterExists = false;
  bool advisorExists = false;
  bool advisorCodeExists = false;

  Chapter selectedChapter = new Chapter();

  User currUser = new User.plain();

  String password = "";
  String confirmPassword = "";

  _RegisterAdvisorPageState() {
    checkCodes();
    registerWidget = new Container(
      width: double.infinity,
      child: new RaisedButton(
          child: new Text("CREATE ACCOUNT"),
          textColor: Colors.white,
          color: mainColor,
          onPressed: register),
    );
  }

  void alert(String alert) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: currCardColor,
              title: new Text(
                "Alert",
                style: TextStyle(color: currTextColor),
              ),
              content: new Text(alert, style: TextStyle(color: currTextColor)),
              actions: [
                new FlatButton(
                    child: new Text("GOT IT"),
                    textColor: mainColor,
                    onPressed: () {
                      router.pop(context);
                    })
              ],
            ));
  }

  void checkCodes() {
    fb
        .database()
        .ref("chapters")
        .child(html.window.location.toString().split("?")[1])
        .once("value")
        .then((value) {
      if (value.snapshot != null &&
          value.snapshot.val()["advisorCode"] ==
              html.window.location.toString().split("?")[2]) {
        // Chapter and Advisor code exists
        print("Chapter and Advisor code exists");
      } else {
        print("Invalid Chapter and Advisor code exists");
        router.navigateTo(context, "/register",
            transition: TransitionType.fadeIn);
      }
    });
  }

  Future<void> register() async {
    fb.auth().setPersistence("local");
    if (currUser.firstName == "" || currUser.lastName == "") {
      alert("Name cannot be empty!");
    } else if (currUser.email == "") {
      alert("Email cannot be empty!");
    } else if (password != confirmPassword) {
      alert("Passwords must match!");
    } else {
      // All good to create account!
      try {
        setState(() {
          registerWidget = new Container(
            child: new HeartbeatProgressIndicator(
              child: new Image.asset(
                "images/deca-diamond.png",
                height: 20,
              ),
            ),
          );
        });
        await fb
            .auth()
            .createUserWithEmailAndPassword(currUser.email, password)
            .then((value) async {
          currUser.userID = value.user.uid;
          currUser.roles.add("Advisor");
          currUser.chapter = selectedChapter;
          print(currUser.userID);
          print(currUser.chapter.chapterID);
          _localStorage["userID"] = fb.auth().currentUser.uid;
          await fb.database().ref("users").child(currUser.userID).set({
            "firstName":
                currUser.firstName.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
            "lastName":
                currUser.lastName.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
            "email": currUser.email,
            "emailVerified": currUser.emailVerified,
            "phone": currUser.phone,
            "gender": currUser.gender,
            "roles": currUser.roles,
            "grade": currUser.grade,
            "yearsMember": currUser.yearsMember,
            "shirtSize": currUser.shirtSize,
            "chapterID": html.window.location.toString().split("?")[1],
          });
          await fb
              .database()
              .ref("chapters")
              .child(html.window.location.toString().split("?")[1])
              .child("advisor")
              .set("${currUser.firstName} ${currUser.lastName}");
          if (currUser.gender == "Female") {
            print("Female pic used");
            fb
                .database()
                .ref("users")
                .child(currUser.userID)
                .child("profileUrl")
                .set(
                    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/default-female.png?alt=media&token=ad2ae077-6927-4209-893a-e394b368538b");
          } else {
            print("Male pic used");
            fb
                .database()
                .ref("users")
                .child(currUser.userID)
                .child("profileUrl")
                .set(
                    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/default-male.png?alt=media&token=5b6b4b1c-649c-46b9-be30-b15d3603e358");
          }
          print("Uploaded profile picture!");
          router.navigateTo(context, "/home?new",
              transition: TransitionType.fadeIn, clearStack: true);
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
            onPressed: register),
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
              width: (MediaQuery.of(context).size.width > 500)
                  ? 500.0
                  : MediaQuery.of(context).size.width - 25,
              height: 600,
              child: new SingleChildScrollView(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text("REGISTER",
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gotham"),
                        textAlign: TextAlign.center),
                    new Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    new Text(
                        "Welcome advisor, we are excited to have you onboard!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17,
                            color:
                                chapterExists ? Colors.green : currTextColor)),
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
                    InternationalPhoneNumberInput(
                      onInputChanged: (value) {
                        currUser.phone = value.phoneNumber;
                        print(currUser.phone);
                      },
                      formatInput: true,
                      hintText: "Phone",
                      initialValue: PhoneNumber(isoCode: "US"),
                      countries: ["US", "CN", "CA", "IN", "JP", "KR"],
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          flex: 2,
                          child: new Text(
                            "Gender",
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 16.0),
                          ),
                        ),
                        new Expanded(
                          flex: 1,
                          child: new DropdownButton(
                            value: currUser.gender,
                            items: [
                              DropdownMenuItem(
                                  child: new Text("Male"), value: "Male"),
                              DropdownMenuItem(
                                  child: new Text("Female"), value: "Female"),
                              DropdownMenuItem(
                                  child: new Text("Other"), value: "Other"),
                              DropdownMenuItem(
                                  child: new Text("Prefer not to say"),
                                  value: "Opt-Out"),
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
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 16.0),
                          ),
                        ),
                        new Expanded(
                          flex: 1,
                          child: new DropdownButton(
                            value: currUser.shirtSize,
                            items: [
                              DropdownMenuItem(
                                  child: new Text("S"), value: "S"),
                              DropdownMenuItem(
                                  child: new Text("M"), value: "M"),
                              DropdownMenuItem(
                                  child: new Text("L"), value: "L"),
                              DropdownMenuItem(
                                  child: new Text("XL"), value: "XL"),
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
                            text:
                                "By creating a myDECA account, you agree to our ",
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
                    new Padding(padding: EdgeInsets.all(16.0)),
                    registerWidget,
                    new Padding(padding: EdgeInsets.all(8.0)),
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

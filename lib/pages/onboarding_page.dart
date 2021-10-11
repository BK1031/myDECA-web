import 'dart:html';
import 'dart:io';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/navbars/onboarding_navbar.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'package:platform_detect/platform_detect.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;
import '../utils/config.dart';
import '../utils/theme.dart';
import 'package:flutter/src/painting/text_style.dart' as ts;
class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  final Storage _localStorage = html.window.localStorage;

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
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 1100) {
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
                                "images/onboarding-header.png",
                                width: double.infinity,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                              new Container(
                                height: 2500,
                              ),
                              new Container(
                                color: mainColor,
                                child: Column(
                                  children: [
                                    new Padding(padding: EdgeInsets.all(200)),
                                    new Center(
                                      child: new Text(
                                        "DOWNLOAD\nAPP",
                                        style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 80, color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    new Padding(padding: EdgeInsets.all(20)),
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        new RaisedButton(
                                          padding: EdgeInsets.only(left: 32, top: 16, bottom: 16, right: 32),
                                          elevation: 0.0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                          child: Row(
                                            children: [
                                              new Icon(Icons.save_alt, color: mainColor,),
                                              new Padding(padding: EdgeInsets.all(8)),
                                              new Text("DOWNLOAD ${operatingSystem.isMac ? "FOR MAC" : operatingSystem.isWindows ? "FOR WINDOWS" : ""}", style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 25),),
                                            ],
                                          ),
                                          color: Colors.white,
                                          textColor: mainColor,
                                          onPressed: () {
                                            router.navigateTo(context, "/beta", transition: TransitionType.fadeIn);
                                          },
                                        ),
                                        new Padding(padding: EdgeInsets.all(8)),
                                        new RaisedButton(
                                          padding: EdgeInsets.only(left: 32, top: 16, bottom: 16, right: 32),
                                          elevation: 0.0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                          child: new Text("OPEN MYDECA IN BROWSER", style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 25),),
                                          color: mainColor,
                                          textColor: Colors.white,
                                          onPressed: getStarted
                                        ),
                                      ],
                                    ),
                                    new Padding(padding: EdgeInsets.all(20)),
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        new InkWell(
                                          onTap: () => launch("https://apps.apple.com/app/id1529395313"),
                                          child: new Image.asset(
                                            "images/app-store.png",
                                            height: 60,
                                          ),
                                        ),
                                        new Padding(padding: EdgeInsets.all(8)),
                                        new InkWell(
                                          onTap: () => launch("https://play.google.com/store/apps/details?id=com.bk1031.mydeca_flutter"),
                                          child: new Image.asset(
                                            "images/google-play.png",
                                            height: 87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    new Padding(padding: EdgeInsets.all(20)),
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
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            new RaisedButton(
                                              padding: EdgeInsets.only(left: 32, top: 16, bottom: 16, right: 32),
                                              elevation: 0.0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                              child: new Text("JOIN BETA", style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 25),),
                                              color: mainColor,
                                              textColor: Colors.white,
                                              onPressed: () {
                                                router.navigateTo(context, "/beta", transition: TransitionType.fadeIn);
                                              },
                                            ),
                                            new Padding(padding: EdgeInsets.all(16)),
                                            new OutlineButton(
                                                padding: EdgeInsets.only(left: 32, top: 16, bottom: 16, right: 32),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                                borderSide: BorderSide(color: Colors.grey),
                                                child: new Text("LEARN MORE", style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 25)),
                                                textColor: Colors.white,
                                                color: mainColor,
                                                onPressed: () => launch("https://docs.mydeca.org")
                                            ),
                                          ],
                                        ),
                                        new Padding(padding: EdgeInsets.all(100)),
                                        new Image.asset(
                                          "images/onboarding-block1.png",
                                          height: 400,
                                        ),
                                      ],
                                    ),
                                    new Image.asset(
                                      "images/onboarding-screen1.png",
                                      height: 800,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    new Image.asset(
                                      "images/onboarding-screen2.png",
                                      height: 800,
                                    ),
                                    new Image.asset(
                                      "images/onboarding-block2.png",
                                      height: 400,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    new Image.asset(
                                      "images/onboarding-block3.png",
                                      height: 800,
                                    ),
                                  ],
                                ),
                                new Padding(padding: EdgeInsets.all(64)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    new Image.asset(
                                      "images/onboarding-block4.png",
                                      height: 800,
                                    ),
                                  ],
                                ),
                                new Container(
                                  height: 425,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      new OnboardingNavbar()
                    ],
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
          backgroundColor: Colors.black.withOpacity(0.8),
          title: new Image.asset(
            "images/deca-logo.png",
            height: 30,
            color: Colors.white,
            fit: BoxFit.contain,
          ),
        ),
        drawer: new OnboardingNavbar(),
        backgroundColor: mainColor.withOpacity(0.2),
        body: new Container(
          child: new SingleChildScrollView(
            child: new Column(
              children: [
                new Image.asset(
                  "images/onboarding-header.png",
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                Column(
                  children: [
                    new Image.asset(
                      "images/onboarding-screen1.png",
                    ),
                    new Image.asset(
                      "images/onboarding-block1.png",
                    ),
                  ],
                ),
                Column(
                  children: [
                    new Image.asset(
                      "images/onboarding-screen2.png",
                    ),
                    new Image.asset(
                      "images/onboarding-block2.png",
                    ),
                  ],
                ),
                Column(
                  children: [
                    new Image.asset(
                      "images/onboarding-block3.png",
                    ),
                  ],
                ),
                new Padding(padding: EdgeInsets.all(64)),
                new Image.asset(
                  "images/onboarding-block4.png",
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    new RaisedButton(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 16),
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: new Text("JOIN BETA", style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 18),),
                      color: mainColor,
                      textColor: Colors.white,
                      onPressed: () {
                        router.navigateTo(context, "/beta", transition: TransitionType.fadeIn);
                      },
                    ),
                    new OutlineButton(
                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                        borderSide: BorderSide(color: Colors.grey),
                        child: new Text("LEARN MORE", style: TextStyle(fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 18)),
                        textColor: Colors.white,
                        color: mainColor,
                        onPressed: () => launch("https://docs.mydeca.org")
                    ),
                  ],
                ),
                new Padding(padding: EdgeInsets.all(16)),
                new Container(
                  color: mainColor,
                  child: Column(
                    children: [
                      new Padding(padding: EdgeInsets.all(20)),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new InkWell(
                            onTap: () => launch("https://apps.apple.com/app/id1529395313"),
                            child: new Image.asset(
                              "images/app-store.png",
                              height: 40,
                            ),
                          ),
                          new Padding(padding: EdgeInsets.all(8)),
                          new InkWell(
                            onTap: () => launch("https://play.google.com/store/apps/details?id=com.bk1031.mydeca_flutter"),
                            child: new Image.asset(
                              "images/google-play.png",
                              height: 60,
                            ),
                          ),
                        ],
                      ),
                      new Padding(padding: EdgeInsets.all(20)),
                      Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: new Wrap(
                          direction: Axis.horizontal,
                          children: [
                            new FlatButton(
                              child: new Text("Copyright © 2020 Equinox Initiative"),
                              textColor: Colors.white,
                              onPressed: () => launch("https://equinox.bk1031.dev"),
                            ),
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
                        ),
                      )
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
}

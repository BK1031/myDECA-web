import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';

class WelcomeDialog extends StatefulWidget {
  @override
  _WelcomeDialogState createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {

  String status = "";

  @override
  void initState() {
    super.initState();
    sendVerification();
  }

  void sendVerification() {
    fb.auth().currentUser.sendEmailVerification();
  }

  void checkVerification() {
    fb.auth().currentUser.reload();
    if (fb.auth().currentUser.emailVerified) {
      print("VERIFIED");
      setState(() {
        status = "Email Verified!";
      });
      fb.database().ref("users").child(fb.auth().currentUser.uid).child("emailVerified").set(true);
      html.window.location.reload();
    }
    else {
      setState(() {
        status = "Email Not Verified";
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          status = "";
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 550.0,
      child: new SingleChildScrollView(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Text(
                "We're excited to have you onboard. Here are some resources to help you get started with myDECA:"
              ),
              new Padding(padding: EdgeInsets.all(8)),
              Container(
                height: 100,
                child: new Row(
                  children: [
                    new Expanded(
                      child: new Card(
                        child: new InkWell(
                          onTap: () {
                            html.window.open("https://docs.mydeca.org/user-1/registration", "Guide");
                          },
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              new Icon(Icons.view_list),
                              new Text("Getting Started Guide")
                            ],
                          ),
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(8)),
                    new Expanded(
                      child: new Card(
                        child: new InkWell(
                          onTap: () {

                          },
                          child: new Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              new Icon(Icons.ondemand_video),
                              new Text("Video Tutorials")
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              new Padding(padding: EdgeInsets.all(8)),
              new Text("One more thing, please verify your email via the link we just sent you. "),
              new Padding(padding: EdgeInsets.all(8)),
              new Text(status, style: TextStyle(color: status == "Email Not Verified" ? Colors.red : Colors.green),),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  new FlatButton(
                    child: new Text("RESEND VERIFICATION EMAIL", style: TextStyle(color: mainColor),),
                    onPressed: () {
                      sendVerification();
                    },
                  ),
                  new RaisedButton(
                    color: mainColor,
                    textColor: Colors.white,
                    child: new Text("VERIFY"),
                    onPressed: () {
                      checkVerification();
                    },
                  ),
                ],
              ),
            ]
        ),
      ),
    );
  }
}

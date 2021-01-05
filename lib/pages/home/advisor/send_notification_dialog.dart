import 'package:flutter/material.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/utils/button_filled.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'package:firebase/firebase.dart' as fb;

class SendNotificationDialog extends StatefulWidget {
  User currUser;
  SendNotificationDialog(this.currUser);
  @override
  _SendNotificationDialogState createState() => _SendNotificationDialogState(this.currUser);
}

class _SendNotificationDialogState extends State<SendNotificationDialog> {

  User currUser;

  String alertTitle = "";
  String alertBody = "";
  List<String> topics = [];
  bool verified = false;

  double visibilityBoxHeight = 0.0;

  final bodyController = new TextEditingController();

  _SendNotificationDialogState(this.currUser);

  void showAlert(String alert) {
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

  publish(String title, String alert) {
    if (alertBody != "" && alertTitle != "" && topics.isNotEmpty) {
      if (!verified) {
        for (int i = 0; i < topics.length; i++) {
          topics[i] = "${currUser.chapter.chapterID}_" + topics[i];
        }
      }
      print(topics);
      fb.database().ref("notifications").push().update({
        "title": title,
        "body": alert,
        "topics": topics
      });
      print("Notification added to queue");
      router.pop(context);
    }
    else {
      showAlert("It looks like some info is missing. Don't forget to select the notification recipients!");
    }
  }

  Widget getTrailingCheck(String val) {
    Widget returnWidget = Container(child: new Text(""),);
    if (topics.contains(val)) {
      setState(() {
        returnWidget = Icon(Icons.check, color: mainColor);
      });
    }
    return returnWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550.0,
      child: new SingleChildScrollView(
        child: new Column(
          children: [
            new Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width > 550 ? 16.0 : 0),
              child: new Column(
                children: <Widget>[
                  new TextField(
                    decoration: InputDecoration(
                        labelText: "Title"
                    ),
                    autocorrect: true,
                    onChanged: (input) {
                      setState(() {
                        alertTitle = input;
                      });
                    },
                  ),
                  new TextField(
                    decoration: InputDecoration(
                        labelText: "Details"
                    ),
                    autocorrect: true,
                    onChanged: (input) {
                      setState(() {
                        alertBody = input;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.all(4.0),),
            new AnimatedContainer(
              height: verified ? 70 : 0,
              duration: const Duration(milliseconds: 200),
              child: new Visibility(
                visible: verified,
                child: new Card(
                  color: Color(0xFFffebba),
                  child: new Container(
                    padding: EdgeInsets.all(8),
                    child: new Row(
                      children: [
                        new Icon(Icons.warning, color: Colors.orangeAccent,),
                        new Padding(padding: EdgeInsets.all(4)),
                        new Text("Your notification will be sent\nto members from ALL chapters.", style: TextStyle(color: Colors.orangeAccent),)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            new ListTile(
              leading: new Icon(Icons.group_add),
              title: new Text("Select Recipients"),
              trailing: new Visibility(
                visible: currUser.roles.contains("Developer"),
                child: new Tooltip(
                  message: verified ? "Official DECA Communication" : "",
                  child: new InkWell(
                    onTap: () {
                      setState(() {
                        verified = !verified;
                      });
                    },
                    child: new Card(
                      color: verified ? mainColor : Colors.grey,
                      child: new Container(
                        padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: new Text(verified ? "✓  VERIFIED" : "UNOFFICIAL", style: TextStyle(color: Colors.white),),
                      ),
                    ),
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  if (visibilityBoxHeight == 0.0) {
                    visibilityBoxHeight = 200;
                  }
                  else {
                    visibilityBoxHeight = 0.0;
                  }
                });
              },
            ),
            new AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: visibilityBoxHeight,
                child: new Scrollbar(
                  child: new ListView(
                    children: <Widget>[
                      new Text("Only users with the roles selected below will recieve this announcement."),
                      new ListTile(
                        leading: topics.contains("Member") ? Icon(Icons.check_box, color: mainColor) : Icon(Icons.check_box_outline_blank, color: Colors.grey),
                        title: new Text("Member"),
                        onTap: () {
                          setState(() {
                            topics.contains("Member") ? topics.remove("Member") : topics.add("Member");
                          });
                        },
                      ),
                      new ListTile(
                        leading: topics.contains("Officer") ? Icon(Icons.check_box, color: mainColor) : Icon(Icons.check_box_outline_blank, color: Colors.grey),
                        title: new Text("Officer"),
                        onTap: () {
                          setState(() {
                            topics.contains("Officer") ? topics.remove("Officer") : topics.add("Officer");
                          });
                        },
                      ),
                      new ListTile(
                        leading: topics.contains("President") ? Icon(Icons.check_box, color: mainColor) : Icon(Icons.check_box_outline_blank, color: Colors.grey),
                        title: new Text("President"),
                        onTap: () {
                          setState(() {
                            topics.contains("President") ? topics.remove("President") : topics.add("President");
                          });
                        },
                      ),
                      new ListTile(
                        leading: topics.contains("Advisor") ? Icon(Icons.check_box, color: mainColor) : Icon(Icons.check_box_outline_blank, color: Colors.grey),
                        title: new Text("Advisor"),
                        onTap: () {
                          setState(() {
                            topics.contains("Advisor") ? topics.remove("Advisor") : topics.add("Advisor");
                          });
                        },
                      ),
                      new ListTile(
                        leading: topics.contains("Developer") ? Icon(Icons.check_box, color: mainColor) : Icon(Icons.check_box_outline_blank, color: Colors.grey),
                        title: new Text("Developer"),
                        onTap: () {
                          setState(() {
                            topics.contains("Developer") ? topics.remove("Developer") : topics.add("Developer");
                          });
                        },
                      ),
                      new Visibility(
                        visible: topics.contains("Member") && !topics.contains("Advisor"),
                        child: new Card(
                          color: Color(0xFFffebba),
                          child: new Container(
                            padding: EdgeInsets.all(8),
                            child: new Row(
                              children: [
                                new Icon(Icons.warning, color: Colors.orangeAccent,),
                                new Padding(padding: EdgeInsets.all(4)),
                                new Text("Advisors are not given the\nMember role by default, so\nyour advisors may not recieve\nthis announcement.", style: TextStyle(color: Colors.orangeAccent),)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ),
            Padding(padding: EdgeInsets.all(4.0),),
            new Container(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: new ButtonFilled(
                onPressed: () {
                  publish(alertTitle, alertBody);
                },
                color: mainColor,
                child: new Text("Send Notification".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 18.0),),
              ),
            )
          ],
        ),
      ),
    );
  }
}

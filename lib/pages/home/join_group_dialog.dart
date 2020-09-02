import 'package:flutter/material.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';

class JoinGroupDialog extends StatefulWidget {
  User currUser;
  JoinGroupDialog(this.currUser);
  @override
  _JoinGroupDialogState createState() => _JoinGroupDialogState(this.currUser);
}

class _JoinGroupDialogState extends State<JoinGroupDialog> {

  User currUser;
  List<Widget> widgetList = new List();
  List<String> groupList = new List();

  String joinCode = "";

  TextEditingController _controller = new TextEditingController();

  _JoinGroupDialogState(this.currUser);

  @override
  void initState() {
    super.initState();
    fb.database().ref("users").child(currUser.userID).onValue.listen((value) {
      setState(() {
        widgetList.clear();
        currUser = User.fromSnapshot(value.snapshot);
      });
      groupList.clear();
      for (int i = 0; i < currUser.groups.length; i++) {
        print(currUser.groups[i]);
        groupList.add(currUser.groups[i]);
        fb.database().ref("chapters").child(currUser.chapter.chapterID).child("groups").child(currUser.groups[i]).child("name").once("value").then((value) {
          if (value.snapshot.val() != null) {
            setState(() {
              widgetList.add(new ListTile(
                title: new Text(value.snapshot.val()),
                trailing: new IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    groupList.remove(currUser.groups[i]);
                    fb.database().ref("users").child(currUser.userID).child("groups").set(groupList);
                  },
                )
              ));
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 550.0,
      child: new SingleChildScrollView(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Column(
                children: widgetList,
              ),
              new Padding(padding: EdgeInsets.all(16)),
              new Text("Join a Group", style: TextStyle(fontSize: 20),),
              new Visibility(
                visible: joinCode == "INVALID",
                child: new Text("Invalid Code", style: TextStyle(color: Colors.red),),
              ),
              Container(
                height: 65,
                child: Row(
                  children: [
                    new Expanded(
                      child: new TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: "Join Code"
                        ),
                        onChanged: (input) {
                          setState(() {
                            joinCode = input;
                          });
                        },
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(8)),
                    Container(
                      width: 75,
                      child: new RaisedButton(
                        color: mainColor,
                        textColor: Colors.white,
                        child: new Text("JOIN"),
                        onPressed: () {
                          if (joinCode != "" && !groupList.contains(joinCode)) {
                            fb.database().ref("chapters").child(currUser.chapter.chapterID).child("groups").child(joinCode).once("value").then((value) {
                              if (value.snapshot.val() != null) {
                                groupList.add(joinCode);
                                fb.database().ref("users").child(currUser.userID).child("groups").set(groupList);
                                _controller.clear();
                              }
                              else {
                                setState(() {
                                  joinCode = "INVALID";
                                });
                              }
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),
              )
            ]
        ),
      ),
    );
  }
}

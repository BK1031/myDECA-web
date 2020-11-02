import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';

class EventTeammateDialog extends StatefulWidget {
  String type;
  User currUser;

  EventTeammateDialog(this.type, this.currUser);
  @override
  _EventTeammateDialogState createState() => _EventTeammateDialogState(this.type, this.currUser);
}

class _EventTeammateDialogState extends State<EventTeammateDialog> {

  String type;
  User currUser;

  List<User> usersList = new List();

  _EventTeammateDialogState(this.type, this.currUser);

  @override
  void initState() {
    super.initState();
    fb.database().ref("users").onChildAdded.listen((event) {
      User user = new User.fromSnapshot(event.snapshot);
      if (user.chapter.chapterID == currUser.chapter.chapterID && user.userID != currUser.userID && (type == "written" ? !writtenTeam.contains(user) : !roleplayTeam.contains(user))) {
        setState(() {
          usersList.add(user);
          usersList.sort((a, b) => a.firstName.compareTo(b.firstName));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      child: new SingleChildScrollView(
        child: new Column(children: usersList.map((e) => new Container(
          padding: EdgeInsets.only(bottom: 8),
          child: new InkWell(
            onTap: () {
              if (type == "written") {
                setState(() {
                  writtenTeam.add(e);
                });
              }
              else if (type == "roleplay") {
                setState(() {
                  roleplayTeam.add(e);
                });
              }
              router.pop(context);
            },
            child: new Card(
              child: Container(
                padding: EdgeInsets.all(8),
                child: new Row(
                  children: [
                    new CircleAvatar(
                      radius: 25,
                      backgroundColor: roleColors[e.roles.first],
                      child: new ClipRRect(
                        borderRadius: new BorderRadius.all(Radius.circular(45)),
                        child: new CachedNetworkImage(
                          imageUrl: e.profileUrl,
                          height: 45,
                          width: 45,
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(8),),
                    new Column(
                      children: [
                        new Text(
                            e.firstName + " " + e.lastName
                        ),
                        new Text(
                            e.email
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )).toList()),
      ),
    );
  }
}

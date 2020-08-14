import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';

class ManageGroupDialog extends StatefulWidget {
  String id;
  User currUser;
  ManageGroupDialog(this.id, this.currUser);
  @override
  _ManageGroupDialogState createState() => _ManageGroupDialogState(this.id, this.currUser);
}

class _ManageGroupDialogState extends State<ManageGroupDialog> {

  String id;
  String name = "";
  User currUser;
  List<Widget> usersWidgetList = new List();

  _ManageGroupDialogState(this.id, this.currUser);

  @override
  void initState() {
    super.initState();
    fb.database().ref("chapters").child(currUser.chapter.chapterID).child("groups").child(id).once("value").then((value) {
      setState(() {
        name = value.snapshot.val().toString();
      });
    });
    fb.database().ref("users").onChildAdded.listen((value) {
      User user = new User.fromSnapshot(value.snapshot);
      if (user.groups.contains(id)) {
        setState(() {
          usersWidgetList.add(new Container(
            padding: EdgeInsets.only(bottom: 8),
            child: new InkWell(
              child: new Card(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: new Row(
                    children: [
                      new CircleAvatar(
                        radius: 25,
                        backgroundColor: roleColors[user.roles.first],
                        child: new ClipRRect(
                          borderRadius: new BorderRadius.all(Radius.circular(45)),
                          child: new CachedNetworkImage(
                            imageUrl: user.profileUrl,
                            height: 45,
                            width: 45,
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(8),),
                      new Column(
                        children: [
                          new Text(
                              user.firstName + " " + user.lastName
                          ),
                          new Text(
                              user.email
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ));
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
              new Text(
                name,
                style: TextStyle(fontFamily: "Montserrat", fontSize: 22, color: currTextColor),
              ),
              new Text(
                id,
                style: TextStyle(color: Colors.grey),
              ),
              new Column(
                children: usersWidgetList,
              )
            ]
        ),
      ),
    );
  }
}

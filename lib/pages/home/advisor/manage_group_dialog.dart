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
  String handbook = "";
  User currUser;
  List<Widget> usersWidgetList = new List();
  List<Widget> handbookWidgetList = new List();

  double height = 0;

  _ManageGroupDialogState(this.id, this.currUser);

  void getHandbooks() {
    setState(() {
      handbookWidgetList.clear();
      handbookWidgetList.add(Container(padding: EdgeInsets.all(8), child: new Text("Select a Handbook")));
    });
    fb.database().ref("chapters").child(currUser.chapter.chapterID).child("handbooks").onChildAdded.listen((event) {
      setState(() {
        handbookWidgetList.add(
          new ListTile(
            leading: (event.snapshot.val()["name"] == handbook) ? Icon(Icons.radio_button_checked, color: mainColor,) : Icon(Icons.radio_button_unchecked, color: mainColor,),
            title: new Text(event.snapshot.val()["name"]),
            onTap: () {
              setState(() {
                fb.database().ref("chapters").child(currUser.chapter.chapterID).child("groups").child(id).child("handbook").set(event.snapshot.key);
                height = 0;
              });
            },
          )
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fb.database().ref("chapters").child(currUser.chapter.chapterID).child("groups").child(id).onValue.listen((value) {
      setState(() {
        name = value.snapshot.val()["name"];
      });
      if (value.snapshot.val()["handbook"] != null) {
        String handbookID = value.snapshot.val()["handbook"];
        fb.database().ref("chapters").child(currUser.chapter.chapterID).child("handbooks").child(handbookID).child("name").once("value").then((value) {
          setState(() {
            handbook = value.snapshot.val();
          });
        });
      }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 25,
                    child: new RaisedButton(
                      child: Text("DELETE", style: TextStyle()),
                      color: Colors.red,
                      textColor: Colors.white,
                      onPressed: () {
                        fb.database().ref("chapters").child(currUser.chapter.chapterID).child("groups").child(id).remove();
                        router.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              new Padding(padding: EdgeInsets.all(4)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                    ],
                  ),
                  new InkWell(
                    onTap: () {
                      if (height == 0) {
                        getHandbooks();
                        setState(() {
                          height = 250;
                        });
                      }
                      else {
                        setState(() {
                          height = 0;
                        });
                      }
                    },
                    child: new Card(
                      elevation: handbook == "" ? 0 : 1,
                      color: handbook == "" ? currCardColor : mainColor,
                      child: new Container(
                        padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                        child: new Text(handbook == "" ? "Select Handbook" : handbook, style: TextStyle(color: handbook == "" ? mainColor : Colors.white),),
                      ),
                    ),
                  )
                ],
              ),
              new AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: height,
                child: new Column(
                  children: handbookWidgetList,
                ),
              ),
              new Padding(padding: EdgeInsets.all(8)),
              new Visibility(
                visible: usersWidgetList.isEmpty,
                child: Center(child: new Text("No users have joined this group.\nPlease check again later.", textAlign: TextAlign.center,)),
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

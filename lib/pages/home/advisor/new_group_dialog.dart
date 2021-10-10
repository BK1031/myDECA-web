import 'package:flutter/material.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';

class NewGroupDialog extends StatefulWidget {
  User currUser;
  NewGroupDialog(this.currUser);
  @override
  _NewGroupDialogState createState() => _NewGroupDialogState(this.currUser);
}

class _NewGroupDialogState extends State<NewGroupDialog> {
  User currUser;
  String id = "";
  String name = "";
  bool valid = false;

  _NewGroupDialogState(this.currUser);

  void checkValid() {
    fb
        .database()
        .ref("chapters")
        .child(currUser.chapter.chapterID)
        .child("groups")
        .child(id)
        .once("value")
        .then((value) {
      if (value.snapshot.val() != null) {
        // Group with id already exists
        setState(() {
          valid = false;
        });
      } else {
        // Group with id doesnt exist
        setState(() {
          valid = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 350.0,
      child: new SingleChildScrollView(
        child:
            new Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          new Visibility(
            visible: id != "",
            child: new Text(
              "Your code will be: $id",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          new Visibility(
            visible: id.length > 0,
            child: new Text(
              valid ? "Valid Code" : "Invalid Code",
              style: TextStyle(color: valid ? Colors.green : Colors.red),
            ),
          ),
          Row(
            children: [
              Container(
                width: 300,
                child: new TextField(
                  decoration: InputDecoration(
                    labelText: "Join Code",
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (input) {
                    id = input.toUpperCase().replaceAll(" ", "");
                    checkValid();
                  },
                ),
              ),
              new IconButton(
                  icon: Icon(Icons.help),
                  tooltip:
                      "This is the code that members can use to join the group")
            ],
          ),
          new TextField(
            decoration: InputDecoration(labelText: "Name"),
            onChanged: (input) {
              name = input;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              new FlatButton(
                child: new Text(
                  "CANCEL",
                  style: TextStyle(color: mainColor),
                ),
                onPressed: () {
                  router.pop(context);
                },
              ),
              new FlatButton(
                child: new Text(
                  "CREATE",
                  style: TextStyle(color: mainColor),
                ),
                onPressed: () {
                  if (valid && name != "") {
                    fb
                        .database()
                        .ref("chapters")
                        .child(currUser.chapter.chapterID)
                        .child("groups")
                        .child(id.toUpperCase())
                        .set({"name": name});
                    router.pop(context);
                  }
                },
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

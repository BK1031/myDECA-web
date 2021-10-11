import 'package:flutter/material.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/role_picker.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'package:flutter/src/painting/text_style.dart' as ts;
class ManageUserRolesDialog extends StatefulWidget {
  User user;
  User currUser;
  ManageUserRolesDialog(this.user, this.currUser);
  @override
  _ManageUserRolesDialogState createState() => _ManageUserRolesDialogState(this.user, this.currUser);
}

class _ManageUserRolesDialogState extends State<ManageUserRolesDialog> {

  User user;
  User currUser;
  List<Widget> widgetList = [];
  List<String> newRolesList = [];

  _ManageUserRolesDialogState(this.user, this.currUser);

  @override
  void initState() {
    super.initState();
  }

  void updateRoles(List<String> list) {
    fb.database().ref("users").child(user.userID).child("roles").set(list);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 550.0,
      child: new SingleChildScrollView(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new RolePicker(
                user.roles,
                (list) {
                  newRolesList = list;
                },
                currUser.roles.first
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  new FlatButton(
                    child: new Text("CANCEL", style: TextStyle(color: mainColor),),
                    onPressed: () {
                      router.pop(context);
                    },
                  ),
                  new FlatButton(
                    child: new Text("OK", style: TextStyle(color: mainColor),),
                    onPressed: () {
                      if (newRolesList.isNotEmpty) {
                        fb.database().ref("users").child(user.userID).child("roles").set(newRolesList);
                        router.pop(context);
                      }
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

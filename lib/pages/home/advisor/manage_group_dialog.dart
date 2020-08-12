import 'package:flutter/material.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:firebase/firebase.dart' as fb;

class ManageGroupDialog extends StatefulWidget {
  String id;
  User currUser;
  ManageGroupDialog(this.id, this.currUser);
  @override
  _ManageGroupDialogState createState() => _ManageGroupDialogState(this.id, this.currUser);
}

class _ManageGroupDialogState extends State<ManageGroupDialog> {

  String id;
  User currUser;

  _ManageGroupDialogState(this.id, this.currUser);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

import 'package:firebase/firebase.dart';

class Meeting {
  String id = "";
  String name = "";
  String url = "";
  DateTime startTime;
  DateTime endTime;

  Meeting();

  Meeting.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    name = snapshot.val()["name"];
    url = snapshot.val()["url"];
    startTime = DateTime.parse(snapshot.val()["startTime"]);
    endTime = DateTime.parse(snapshot.val()["endTime"]);
  }
}
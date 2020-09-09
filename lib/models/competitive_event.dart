import 'package:firebase/firebase.dart';

class CompetitiveEvent {
  String id = "";
  String name = "";
  String desc = "";
  String type = "";
  String cluster = "";
  String guidelines = "";
  DataSnapshot snapshot;

  CompetitiveEvent();

  CompetitiveEvent.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    name = snapshot.val()["name"];
    desc = snapshot.val()["desc"];
    type = snapshot.val()["type"];
    cluster = snapshot.val()["cluster"];
    guidelines = snapshot.val()["guidelines"];
    this.snapshot = snapshot;
  }
}
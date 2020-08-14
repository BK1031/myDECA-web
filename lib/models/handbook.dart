import 'package:firebase/firebase.dart';

class Handbook {

  String handbookID = "";
  String name = "";
  List<String> tasks = new List();

  Handbook.plain();

  Handbook.fromSnapshot(DataSnapshot snapshot) {
    handbookID = snapshot.key;
    name = snapshot.val()["name"];
    if (snapshot.val()["tasks"] != null) {
      for (int i = 0; i < snapshot.val()["tasks"].length; i++) {
        tasks.add(snapshot.val()["tasks"][i]);
      }
    }
  }
}
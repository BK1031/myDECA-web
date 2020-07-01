import 'package:firebase/firebase.dart';

class ConferenceWinner {
  String key;
  String name;
  String event;
  String award;

  ConferenceWinner(this.name, this.event, this.award);

  ConferenceWinner.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.val()["name"],
        event = snapshot.val()["event"],
        award = snapshot.val()["award"];

  @override
  String toString() {
    return "$name – $award";
  }
}
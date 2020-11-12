import 'package:firebase/firebase.dart';

class ConferenceAgendaItem {
  String key = "";
  String title = "";
  String desc = "";
  String date = "";
  String time = "";
  String endTime = "";
  String location = "";

  ConferenceAgendaItem.plain();

  ConferenceAgendaItem.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        title = snapshot.val()["title"],
        desc = snapshot.val()["desc"],
        date = snapshot.val()["date"],
        time = snapshot.val()["time"],
        endTime = snapshot.val()["endTime"],
        location = snapshot.val()["location"];
}
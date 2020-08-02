import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/user.dart';

class Announcement {
  String announcementID  = "";
  String title = "";
  String desc = "";
  DateTime date = new DateTime.now();
  User author = new User.plain();
  bool read = false;
  bool official = false;
  List<String> topics = new List();

  Announcement.plain();

  Announcement.fromSnapshot(fb.DataSnapshot snapshot) {
    announcementID = snapshot.key;
    title = snapshot.val()["title"];
    desc = snapshot.val()["desc"];
    date = DateTime.parse(snapshot.val()["date"]);
    author.userID = snapshot.val()["author"];
    for (int i = 0; i < snapshot.val()["topics"].length; i++) {
      topics.add(snapshot.val()["topics"][i]);
    }
  }
}
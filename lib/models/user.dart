import 'package:firebase/firebase.dart';
import 'package:mydeca_web/models/chapter.dart';

class User {
  String userID = "";
  String firstName = "";
  String lastName = "";
  String email = "";
  bool emailVerified = false;
  String profileUrl = "";
  String gender = "Male";
  List<String> roles = new List();
  int grade = 9;
  int yearsMember = 0;
  String shirtSize = "M";
  Chapter chapter = new Chapter();

  User.plain();

  User.fromSnapshot(DataSnapshot snapshot) {
    userID = snapshot.key;
    firstName = snapshot.val()["firstName"];
    lastName = snapshot.val()["lastName"];
    email = snapshot.val()["email"];
    emailVerified = snapshot.val()["emailVerified"];
    profileUrl = snapshot.val()["profileUrl"];
    gender = snapshot.val()["gender"];
    grade = snapshot.val()["grade"];
    yearsMember = snapshot.val()["yearsMember"];
    shirtSize = snapshot.val()["shirtSize"];
    chapter.chapterID = snapshot.val()["chapterID"];
    for (int i = 0; i < snapshot.val()["roles"].length; i++) {
      roles.add(snapshot.val()["roles"][i]);
    }
  }

  @override
  String toString() {
    return "$firstName $lastName <$email> Grade $grade";
  }

}
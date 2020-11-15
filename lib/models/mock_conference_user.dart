import 'package:mydeca_web/models/user.dart';

class MockConferenceUser {
  User user = new User.plain();
  String writtenTeamID = "";
  String writtenEvent = "";
  String writtenUrl = "";
  List<User> writtenTeam = new List();
  int writtenScore = 0;

  String roleplayTeamID = "";
  String roleplayEvent = "";
  List<User> roleplayTeam = new List();
  int roleplayScore = 0;

  String testName = "";
  int testScore = 0;
}
import 'package:mydeca_web/models/user.dart';

class MockConferenceTeam {
  String teamID = "";
  String type = "";
  String event = "";
  String writtenUrl = "";

  DateTime startTime;
  User judge = User.plain();
  int score;

  int testScore = 0;

  List<User> users = new List();
}
import 'package:mydeca_web/models/user.dart';

class MockConferenceTeam {
  String teamID = "";
  String type = "";
  String event = "";
  String writtenUrl = "";

  DateTime startTime;
  User judge = User.plain();

  List<User> users = new List();
}
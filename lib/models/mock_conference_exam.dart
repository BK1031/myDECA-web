import 'package:mydeca_web/models/user.dart';

class MockConferenceExam {
  String examName = "";
  List<MockConferenceExamQuestion> questions = new List(50);
  int score = -1;
  User user;

  String testUrl = 'https://static.impression.co.uk/2014/05/loading1.gif';
  String solutionUrl = 'https://static.impression.co.uk/2014/05/loading1.gif';
}

class MockConferenceExamQuestion {
  int number = 0;
  String myAnswer;
  String correctAnswer;
}
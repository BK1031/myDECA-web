import 'handbook_item.dart';
import 'user.dart';

class UserHandbook {
  String handbookID = "";
  String name = "";
  User user = new User.plain();
  List<HandbookItem> items = new List();
}
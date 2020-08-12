import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/utils/theme.dart';

class AdvisorConferenceSelect extends StatefulWidget {
  User user;
  AdvisorConferenceSelect(this.user);
  @override
  _AdvisorConferenceSelectState createState() => _AdvisorConferenceSelectState(this.user);
}

class _AdvisorConferenceSelectState extends State<AdvisorConferenceSelect> {

  User user;
  List<Widget> widgetList = new List();

  _AdvisorConferenceSelectState(this.user);

  @override
  void initState() {
    super.initState();
    updateWidget();
  }

  void updateWidget() {
    widgetList.clear();
    fb.database().ref("conferences").once("value").then((value) {
      Map<String, dynamic> map = value.snapshot.toJson();
      map.keys.forEach((element) {
        if (!map[element]["past"]) {
          fb.database().ref("chapters").child(user.chapter.chapterID).child("conferences").child(element).child("enabled").once("value").then((enabled) {
            if (enabled.snapshot.val() != null && enabled.snapshot.val()) {
              // Conference has already been enabled
              setState(() {
                widgetList.add(new ListTile(
                  leading: Icon(Icons.check_box, color: mainColor),
                  title: new Text(element),
                  onTap: () {
                    selectConference(false, element);
                  },
                ));
              });
            }
            else {
              setState(() {
                widgetList.add(new ListTile(
                  leading: Icon(Icons.check_box_outline_blank, color: mainColor),
                  title: new Text(element),
                  onTap: () {
                    selectConference(true, element);
                  },
                ));
              });
            }
          });
        }
      });
    });
  }

  void selectConference(bool select, String id) {
    fb.database().ref("chapters").child(user.chapter.chapterID).child("conferences").child(id).child("enabled").set(select);
    updateWidget();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 550.0,
      child: new SingleChildScrollView(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgetList
        ),
      ),
    );
  }
}

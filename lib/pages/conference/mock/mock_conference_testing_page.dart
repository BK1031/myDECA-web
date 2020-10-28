import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/material.dart';
import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/navbars/mobile_sidebar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/pages/conference/conference_media_page.dart';
import 'package:mydeca_web/pages/conference/conference_overview_page.dart';
import 'package:mydeca_web/pages/conference/conference_schedule_page.dart';
import 'package:mydeca_web/pages/conference/conference_winner_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

class MockConferenceTestingPage extends StatefulWidget {
  String id;
  MockConferenceTestingPage(this.id);
  @override
  _MockConferenceTestingPageState createState() => _MockConferenceTestingPageState(this.id);
}

class _MockConferenceTestingPageState extends State<MockConferenceTestingPage> {

  final Storage _localStorage = html.window.localStorage;
  User currUser = User.plain();
  Conference conference = Conference.plain();

  bool taken = false;

  var answers = new List<int>.generate(50, (i) => i + 1);

  _MockConferenceTestingPageState(String id) {
    conference.conferenceID = id;
  }

  @override
  void initState() {
    super.initState();
    if (_localStorage["userID"] != null) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
        });
        fb.database().ref("conferences").child(conference.conferenceID).once("value").then((value) {
          setState(() {
            conference = new Conference.fromSnapshot(value.snapshot);
          });
        });
        if (conference.conferenceID.contains("Mock")) {
          fb.database().ref("conferences").child(conference.conferenceID).child("testScores").child(currUser.userID).once("value").then((value) {
            if (value.snapshot.val() != null) {
              setState(() {
                taken = true;
              });
            }
          });
        }
      });
    }
  }

  String src = 'https://www.deca.org/wp-content/uploads/2020/03/HS_Business_Administration_Core_Sample_Exam_20.pdf';
  String src2 = 'https://flutter.dev/community';
  String src3 = 'http://www.youtube.com/embed/IyFZznAk69U';
  static ValueKey key = ValueKey('key_0');
  static ValueKey key2 = ValueKey('key_1');
  static ValueKey key3 = ValueKey('key_2');
  bool _isHtml = false;
  bool _isMarkdown = false;
  bool _useWidgets = false;
  bool _editing = false;
  bool _isSelectable = false;

  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('BUSINESS ADMINISTRATION CORE EXAM', style: TextStyle(color: Colors.white),),
          centerTitle: true,
          actions: <Widget>[
            Center(child: new Text("37 min remaining", style: TextStyle(color: Colors.white))),
            new Padding(padding: EdgeInsets.all(8))
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(label: new Text("SUBMIT"), onPressed: () {},),
        body: _editing
            ? SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SwitchListTile(
                title: Text('Selectable Text'),
                value: _isSelectable,
                onChanged: (val) {
                  if (mounted)
                    setState(() {
                      _isSelectable = val;
                    });
                },
              ),
            ],
          ),
        )
            : Stack(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: EasyWebView(
                        src: src,
                        onLoaded: () {
                          print('$key: Loaded: $src');
                        },
                        isHtml: _isHtml,
                        isMarkdown: _isMarkdown,
                        convertToWidgets: _useWidgets,
                        key: key
                      // width: 100,
                      // height: 100,
                    )),
                Expanded(
                  flex: 1,
                  child: new SingleChildScrollView(
                    child: new Column(
                      children: answers.map((e) => new Container(
                        padding: EdgeInsets.all(8),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            new Text("Question $e", style: TextStyle(fontSize: 20),),
                            new RadioListTile(
                              title: new Text("A"),
                              value: false,
                            ),
                            new RadioListTile(
                              title: new Text("B"),
                              value: false,
                            ),
                            new RadioListTile(
                              title: new Text("C"),
                              value: false,
                            ),
                            new RadioListTile(
                              title: new Text("D"),
                              value: false,
                            )
                          ],
                        ),
                      )).toList()
                    ),
                  )
                ),
              ],
            ),
          ],
        ));
  }
}

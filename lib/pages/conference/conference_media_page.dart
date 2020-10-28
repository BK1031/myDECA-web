import 'dart:html';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/chapter.dart';
import 'dart:ui' as ui;
import 'package:mydeca_web/models/conference.dart';
import 'package:mydeca_web/models/conference_agenda_item.dart';
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/pages/conference/conference_media_page.dart';
import 'package:mydeca_web/pages/conference/conference_overview_page.dart';
import 'package:mydeca_web/pages/conference/conference_schedule_page.dart';
import 'package:mydeca_web/pages/conference/conference_winner_page.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

class ConferenceMediaPage extends StatefulWidget {
  String id;
  ConferenceMediaPage(this.id);
  @override
  _ConferenceMediaPageState createState() => _ConferenceMediaPageState(this.id);
}

class _ConferenceMediaPageState extends State<ConferenceMediaPage> {

  List<Widget> widgetList = new List();

  User currUser = User.plain();
  final Storage _localStorage = html.window.localStorage;

  String id;

  _ConferenceMediaPageState(this.id);

  @override
  Widget build(BuildContext context) {
    if (widgetList.isEmpty) {
      return Container(
          child: new Text("Nothing to see here!\nCheck back later for media.", textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: currTextColor),)
      );
    }
    else {
      return Container(
        child: new Column(
            children: widgetList
        ),
      );
    }
  }
}

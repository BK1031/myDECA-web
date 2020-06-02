import 'dart:html';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/navbars/home_navbar.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'dart:html' as html;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Storage _localStorage = html.window.localStorage;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new SingleChildScrollView(
        child: new Column(
          children: [
            HomeNavbar()
          ],
        ),
      ),
    );
  }
}

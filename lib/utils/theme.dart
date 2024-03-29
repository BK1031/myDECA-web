import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/src/painting/text_style.dart' as ts;

bool darkMode = false;
bool darkAppBar = false;

// Main DECA Color
Color mainColor = const Color(0xFF0073CE);
// Color for Selected Event
Color eventColor = const Color(0xFF0073CE);

// Role Colors
Map<String, Color> roleColors = {
  "Member": Color(0xFFfcc415),
  "Alumni": Color(0xFFffe28a),
  "Officer": Color(0xFFeb5757),
  "President": Color(0xFFA786DD),
  "Advisor": Color(0xFF00CF9E),
  "Bot": Color(0xFF0073CE),
  "Developer": Color(0xFF0073CE),
  "Judge": Color(0xFFff4ae7)
};

// LIGHT THEME
const lightTextColor = Colors.black;
const lightAccentColor = Color(0xFF0073CE);
const lightBackgroundColor = Color(0xFFf9f9f9);
const lightCardColor = Colors.white;
const lightDividerColor = const Color(0xFFC9C9C9);

// DARK THEME
const darkTextColor = Colors.white;
const darkAccentColor = Color(0xFF0073CE);
const darkBackgroundColor = const Color(0xFF212121);
const darkCardColor = const Color(0xFF2C2C2C);
const darkDividerColor = const Color(0xFF616161);

// CURRENT COLORs
var currTextColor = lightTextColor;
var currAccentColor = lightAccentColor;
var currBackgroundColor = lightBackgroundColor;
var currCardColor = lightCardColor;
var currDividerColor = lightDividerColor;

final mainTheme = new ThemeData(
    primaryColor: currAccentColor,
    accentColor: currAccentColor,
    fontFamily: "Source Sans Pro",
    appBarTheme: new AppBarTheme(
        titleTextStyle: TextStyle(
            fontSize: 20.0,
            fontFamily: "Gotham",
            color: Colors.white,
            fontWeight: FontWeight.bold)));

final markdownStyle = MarkdownStyleSheet(
  h1: TextStyle(
      fontFamily: "Montserrat",
      fontSize: 26,
      color: currTextColor,
      fontWeight: FontWeight.bold),
  h2: TextStyle(
      fontFamily: "Montserrat",
      fontSize: 22,
      color: currTextColor,
      fontWeight: FontWeight.bold),
  h3: TextStyle(
      fontFamily: "Montserrat",
      fontSize: 18,
      color: currTextColor,
      fontWeight: FontWeight.bold),
  p: TextStyle(
      fontFamily: "Source Sans Pro", fontSize: 18, color: currTextColor),
);

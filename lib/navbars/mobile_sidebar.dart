import 'dart:html';
import 'dart:html' as html;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/user.dart';
import 'package:mydeca_web/utils/button_filled.dart';
import 'package:mydeca_web/utils/button_flat.dart';
import 'package:mydeca_web/utils/button_outline.dart';
import 'package:mydeca_web/utils/config.dart';
import 'package:mydeca_web/utils/theme.dart';

class MobileSidebar extends StatefulWidget {
  @override
  _MobileSidebarState createState() => _MobileSidebarState();
}

class _MobileSidebarState extends State<MobileSidebar> {

  User currUser = User.plain();
  final Storage _localStorage = html.window.localStorage;
  List<Widget> roleWidgetList = new List();

  @override
  void initState() {
    super.initState();
    if (_localStorage.containsKey("userID")) {
      fb.database().ref("users").child(_localStorage["userID"]).once("value").then((value) {
        setState(() {
          currUser = User.fromSnapshot(value.snapshot);
          print(currUser);
          for (int i = 0; i < currUser.roles.length; i++) {
            print(currUser.roles[i]);
            roleWidgetList.add(new Card(
              color: roleColors[currUser.roles[i]],
              child: new Container(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                child: new Text(currUser.roles[i], style: TextStyle(color: Colors.white),),
              ),
            ));
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: Scaffold(
        backgroundColor: mainColor,
        body: new SafeArea(
          child: new Container(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Padding(padding: EdgeInsets.all(16)),
                      new ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        child: new CachedNetworkImage(
                          imageUrl: currUser.profileUrl,
                          height: 100,
                        ),
                      ),
                      new Padding(padding: EdgeInsets.all(8)),
                      new Text(
                        currUser.firstName + " " + currUser.lastName,
                        style: TextStyle(color: Colors.white, fontFamily: "Montserrat", fontWeight: FontWeight.bold, fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                      new FlatButton(
                        child: new Text("View Profile"),
                        textColor: Colors.white.withOpacity(0.6),
                        onPressed: () {
                          router.pop(context);
                          Future.delayed(const Duration(milliseconds: 100), () {
                            router.navigateTo(context, "/profile", transition: TransitionType.nativeModal);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new ListTile(
                      leading: Icon(Icons.home, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Home", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/home", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.notifications, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Announcements", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/home/announcements", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.people, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Conferences", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/conferences", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.event_note, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Events", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/events", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.chat, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Chat", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/chat", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                    new ListTile(
                      leading: Icon(Icons.settings, color: Colors.white.withOpacity(0.70),),
                      title: new Text("Settings", style: TextStyle(color: Colors.white, fontSize: 17),),
                      onTap: () {
                        router.pop(context);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          router.navigateTo(context, "/settings", transition: TransitionType.fadeIn, replace: true);
                        });
                      },
                    ),
                  ],
                ),
                new Container(
                  padding: EdgeInsets.only(right: 16, left: 16),
                  width: double.infinity,
                  child: new ButtonFilled(
                    onPressed: () async {
                      await fb.auth().signOut();
                      _localStorage.remove("userID");
                      router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
                    },
                    padding: EdgeInsets.all(8),
                    color: Colors.red,
                    child: new Text("SIGN OUT", style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

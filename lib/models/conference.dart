import 'package:firebase/firebase.dart';

class Conference {
  String conferenceID = "";
  String fullName = "";
  String desc = "";
  String date = "";
  String imageUrl = "";
  String mapUrl = "";
  String hotelMapUrl = "";
  String eventsUrl = "";
  String alertsUrl = "";
  String siteUrl = "";
  String location = "";
  String address = "";
  bool past = false;

  Conference.plain();

  Conference.fromSnapshot(DataSnapshot snapshot)
      : conferenceID = snapshot.key,
        fullName = snapshot.val()["full"],
        desc = snapshot.val()["desc"],
        date = snapshot.val()["date"],
        imageUrl = snapshot.val()["imageUrl"],
        mapUrl = snapshot.val()["mapUrl"],
        hotelMapUrl = snapshot.val()["hotelMapUrl"],
        eventsUrl = snapshot.val()["eventsUrl"],
        siteUrl = snapshot.val()["siteUrl"],
        alertsUrl = snapshot.val()["alertsUrl"],
        location = snapshot.val()["location"],
        past = snapshot.val()["past"],
        address = snapshot.val()["address"];
}
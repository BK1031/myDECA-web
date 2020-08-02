import 'package:firebase/firebase.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mydeca_web/pages/auth/login_page.dart';
import 'package:mydeca_web/pages/auth/register_advisor_page.dart';
import 'package:mydeca_web/pages/auth/register_page.dart';
import 'package:mydeca_web/pages/conference/conference_details_page.dart';
import 'package:mydeca_web/pages/conference/conference_page.dart';
import 'package:mydeca_web/pages/event/events_page.dart';
import 'package:mydeca_web/pages/home/announcement/announcement_details_page.dart';
import 'package:mydeca_web/pages/home/announcement/announcements_page.dart';
import 'package:mydeca_web/pages/home/announcement/new_announcement_page.dart';
import 'package:mydeca_web/pages/home/home_page.dart';
import 'package:mydeca_web/pages/onboarding_page.dart';
import 'package:mydeca_web/utils/service_account.dart';
import 'package:mydeca_web/utils/theme.dart';
import 'utils/config.dart';

void main() {
  initializeApp(
      apiKey: ServiceAccount.apiKey,
      authDomain: ServiceAccount.authDomain,
      databaseURL: ServiceAccount.databaseUrl,
      projectId: ServiceAccount.projectID,
      storageBucket: ServiceAccount.storageUrl
  );

  // AUTH ROUTES
  router.define('/login', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new LoginPage();
  }));
  router.define('/register', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new RegisterPage();
  }));
  router.define('/register/advisor', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new RegisterAdvisorPage();
  }));

  // HOME ROUTES
  router.define('/', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new OnboardingPage();
  }));
  router.define('/home', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new HomePage();
  }));

  // ANNOUNCEMENT ROUTES
  router.define('/home/announcements', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new AnnouncementsPage();
  }));
  router.define('/home/announcements/details', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new AnnouncementDetailsPage();
  }));
  router.define('/home/announcements/new', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new NewAnnouncementPage();
  }));

  // CONFERENCES ROUTES
  router.define('/conferences', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new ConferencesPage();
  }));
  router.define('/conferences/details', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new ConferenceDetailsPage();
  }));


  // EVENTS ROUTES
  router.define('/events', handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new EventsPage();
  }));

  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: mainTheme,
    initialRoute: '/',
    onGenerateRoute: router.generator,
  ));
}
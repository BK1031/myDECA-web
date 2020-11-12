import 'package:fluro/fluro.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/user.dart';

import '../models/version.dart';

Version appVersion = new Version("1.7.8+1");
String appStatus = "";
String appFull = "Version ${appVersion.toString()}";

final router = new Router();

Map<String, List<String>> mockConferenceEvents = {
  "Business Administration Operations Written Event": ["BOR", "BMOR", "FOR"],
  "Hospitality/Sports Operations Written Event": ["HTOR", "SEOR"],
  "Entrepreneurship Written Event": ["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"],
  "Project Management Written Event": ["PMBS", "PMCD", "PMCA", "PMCG", "PMFL", "PMSP"],
  "Professional Selling Written Event": ["HTPS", "PSE", "FCE"],
  "Integrated Marketing Written Event": ["IMCS", "IMCE", "IMCP"],
  "Principles of Finance": ["PFN"],
  "Principles of Business Management and Administration": ["PBM"],
  "Principles of Hospitality and Tourism": ["PHT"],
  "Principles of Marketing": ["PMK"],
  "Retail Marketing Roleplay": ["AAM", "RMS", "BTDM"],
  "Business Law and Ethics Roleplay": ["BLTDM"],
  "Entrepreneurship Roleplay": ["ETDM", "ENT"],
  "Sports Entertainment Roleplay": ["SEM", "STDM"],
  "Human Resources Management Roleplay": ["HRM"],
  "Hospitality Services Roleplay": ["QSRM", "RFSM", "TTDM", "HTDM", "HLM"],
  "Financial Services Roleplay": ["ACT", "BFS", "PFL", "FTDM"],
  "Marketing Services Roleplay": ["BSM", "FMS", "MCS", "MTDM"]
};

Map<String, List<String>> roleplayPrompts = {
  "Principles of Finance": ["PFN"],
  "Principles of Business Management and Administration": ["PBM"],
  "Principles of Hospitality and Tourism": ["PHT"],
  "Principles of Marketing": ["PMK"],
  "Retail Marketing Roleplay": ["AAM", "RMS"],
  "Business Law and Ethics Roleplay": ["https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FBusiness%20Law%20and%20Ethics%20Roleplay.pdf?alt=media&token=2ad49d4a-5975-4ca6-b480-69a682e27c61", "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FBusiness%20Law%20and%20Ethics%20Roleplay%20Judge.pdf?alt=media&token=82121ea3-4f5b-437a-bee1-54e85011db03"],
  "Entrepreneurship Roleplay": ["ETDM", "ENT"],
  "Sports Entertainment Roleplay": ["SEM", "STDM"],
  "Human Resources Management Roleplay": ["HRM"],
  "Hospitality Services Roleplay": ["QSRM", "RFSM"],
  "Financial Services Roleplay": ["ACT", "BFS"],
  "Marketing Services Roleplay": ["BSM", "FMS"]
};

Map<String, List<String>> roleplayExams = {
  "Business Administration Core Exam": ["PFN", "PBM", "PHT", "PMK"],
  "Business Management Exam": ["BLTDM", "HRM"],
  "Entrepreneurship Exam": ["ETDM", "ENT"],
  "Finance Exam": ["ACT", "BFS", "FTDM"],
  "Hospitality + Tourism Exam": ["HTPS", "HTDM", "HLM", "QSRM", "RFSM", "TTDM"],
  "Marketing Exam": ["AAM", "ASM", "BSM", "BTDM", "FMS", "IMCE", "IMCP", "IMCS", "MCS", "MTDM", "PSE", "RMS", "SEM", "STDM"],
  "Personal Finance Literacy Exam": ["PFL"]
};

List<User> writtenTeam = new List();
List<User> roleplayTeam = new List();

String appLegal = """
MIT License
Copyright (c) 2020 Equinox Initiative
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
""";
import 'package:fluro/fluro.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/user.dart';

import '../models/version.dart';

Version appVersion = new Version("1.7.9+1");
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

Map<String, List<List<String>>> writtenRubrics = {
  "Business Administration Operations Written Event": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Hospitality/Sports Operations Written Event": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Entrepreneurship Written Event": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Project Management Written Event": [["Statement of the problem and project scope (0 - 10)", "Planning and Organizaiton (0 - 15)", "Description and documentation of the project plan implementation (0 - 10)", "Monitoring and Controlling (0 - 10)", "Evaluation of key metrics, lessons learned, recommendations for future projects (0 - 10)", "Appearance and Word Usage (0 - 5)"], ["Explain the project? (0 - 10)", "Apply project management tools to complete the project? (0 - 10)", "Evaluate project results? (0 - 10)", "Professional standards (organization, clarity and effectiveness of the presentation); effective use of visuals, appearance, poise, confidence, participation of all (0 - 10)"]],
  "Professional Selling Written Event": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Integrated Marketing Written Event": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
};

Map<String, List<List<String>>> roleplayRubrics = {
  "Principles of Finance": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Principles of Business Management and Administration": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Principles of Hospitality and Tourism": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Principles of Marketing": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Retail Marketing Roleplay": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Business Law and Ethics Roleplay": [["Explain the nature of business ethics? (0 - 10)", "Explain the concept of private enterprise? (0 - 10)", "Determine factors affecting business risk? (0 - 10)", "Identify factors affecting a business’s profit? (0 - 10)", "Explain reasons for ethical dilemmas? (0 - 10)", "Recognize and respond to ethical dilemmas? (0 - 10)", "Assess long-term value and impact of actions on others?  (0 - 10)"], ["Reason effectively and use systems thinking? (0 - 6)", "Make judgments and decisions, and solve problems? (0 - 6)", "Communicate clearly and show evidence of collaboration? (0 - 6)", "Show evidence of creativity? (0 - 6)", "Overall impression and responses to the judge’s questions (0 - 6)"]],
  "Entrepreneurship Roleplay": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Sports Entertainment Roleplay": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Human Resources Management Roleplay": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Hospitality Services Roleplay": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Financial Services Roleplay": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
  "Marketing Services Roleplay": [["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"]],
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
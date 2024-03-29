import 'package:fluro/fluro.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:mydeca_web/models/user.dart';

import '../models/version.dart';

Version appVersion = new Version("2.0.1+1");
String appStatus = "";
String appFull = "Version ${appVersion.toString()}";

final router = new FluroRouter();

Map<String, List<String>> mockConferenceEvents = {
  "Business Administration Operations Written Event": ["BOR", "BMOR", "FOR"],
  "Hospitality/Sports Operations Written Event": ["HTOR", "SEOR"],
  "Entrepreneurship Written Event": ["EIB", "IBP", "EIP", "ESB", "EFB", "EBG"],
  "Project Management Written Event": [
    "PMBS",
    "PMCD",
    "PMCA",
    "PMCG",
    "PMFL",
    "PMSP"
  ],
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
  "Principles of Finance": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FPrinciples%20of%20Finance.pdf?alt=media&token=ae3198a6-f38c-468f-90fa-d944535b1813",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FPrinciples%20of%20Finance%20Judge.pdf?alt=media&token=528ed658-6000-45d7-8725-f14500e4d595"
  ],
  "Principles of Business Management and Administration": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FPrinciples%20of%20Business%20Management%20and%20Administration.pdf?alt=media&token=a80de274-2132-499c-b5b5-4ae925ec3fe0",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FPrinciples%20of%20Business%20Management%20and%20Administration%20Judge.pdf?alt=media&token=2c7f7c67-1e06-4135-9971-4832c8a9f35b"
  ],
  "Principles of Hospitality and Tourism": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FPrinciples%20of%20Hospitality%20and%20Tourism.pdf?alt=media&token=ced13316-f7f0-4f95-8e12-c0ae8c245c58",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FPrinciples%20of%20Hospitality%20and%20Tourism%20Judge.pdf?alt=media&token=acde608b-2f78-4498-8eb2-bc75e0b984cf"
  ],
  "Principles of Marketing": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FPrinciples%20of%20Marketing.pdf?alt=media&token=e54cb17e-e50e-4036-a370-0638e18fd266",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FPrinciples%20of%20Marketing%20Judge.pdf?alt=media&token=36b01384-c330-4c8e-9260-e2ce9648d75c"
  ],
  "Retail Marketing Roleplay": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FRetail%20Marketing%20Roleplay.pdf?alt=media&token=e9ff4d10-837e-41f2-ad01-a1e238dee7c7",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FRetail%20Marketing%20Roleplay%20Judge.pdf?alt=media&token=4bd42f61-370a-47d1-ad92-ff1f516071be"
  ],
  "Business Law and Ethics Roleplay": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FBusiness%20Law%20and%20Ethics%20Roleplay.pdf?alt=media&token=2ad49d4a-5975-4ca6-b480-69a682e27c61",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FBusiness%20Law%20and%20Ethics%20Roleplay%20Judge.pdf?alt=media&token=82121ea3-4f5b-437a-bee1-54e85011db03"
  ],
  "Entrepreneurship Roleplay": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FEntrepreneurship%20Roleplay.pdf?alt=media&token=67d9ff12-353d-47ea-a04c-e700de91c3e2",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FEntrepreneurship%20Roleplay%20Judge.pdf?alt=media&token=59985c20-1445-4e64-b9a6-daaae9006fe2"
  ],
  "Sports Entertainment Roleplay": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FSports%20Entertainment%20Roleplay.pdf?alt=media&token=594c0697-f1a2-4a2c-ab7d-299938d42c69",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FSports%20Entertainment%20Roleplay%20Judge.pdf?alt=media&token=4f634111-82c4-4294-ba2e-029f667ac223"
  ],
  "Human Resources Management Roleplay": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FHuman%20Resources%20Management%20Roleplay.pdf?alt=media&token=48f1e1da-ae45-4ef0-85ea-be4d81de66d6",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FHuman%20Resources%20Management%20Roleplay%20Judge.pdf?alt=media&token=9591e72d-9917-4f61-9c49-e72330d1f288"
  ],
  "Hospitality Services Roleplay": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FHospitality%20Services%20Roleplay.pdf?alt=media&token=74b6a6c0-fb3e-4bf6-b46d-1005022c8313",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FHospitality%20Services%20Roleplay%20Judge.pdf?alt=media&token=695e1229-4848-490d-bfd3-04f95a8a1581"
  ],
  "Financial Services Roleplay": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FFinancial%20Services%20Roleplay.pdf?alt=media&token=32e8fb64-a502-473b-99a0-d54cda0ed6fc",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FFinancial%20Services%20Roleplay%20Judge.pdf?alt=media&token=4819a1c9-621f-4650-86cb-4d675cd743ff"
  ],
  "Marketing Services Roleplay": [
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FMarketing%20Services%20Roleplay.pdf?alt=media&token=d3d23bcf-c6e9-4296-8126-ce9e00fbef2c",
    "https://firebasestorage.googleapis.com/v0/b/mydeca-app.appspot.com/o/2020-VC-Mock%2Froleplays%2FMarketing%20Services%20Roleplay%20Judge.pdf?alt=media&token=186c4c33-ba80-45d8-bb2e-2492ae1d0b29"
  ]
};

Map<String, List<String>> roleplayExams = {
  "Business Administration Core Exam": ["PFN", "PBM", "PHT", "PMK"],
  "Business Management Exam": ["BLTDM", "HRM"],
  "Entrepreneurship Exam": ["ETDM", "ENT"],
  "Finance Exam": ["ACT", "BFS", "FTDM"],
  "Hospitality + Tourism Exam": ["HTPS", "HTDM", "HLM", "QSRM", "RFSM", "TTDM"],
  "Marketing Exam": [
    "AAM",
    "ASM",
    "BSM",
    "BTDM",
    "FMS",
    "IMCE",
    "IMCP",
    "IMCS",
    "MCS",
    "MTDM",
    "PSE",
    "RMS",
    "SEM",
    "STDM"
  ],
  "Personal Finance Literacy Exam": ["PFL"]
};

Map<String, List<List<String>>> writtenRubrics = {
  "Business Administration Operations Written Event": [
    [
      "Introductions/Overview (0 - 10)",
      "Problem and Research Methods Used in Study (0 - 10)",
      "Proposed Strategic Plan (0 - 10)",
      "Proposed Budget (0 - 10)",
      "Appearance (0 - 10)"
    ],
    [
      "Overall Presentation (0 - 10)",
      "Describe methods used to the design research study? (0 - 10)",
      "Describe strategies and approaches for leading change? (0 - 10)",
      "Describe the nature of budgets? (0 - 10)",
      "Professional standards (appearance, poise, confidence), presentation technique, effective use of visuals and participation of all (0 - 10)"
    ]
  ],
  "Hospitality/Sports Operations Written Event": [
    [
      "Introductions/Overview (0 - 10)",
      "Problem and Research Methods Used in Study (0 - 10)",
      "Proposed Strategic Plan (0 - 10)",
      "Proposed Budget (0 - 10)",
      "Appearance (0 - 10)"
    ],
    [
      "Overall Presentation (0 - 10)",
      "Describe methods used to the design research study? (0 - 10)",
      "Describe strategies and approaches for leading change? (0 - 10)",
      "Describe the nature of budgets? (0 - 10)",
      "Professional standards (appearance, poise, confidence), presentation technique, effective use of visuals and participation of all (0 - 10)"
    ]
  ],
  "Entrepreneurship Written Event": [
    [
      "Problem (0 - 10)",
      "Solution (0 - 10)",
      "Financials (0 - 10)",
      "Conclusion (0 - 10)",
      "Appearance (0 - 10)"
    ],
    [
      "Overall Presentation (0 - 10)",
      "Assess opportunities for venture creation (0 - 5)",
      "Determine feasibility of venture ideas (0 - 5)",
      "Describe market-entry strategies for conducting business internationally (0 - 5)",
      "Evaluate risk-taking opportunities (0 - 10)",
      "Describe marketing functions and related activities (0 - 5)",
      "Determine relationships among total revenue, marginal revenue, output and profit (0 - 5)"
    ]
  ],
  "Project Management Written Event": [
    [
      "Statement of the problem and project scope (0 - 10)",
      "Planning and Organizaiton (0 - 15)",
      "Description and documentation of the project plan implementation (0 - 10)",
      "Monitoring and Controlling (0 - 10)",
      "Evaluation of key metrics, lessons learned, recommendations for future projects (0 - 10)",
      "Appearance and Word Usage (0 - 5)"
    ],
    [
      "Explain the project? (0 - 10)",
      "Apply project management tools to complete the project? (0 - 10)",
      "Evaluate project results? (0 - 10)",
      "Professional standards (organization, clarity and effectiveness of the presentation); effective use of visuals, appearance, poise, confidence, participation of all (0 - 10)"
    ]
  ],
  "Professional Selling Written Event": [
    ["No written for this event (leave this blank)"],
    [
      "Presented an effective and engaging opening (0 - 7)",
      "Established relationship with customer/client (0 - 8)",
      "Communicated understanding of customer/client needs (0 - 8)",
      "Facilitated customer/client buying decisions (0 - 8)",
      "Recommended specific product(s)/service(s)/action(s) (0 - 8)",
      "Demonstrated or explained product(s)/service(s)/action(s) (0 - 8)",
      "Properly stated features and benefits of product(s)/service(s)/action(s) (0 - 7)",
      "Prescribed a solution(s) to meet customer/client needs (0 - 8)",
      "Effectively answered customer/client questions and concerns (0 - 8)",
      "Effectively closed the sale or ended the consultation (0 - 10)",
      "The presentation was well-organized and clearly presented; used professional grammar and vocabulary, words were enunciated and pronounced clearly, voice conveyed enthusiasm and volume was appropriate for the situation. (0 - 10)",
      "Professional appearance, poise and confidence (0 - 10)"
    ]
  ],
  "Integrated Marketing Written Event": [
    [
      "The description of the event, product or service, and business is clearly defined (0 - 12)",
      "Objectives are defined and referenced throughout the campaign (0 - 12)",
      "The written entry is well-organized, professional, and presented in a logical manner with unifying theme (0 - 6)"
    ],
    [
      "The campaign activities are realistic, show evidence of marketing knowledge, and are research based (0 - 12)",
      "Provides high-quality appropriate and creative samples of key marketing pieces suggested (0 - 12)",
      "Campaign schedule is cohesive with evidence of creativity/originality and plan is no more than 45 days long (0 - 12)",
      "The budget is realistic for the campaign and all costs that would be incurred have been considered (0 - 12)",
      "The target market is clearly analyzed (0 - 10)",
      "Key metrics are well thought out and appropriate for the campaign (0 - 6)",
      "Overall performance: professional appearance, poise, confidence, presentation technique, effective use of visuals, professionalism of participants, participation by each participant (0 - 6)"
    ]
  ],
};

Map<String, List<List<String>>> roleplayRubrics = {
  "Principles of Finance": [
    [
      "Explain the nature of effective verbal communications? (0 - 18)",
      "Explain communication techniques that support and encourage a speaker? (0 - 18)",
      "Interpret other's nonverbal cues? (0 - 18)",
      "Demonstrate active listening skills? (0 - 18)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 7)",
      "Communicate clearly? (0 - 7)",
      "Show evidence of creativity? (0 - 7)",
      "Overall impression and responses to the judge's questions? (0 - 7)"
    ]
  ],
  "Principles of Business Management and Administration": [
    [
      "Explain the nature of effective verbal communications? (0 - 18)",
      "Explain the nature of effective written communications? (0 - 18)",
      "Employ communication strategies appropriate to target audience? (0 - 18)",
      "Defend ideas objectively? (0 - 18)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 7)",
      "Communicate clearly? (0 - 7)",
      "Show evidence of creativity? (0 - 7)",
      "Overall impression and responses to the judge's questions? (0 - 7)"
    ]
  ],
  "Principles of Hospitality and Tourism": [
    [
      "Explain the nature of effective verbal communications? (0 - 18)",
      "Explain the nature of effective written communications? (0 - 18)",
      "Distinguish between using social media for business and personal purposes? (0 - 18)",
      "Employ communication styles appropriate to target audiences? (0 - 18)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 7)",
      "Communicate clearly? (0 - 7)",
      "Show evidence of creativity? (0 - 7)",
      "Overall impression and responses to the judge's questions? (0 - 7)"
    ]
  ],
  "Principles of Marketing": [
    [
      "Explain the nature of effective written communications? (0 - 18)",
      "Explain how digital communications exposes business to risk? (0 - 18)",
      "Dinstinguish between using social media for business and personal purposes? (0 - 18)",
      "Select and utilize appropriate formats for professional writing? (0 - 18)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 7)",
      "Communicate clearly? (0 - 7)",
      "Show evidence of creativity? (0 - 7)",
      "Overall impression and responses to the judge's questions? (0 - 7)"
    ]
  ],
  "Retail Marketing Roleplay": [
    [
      "Distinguish between retailing and marketing? (0 - 14)",
      "Describe marketing functions and related activities? (0 - 14)",
      "Explain factors that influence customer/client/business buying behavior? (0 - 14)",
      "Explain the concept of marketing strategies? (0 - 14)",
      "Explain the role of promotion as a marketing function? (0 - 14)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 6)",
      "Make judgments and decisions, and solve problems? (0 - 6)",
      "Communicate clearly? (0 - 6)",
      "Show evidence of creativity? (0 - 6)",
      "Overall impression and responses to the judge's questions (0 - 6)"
    ]
  ],
  "Business Law and Ethics Roleplay": [
    [
      "Explain the nature of business ethics? (0 - 10)",
      "Explain the concept of private enterprise? (0 - 10)",
      "Determine factors affecting business risk? (0 - 10)",
      "Identify factors affecting a business’s profit? (0 - 10)",
      "Explain reasons for ethical dilemmas? (0 - 10)",
      "Recognize and respond to ethical dilemmas? (0 - 10)",
      "Assess long-term value and impact of actions on others?  (0 - 10)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 6)",
      "Make judgments and decisions, and solve problems? (0 - 6)",
      "Communicate clearly and show evidence of collaboration? (0 - 6)",
      "Show evidence of creativity? (0 - 6)",
      "Overall impression and responses to the judge’s questions (0 - 6)"
    ]
  ],
  "Entrepreneurship Roleplay": [
    [
      "Describe the nature of entrepreneurship? (0 - 14)",
      "Describe processes used to scquire adequate financial resources for eventure creation/start-up? (0 - 14)",
      "Select sources to finance venture creation/start-up? (0 - 14)",
      "Describe considerations in selecting capital resources? (0 - 14)",
      "Assess the costs/benefits asscoiated with resources? (0 - 14)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 6)",
      "Make judgments and decisions, and solve problems? (0 - 6)",
      "Communicate clearly? (0 - 6)",
      "Show evidence of creativity? (0 - 6)",
      "Overall impression and responses to the judge's questions (0 - 6)"
    ]
  ],
  "Sports Entertainment Roleplay": [
    [
      "Explain the nature and scope of the product/service management function? (0 - 14)",
      "Generate product ideas? (0 - 14)",
      "Explain the concept of product mix? (0 - 14)",
      "Develop poisitioning concept for a new product idea? (0 - 14)",
      "Explain the concept of market and market identification? (0 - 14)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 6)",
      "Make judgments and decisions, and solve problems? (0 - 6)",
      "Communicate clearly? (0 - 6)",
      "Show evidence of creativity? (0 - 6)",
      "Overall impression and responses to the judge's questions (0 - 6)"
    ]
  ],
  "Human Resources Management Roleplay": [
    [
      "Maintain confidentiality in dealing with personnel? (0 - 14)",
      "Explain the nature of staff communication? (0 - 14)",
      "Choose and use appropriate channnel for workplace communication? (0 - 14)",
      "Explain the nature of effective written communications? (0 - 14)",
      "Explain the nature of effective verbal communications? (0 - 14)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 6)",
      "Make judgments and decisions, and solve problems? (0 - 6)",
      "Communicate clearly? (0 - 6)",
      "Show evidence of creativity? (0 - 6)",
      "Overall impression and responses to the judge's questions (0 - 6)"
    ]
  ],
  "Hospitality Services Roleplay": [
    [
      "Explain the nature of staff communication? (0 - 14)",
      "Choose and use appropriate channel for workplace communication? (0 - 14)",
      "Employ communication styles appropriate to target audience? (0 - 14)",
      "Reinforce service orientation through communication? (0 - 14)",
      "Illustrate correct food handling and production techniques? (0 - 14)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 6)",
      "Make judgments and decisions, and solve problems? (0 - 6)",
      "Communicate clearly? (0 - 6)",
      "Show evidence of creativity? (0 - 6)",
      "Overall impression and responses to the judge's questions (0 - 6)"
    ]
  ],
  "Financial Services Roleplay": [
    [
      "Explain the concept of accounting? (0 - 14)",
      "Demonstrate the effects of transactions on the accounting equation? (0 - 14)",
      "Describe the nature of income statements? (0 - 14)",
      "Describe the nature of balance sheets? (0 - 14)",
      "Describe the nature of cash flow statements? (0 - 14)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 6)",
      "Make judgments and decisions, and solve problems? (0 - 6)",
      "Communicate clearly? (0 - 6)",
      "Show evidence of creativity? (0 - 6)",
      "Overall impression and responses to the judge's questions (0 - 6)"
    ]
  ],
  "Marketing Services Roleplay": [
    [
      "Describe marketing functions and related activities? (0 - 14)",
      "Explain factors that influence customer/client/business buying behavior? (0 - 14)",
      "Discuss actions employees can take to achieve the company's desired results? (0 - 14)",
      "Explain how businesses can use trade-show/exposition participation to communicate with targeted audiences? (0 - 14)",
      "Participate in the design of collateral materials to promote special event? (0 - 14)"
    ],
    [
      "Reason effectively and use systems thinking? (0 - 6)",
      "Make judgments and decisions, and solve problems? (0 - 6)",
      "Communicate clearly? (0 - 6)",
      "Show evidence of creativity? (0 - 6)",
      "Overall impression and responses to the judge's questions (0 - 6)"
    ]
  ]
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

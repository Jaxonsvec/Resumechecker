import 'resume_analysis.dart';

class ResumeExample {
  const ResumeExample({
    required this.id,
    required this.title,
    required this.field,
    required this.level,
    required this.text,
    required this.whyItWorks,
    required this.categoryScores,
  });
  final String id, title, field, level, text, whyItWorks;
  final Map<String, ResumeCategoryScore> categoryScores;
  int get overallScore =>
      (categoryScores.values.fold<int>(0, (sum, item) => sum + item.score) /
              categoryScores.length)
          .round();
}

ResumeCategoryScore _s(int score, String why) =>
    ResumeCategoryScore(score: score, explanation: why);

final resumeExamples = <ResumeExample>[
  ResumeExample(
    id: 'graduate',
    title: 'Recent Graduate',
    field: 'Business',
    level: 'Entry level',
    text: 'Avery Morgan | Fictional Demonstration\nAustin, TX | avery.morgan@example.test\n\nSUMMARY\nRecent business graduate interested in operations and customer experience. Experienced with spreadsheet analysis, clear documentation, and coordinating student projects.\n\nSKILLS\nExcel, Google Sheets, customer service, process documentation, presentation design\n\nPROJECTS\nCampus Service Improvement | Student project | 2025\n- Interviewed 18 fictional student participants and grouped feedback into four service themes.\n- Built a sample spreadsheet dashboard to track response time and common requests.\n- Presented three low-cost process changes to a class panel.\n\nEXPERIENCE\nStudent Assistant | Fictional Campus Office | 2024–2025\n- Organized appointment records and prepared weekly status summaries for a 5-person office team.\n- Wrote a step-by-step intake guide used to onboard two fictional student assistants.\n\nEDUCATION\nB.B.A. Business Administration | Fictional State College | 2025',
    whyItWorks: 'Relevant projects and early experience are prominent, with concrete fictional scope and no overstated experience.',
    categoryScores: {
      'clarity': _s(84, 'Sections and sentences are easy to scan.'),
      'impact': _s(80, 'Project contributions are direct.'),
      'measurable_results': _s(78, 'Uses truthful-to-example project scope.'),
      'skills_experience': _s(82, 'Skills connect to evidence.'),
      'formatting_organization': _s(86, 'Conventional readable section order.'),
    },
  ),
  ResumeExample(
    id: 'software',
    title: 'Software Engineer',
    field: 'Software engineering',
    level: 'Early career',
    text: 'Riley Chen | Fictional Demonstration\nSeattle, WA | riley.chen@example.test\n\nSUMMARY\nSoftware engineer focused on backend services and developer tooling. Builds maintainable APIs, automates workflows, and collaborates across product and engineering.\n\nSKILLS\nTypeScript, Java, SQL, REST APIs, PostgreSQL, Docker, automated testing\n\nEXPERIENCE\nSoftware Engineer | Fictional Northstar Studio | 2023–Present\n- Built a job queue service processing 40,000 fictional test events per day in a load test.\n- Added integration tests for 22 API routes and documented local setup for new teammates.\n- Worked with design and support to clarify failure states in an internal dashboard.\n\nPROJECT\nTransit Planner | Personal project | 2022\n- Created a Java application that imports sample schedule data and flags conflicting connections.\n- Added input validation and unit tests for parsing edge cases.\n\nEDUCATION\nB.S. Computer Science | Fictional Cascadia University | 2022',
    whyItWorks: 'Technical skills are supported by concrete projects, and test scale is explicitly fictional example content.',
    categoryScores: {
      'clarity': _s(88, 'Concise verbs and clear technical nouns.'),
      'impact': _s(86, 'Ownership and collaboration are visible.'),
      'measurable_results': _s(84, 'Test scale is given with context.'),
      'skills_experience': _s(90, 'Relevant skills have evidence.'),
      'formatting_organization': _s(88, 'Sections support quick scanning.'),
    },
  ),
  ResumeExample(
    id: 'business',
    title: 'Business Operations',
    field: 'Business administration',
    level: 'Mid career',
    text: 'Samira Patel | Fictional Demonstration\nChicago, IL | samira.patel@example.test\n\nSUMMARY\nOperations coordinator experienced in scheduling, vendor communication, and reporting workflows in fictional service organizations.\n\nSKILLS\nProcess mapping, Excel, vendor coordination, budget tracking, SOP writing, stakeholder communication\n\nEXPERIENCE\nOperations Coordinator | Fictional Harbor Services | 2021–Present\n- Standardized monthly purchasing reports across 3 fictional departments using a shared template.\n- Coordinated 12 recurring vendors and maintained a renewal calendar for department leads.\n- Documented an invoice review workflow that reduced duplicate follow-up in a fictional pilot.\n\nOffice Administrator | Fictional Pine Collective | 2018–2021\n- Scheduled meetings and maintained onboarding materials for a 24-person office.\n- Reconciled expenses and routed exceptions to the finance contact.\n\nEDUCATION\nB.A. Communications | Fictional Lakeside College | 2018',
    whyItWorks: 'The summary establishes focus while bullets distinguish responsibilities from process improvements.',
    categoryScores: {
      'clarity': _s(86, 'Bullets use direct language.'),
      'impact': _s(83, 'Ownership is clear; outcomes could be stronger.'),
      'measurable_results': _s(
        80,
        'Uses scope counts without invented impact.',
      ),
      'skills_experience': _s(88, 'Skills align with listed roles.'),
      'formatting_organization': _s(87, 'Consistent reverse chronology.'),
    },
  ),
  ResumeExample(
    id: 'healthcare',
    title: 'Healthcare Support',
    field: 'Healthcare',
    level: 'Early career',
    text: 'Taylor Brooks | Fictional Demonstration\nDenver, CO | taylor.brooks@example.test\n\nSUMMARY\nPatient services coordinator experienced in appointment scheduling, accurate records handling, and helping patients navigate clinic procedures. No clinical credentials are claimed.\n\nSKILLS\nScheduling, patient communication, records accuracy, referral coordination, privacy procedures\n\nEXPERIENCE\nPatient Services Representative | Fictional Meadow Clinic | 2022–Present\n- Scheduled appointments across 3 fictional provider calendars and confirmed preparation instructions.\n- Routed referral documents to the appropriate fictional care team using clinic procedures.\n- Updated contact and appointment records and escalated inconsistencies for review.\n\nVOLUNTEER EXPERIENCE\nCommunity Health Fair Volunteer | Fictional Neighborhood Event | 2021\n- Directed visitors to registration stations and shared printed service information.\n\nEDUCATION\nA.A. Health Administration | Fictional Front Range College | 2022',
    whyItWorks: 'Administrative healthcare support is described precisely without implying licenses or clinical duties.',
    categoryScores: {
      'clarity': _s(88, 'Responsibilities are specific and readable.'),
      'impact': _s(78, 'Scope is clear, with limited outcomes.'),
      'measurable_results': _s(
        74,
        'Provides scope without invented care outcomes.',
      ),
      'skills_experience': _s(86, 'Role skills have direct examples.'),
      'formatting_organization': _s(
        87,
        'Clear sections and credential framing.',
      ),
    },
  ),
  ResumeExample(
    id: 'manager',
    title: 'Experienced Program Manager',
    field: 'Program management',
    level: 'Senior',
    text: 'Jordan Ellis | Fictional Demonstration\nPortland, OR | jordan.ellis@example.test\n\nSUMMARY\nProgram manager experienced in coordinating launches, planning budgets, and building operating rhythms for fictional teams.\n\nSKILLS\nProgram planning, risk management, budget tracking, facilitation, vendor coordination, executive updates\n\nEXPERIENCE\nSenior Program Manager | Fictional Juniper Works | 2019–Present\n- Coordinated a fictional 6-team service launch, maintaining milestones, owners, and risks.\n- Managed a sample \$1.2M annual operating plan and prepared monthly variance notes.\n- Introduced a decision log and weekly agenda adopted by 4 fictional program teams.\n\nProgram Coordinator | Fictional Fieldstone Group | 2015–2019\n- Tracked dependencies for 8 concurrent projects and escalated schedule risks.\n- Prepared status reports for internal and vendor stakeholders.\n\nEDUCATION\nM.P.A. | Fictional Northwest Institute | 2015\nB.A. Sociology | Fictional Northwest Institute | 2013',
    whyItWorks: 'Demonstrates scope, decisions, and cross-team work; all names, organizations, and metrics are fictional.',
    categoryScores: {
      'clarity': _s(87, 'Sections and ownership are clear.'),
      'impact': _s(90, 'Cross-functional scope is explicit.'),
      'measurable_results': _s(86, 'Budget and counts have context.'),
      'skills_experience': _s(90, 'Skills have evidence across roles.'),
      'formatting_organization': _s(88, 'Consistent reverse chronology.'),
    },
  ),
];

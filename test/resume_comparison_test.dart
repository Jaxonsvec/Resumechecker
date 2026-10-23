import 'package:airesume/models/resume_analysis.dart';
import 'package:airesume/models/resume_example.dart';
import 'package:airesume/screens/resume_comparison_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('compares rubric categories and gives a path to the editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: ResumeComparisonScreen(userAnalysis: _analysis())),
    );
    await tester.tap(find.byType(DropdownButtonFormField<ResumeExample>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Software Engineer (Early career)').last);
    await tester.pumpAndSettle();
    expect(find.text('Overall scores'), findsOneWidget);
    expect(find.text('87/100'), findsOneWidget);
    expect(find.textContaining('Example: 88'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Team leadership is present.'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('Team leadership is present.'), findsOneWidget);
    await tester.ensureVisible(find.text('Open editor and improve resume'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open editor and improve resume'));
    await tester.pumpAndSettle();
    expect(find.text('Working resume text'), findsOneWidget);
  });
}

ResumeAnalysis _analysis() => ResumeAnalysis(
  overallScore: 80,
  categoryScores: {
    for (final key in const [
      'clarity',
      'impact',
      'measurable_results',
      'skills_experience',
      'formatting_organization',
    ])
      key: const ResumeCategoryScore(
        score: 80,
        explanation: 'Evidence supports this category score.',
      ),
  },
  summary: 'A focused resume.',
  strengths: const [
    ResumeStrength(
      title: 'Leadership',
      evidence: 'Team leadership is present.',
    ),
  ],
  improvements: const [
    ResumeImprovement(
      title: 'Clarify outcomes',
      evidence: 'No results shown.',
      recommendation: 'Add a truthful result if available.',
    ),
  ],
  missingInformation: const [],
  suggestedRewrites: const [],
  jobRelevance: null,
  sourceResumeText: 'Casey Example\nExperience: Led a team.',
);

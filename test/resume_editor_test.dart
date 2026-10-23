import 'dart:typed_data';

import 'package:airesume/models/resume_analysis.dart';
import 'package:airesume/screens/resume_editor_screen.dart';
import 'package:airesume/screens/analysis_results_screen.dart';
import 'package:airesume/services/resume_analysis_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'accepts a factual rewrite and sends the revised text for regrade',
    (tester) async {
      final api = _FakeApi();
      await tester.pumpWidget(
        MaterialApp(
          home: ResumeEditorScreen(initialAnalysis: _analysis(), api: api),
        ),
      );
      await tester.ensureVisible(find.text('Accept').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Accept').first);
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byType(TextField).first);
      expect(field.controller!.text, contains('Led a four-person team.'));
      expect(field.controller!.text, contains('Unchanged section stays here.'));

      await tester.ensureVisible(find.text('Regrade Resume'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Regrade Resume'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send and regrade'));
      await tester.pumpAndSettle();
      expect(api.submittedText, contains('Led a four-person team.'));
      expect(api.submittedText, contains('Unchanged section stays here.'));
      expect(
        find.textContaining('Previous 80/100 → Current 82/100'),
        findsOneWidget,
      );
    },
  );

  testWidgets('lets the user reject a rewrite suggestion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResumeEditorScreen(initialAnalysis: _analysis(), api: _FakeApi()),
      ),
    );
    await tester.ensureVisible(find.text('Reject').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reject').first);
    await tester.pump();
    expect(find.text('Rejected'), findsOneWidget);
  });

  testWidgets(
    'keeps a manual working revision while moving between results and editor',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnalysisResultsScreen(
            result: _analysis(),
            resumeName: 'Resume.pdf',
          ),
        ),
      );
      await tester.scrollUntilVisible(
        find.text('Edit Resume'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Resume'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'Manual working revision',
      );
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Edit Resume'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Resume'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Manual working revision',
      );
    },
  );
}

ResumeAnalysis _analysis({
  String source = 'Led a team of four.\nUnchanged section stays here.',
  int overall = 80,
}) => ResumeAnalysis(
  overallScore: overall,
  categoryScores: {
    for (final key in const [
      'clarity',
      'impact',
      'measurable_results',
      'skills_experience',
      'formatting_organization',
    ])
      key: ResumeCategoryScore(
        score: overall,
        explanation: 'Evidence-based score.',
      ),
  },
  summary: 'A concise assessment.',
  strengths: const [],
  improvements: const [],
  missingInformation: const [],
  jobRelevance: null,
  sourceResumeText: source,
  suggestedRewrites: const [
    ResumeRewrite(
      section: 'Experience',
      originalText: 'Led a team of four.',
      revisedText: 'Led a four-person team.',
      rationale: 'Clearer wording preserves the supplied fact.',
    ),
  ],
);

class _FakeApi implements ResumeAnalysisApi {
  String? submittedText;
  @override
  Future<ResumeAnalysis> analyzeText({
    required String resumeText,
    String? targetRole,
  }) async {
    submittedText = resumeText;
    return _analysis(source: resumeText, overall: 82);
  }

  @override
  Future<ResumeAnalysis> analyze({
    required String fileName,
    required Future<Uint8List> Function() readBytes,
    String? targetRole,
  }) => throw UnimplementedError();
}

import 'package:airesume/models/resume_example.dart';
import 'package:airesume/screens/resume_examples_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('example library contains five fictional, rubric-scored resumes', () {
    expect(resumeExamples, hasLength(5));
    expect(resumeExamples.map((item) => item.id).toSet(), hasLength(5));
    for (final example in resumeExamples) {
      expect(example.text, contains('Fictional Demonstration'));
      expect(example.categoryScores, hasLength(5));
      expect(example.overallScore, inInclusiveRange(0, 100));
      expect(
        example.overallScore,
        (example.categoryScores.values.fold<int>(
                  0,
                  (sum, item) => sum + item.score,
                ) /
                5)
            .round(),
      );
      for (final score in example.categoryScores.values) {
        expect(score.score, inInclusiveRange(0, 100));
      }
    }
  });

  testWidgets('examples screen exposes all five sample resumes', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ResumeExamplesScreen()));
    for (final example in resumeExamples) {
      await tester.ensureVisible(find.text(example.title));
      expect(find.text(example.title), findsOneWidget);
    }
  });
}

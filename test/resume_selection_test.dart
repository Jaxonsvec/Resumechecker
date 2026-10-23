import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airesume/models/picked_resume.dart';
import 'package:airesume/models/resume_analysis.dart';
import 'package:airesume/screens/resume_selection_screen.dart';
import 'package:airesume/services/resume_analysis_api.dart';
import 'package:airesume/services/resume_file_picker.dart';

void main() {
  group('ResumeFileValidator', () {
    test('accepts PDF and DOCX names without regard to extension case', () {
      expect(
        ResumeFileValidator.validate(fileName: 'Resume.PDF', sizeBytes: 2048),
        isNull,
      );
      expect(
        ResumeFileValidator.validate(fileName: 'Resume.DoCx', sizeBytes: 1),
        isNull,
      );
    });

    test('accepts the 10 MiB limit and rejects larger files', () {
      expect(
        ResumeFileValidator.validate(
          fileName: 'Resume.pdf',
          sizeBytes: ResumeFileValidator.maxSizeBytes,
        ),
        isNull,
      );
      expect(
        ResumeFileValidator.validate(
          fileName: 'Resume.pdf',
          sizeBytes: ResumeFileValidator.maxSizeBytes + 1,
        ),
        ResumeFileValidationError.fileTooLarge,
      );
    });

    test('rejects unsupported, empty, and unmeasurable files', () {
      expect(
        ResumeFileValidator.validate(fileName: 'resume.txt', sizeBytes: 10),
        ResumeFileValidationError.unsupportedType,
      );
      expect(
        ResumeFileValidator.validate(fileName: 'resume', sizeBytes: 10),
        ResumeFileValidationError.unsupportedType,
      );
      expect(
        ResumeFileValidator.validate(fileName: 'resume.pdf', sizeBytes: 0),
        ResumeFileValidationError.emptyFile,
      );
      expect(
        ResumeFileValidator.validate(fileName: 'resume.pdf', sizeBytes: null),
        ResumeFileValidationError.sizeUnavailable,
      );
      expect(
        ResumeFileValidator.validate(fileName: 'resume.pdf', sizeBytes: -1),
        ResumeFileValidationError.sizeUnavailable,
      );
    });
  });

  testWidgets('selects, displays, replaces, and removes a resume', (
    tester,
  ) async {
    final picker = _FakeResumeFilePicker([
      _resume('First Resume.pdf', 2048),
      _resume('Updated CV.docx', 1024 * 1024),
    ]);
    await _pumpSelectionScreen(tester, picker);

    await _tap(tester, 'Choose a resume');
    expect(find.text('First Resume.pdf'), findsOneWidget);
    expect(find.text('PDF · 2.0 KiB'), findsOneWidget);

    await _tap(tester, 'Replace resume');
    expect(find.text('Updated CV.docx'), findsOneWidget);
    expect(find.text('DOCX · 1.0 MiB'), findsOneWidget);

    await _tap(tester, 'Remove resume');
    expect(find.text('No resume selected'), findsOneWidget);
    expect(find.text('Updated CV.docx'), findsNothing);
  });

  testWidgets('rejects invalid replacement and keeps the prior resume', (
    tester,
  ) async {
    final picker = _FakeResumeFilePicker([
      _resume('Good resume.pdf', 2048),
      _resume('notes.txt', 512),
    ]);
    await _pumpSelectionScreen(tester, picker);

    await _tap(tester, 'Choose a resume');
    await _tap(tester, 'Replace resume');

    expect(find.text('Good resume.pdf'), findsOneWidget);
    expect(find.textContaining('Choose a PDF or DOCX file.'), findsOneWidget);
  });

  testWidgets('canceling the picker preserves the current selection', (
    tester,
  ) async {
    final picker = _FakeResumeFilePicker([_resume('Resume.pdf', 1024), null]);
    await _pumpSelectionScreen(tester, picker);

    await _tap(tester, 'Choose a resume');
    await _tap(tester, 'Replace resume');

    expect(find.text('Resume.pdf'), findsOneWidget);
    expect(find.byKey(const ValueKey('resume-selection-error')), findsNothing);
  });

  testWidgets('reports file chooser access errors without exposing details', (
    tester,
  ) async {
    final picker = _FakeResumeFilePicker([
      PlatformException(code: 'denied', message: 'private local path'),
    ]);
    await _pumpSelectionScreen(tester, picker);

    await _tap(tester, 'Choose a resume');

    expect(find.textContaining('Check device access'), findsOneWidget);
    expect(find.textContaining('private local path'), findsNothing);
  });

  testWidgets('rejects files larger than 10 MiB', (tester) async {
    final picker = _FakeResumeFilePicker([
      _resume('Large resume.pdf', ResumeFileValidator.maxSizeBytes + 1),
    ]);
    await _pumpSelectionScreen(tester, picker);

    await _tap(tester, 'Choose a resume');

    expect(find.text('No resume selected'), findsOneWidget);
    expect(find.textContaining('exceeds the 10 MiB limit'), findsOneWidget);
  });

  testWidgets('requires processing consent and shows real analysis results', (
    tester,
  ) async {
    final result = ResumeAnalysis(
      overallScore: 80,
      categoryScores: {
        for (final key in [
          'clarity',
          'impact',
          'measurable_results',
          'skills_experience',
          'formatting_organization',
        ])
          key: const ResumeCategoryScore(
            score: 80,
            explanation: 'Clear and supported.',
          ),
      },
      summary: 'A focused resume with relevant experience.',
      strengths: const [
        ResumeStrength(title: 'Leadership', evidence: 'Led a team of four.'),
      ],
      improvements: const [
        ResumeImprovement(
          title: 'Show measurable impact',
          evidence: 'The role lists responsibilities without outcomes.',
          recommendation: 'Add a truthful result or scale where available.',
        ),
      ],
      missingInformation: const ['Education details'],
      suggestedRewrites: const [],
      jobRelevance: null,
    );
    final api = _FakeResumeAnalysisApi([
      const ResumeAnalysisException('The analysis server is unavailable.'),
      result,
    ]);
    await _pumpSelectionScreen(
      tester,
      _FakeResumeFilePicker([_resume('Resume.pdf', 2048)]),
      analysisApi: api,
    );

    await _tap(tester, 'Choose a resume');
    await tester.drag(find.byType(ListView).last, const Offset(0, -560));
    await tester.pumpAndSettle();
    expect(find.text('Analyze resume'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('analysis-consent')));
    await tester.tap(find.byKey(const ValueKey('analysis-consent')));
    await tester.enterText(find.byType(TextField), 'Product engineer');
    await tester.pumpAndSettle();
    await _tap(tester, 'Analyze resume');
    expect(find.text('The analysis server is unavailable.'), findsOneWidget);
    await _tap(tester, 'Try again');
    expect(find.text('Your feedback is ready'), findsOneWidget);
    await _tap(tester, 'View resume feedback');

    expect(find.text('Resume feedback'), findsOneWidget);
    expect(
      find.text('A focused resume with relevant experience.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.textContaining('Led a team of four.'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('Led a team of four.'), findsOneWidget);
    expect(
      find.textContaining('Add a truthful result or scale where available.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Education details'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Education details'), findsOneWidget);
    expect(api.fileNames, ['Resume.pdf', 'Resume.pdf']);
    expect(api.targetRoles, ['Product engineer', 'Product engineer']);
  });
}

Future<void> _pumpSelectionScreen(
  WidgetTester tester,
  ResumeFilePicker picker, {
  ResumeAnalysisApi? analysisApi,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ResumeSelectionScreen(picker: picker, analysisApi: analysisApi),
    ),
  );
}

Future<void> _tap(WidgetTester tester, String label) async {
  final text = find.text(label);
  await tester.ensureVisible(text);
  await tester.drag(find.byType(ListView).last, const Offset(0, 96));
  await tester.pumpAndSettle();
  final button = find.ancestor(
    of: text,
    matching: find.byWidgetPredicate(
      (widget) => widget is ButtonStyleButton || widget is TextButton,
    ),
  );
  await tester.tap(button.evaluate().isEmpty ? text : button.first);
  await tester.pumpAndSettle();
}

PickedResume _resume(String name, int sizeBytes) =>
    PickedResume(name: name, sizeBytes: sizeBytes);

class _FakeResumeFilePicker implements ResumeFilePicker {
  _FakeResumeFilePicker(Iterable<Object?> responses)
    : _responses = Queue<Object?>.of(responses);

  final Queue<Object?> _responses;

  @override
  Future<PickedResume?> pickResume() async {
    final response = _responses.removeFirst();
    if (response is Exception) throw response;
    return response as PickedResume?;
  }
}

class _FakeResumeAnalysisApi implements ResumeAnalysisApi {
  _FakeResumeAnalysisApi(Iterable<Object> responses)
    : _responses = Queue<Object>.of(responses);

  final Queue<Object> _responses;
  final List<String> fileNames = [];
  final List<String?> targetRoles = [];

  @override
  Future<ResumeAnalysis> analyze({
    required String fileName,
    required Future<Uint8List> Function() readBytes,
    String? targetRole,
  }) async {
    fileNames.add(fileName);
    targetRoles.add(targetRole);
    final response = _responses.removeFirst();
    if (response is Exception) throw response;
    return response as ResumeAnalysis;
  }

  @override
  Future<ResumeAnalysis> analyzeText({
    required String resumeText,
    String? targetRole,
  }) async => throw UnimplementedError();
}

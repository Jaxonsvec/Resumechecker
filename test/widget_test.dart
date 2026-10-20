import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airesume/main.dart';
import 'package:airesume/resume_input.dart';

void main() {
  test('validates extensions and size boundaries', () {
    for (final name in ['resume.pdf', 'resume.DOCX']) {
      expect(
        ResumeFile(name: name, size: maxResumeBytes).validationError,
        isNull,
      );
    }
    for (final file in [
      const ResumeFile(name: 'resume.txt', size: 100),
      const ResumeFile(name: 'pdf', size: 100),
      const ResumeFile(name: 'resume.pdf', size: 0),
      const ResumeFile(name: 'resume.pdf', size: -1),
      const ResumeFile(name: 'resume.docx', size: maxResumeBytes + 1),
    ]) {
      expect(file.validationError, isNotNull);
    }
  });

  testWidgets('home shows resume entry and local-only explanation', (
    tester,
  ) async {
    await tester.pumpWidget(const AiresumeApp());
    expect(find.text('Add your resume'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Choose a resume'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(
      find.textContaining('Upload and analysis are not available'),
      findsOneWidget,
    );
  });

  testWidgets('select, cancel, reject, retry, replace and remove', (
    tester,
  ) async {
    ResumeFile? next = const ResumeFile(name: 'first.pdf', size: 1024);
    var fail = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResumeInput(
            picker: () async {
              if (fail) throw StateError('private error');
              return next;
            },
          ),
        ),
      ),
    );
    Future<void> choose(String label) async {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    await choose('Choose a resume');
    expect(find.text('first.pdf'), findsOneWidget);
    expect(find.text('PDF · 1.0 KiB'), findsOneWidget);
    next = null;
    await choose('Replace resume');
    expect(find.text('first.pdf'), findsOneWidget);
    next = const ResumeFile(name: 'invalid.exe', size: 10);
    await choose('Replace resume');
    expect(find.text('Choose a PDF or DOCX file.'), findsOneWidget);
    expect(find.text('first.pdf'), findsOneWidget);
    fail = true;
    await choose('Replace resume');
    expect(find.textContaining('Could not access'), findsOneWidget);
    expect(find.textContaining('private error'), findsNothing);
    fail = false;
    next = const ResumeFile(name: 'replacement.docx', size: 2048);
    await choose('Replace resume');
    expect(find.text('replacement.docx'), findsOneWidget);
    expect(find.text('first.pdf'), findsNothing);
    await choose('Remove resume');
    expect(find.text('replacement.docx'), findsNothing);
    expect(find.text('Choose a resume'), findsOneWidget);
  });

  testWidgets('prevents duplicate picks and tolerates disposal', (
    tester,
  ) async {
    final pending = Completer<ResumeFile?>();
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ResumeInput(
          picker: () {
            calls++;
            return pending.future;
          },
        ),
      ),
    );
    await tester.tap(find.text('Choose a resume'));
    await tester.pump();
    expect(find.text('Opening files…'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(calls, 1);
    await tester.pumpWidget(const SizedBox());
    pending.complete(const ResumeFile(name: 'resume.pdf', size: 1));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

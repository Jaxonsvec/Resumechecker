import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airesume/main.dart';
import 'package:airesume/widgets/feedback_state.dart';

void main() {
  testWidgets('home opens the connected resume-selection flow', (tester) async {
    await tester.pumpWidget(const AiresumeApp());

    expect(find.text('Make your next move\nwith confidence.'), findsOneWidget);
    expect(find.text('Tell us about your next role'), findsOneWidget);
    await _scrollHomeTo(tester, 'Choose a resume');
    await tester.tap(find.text('Choose a resume'));
    await tester.pumpAndSettle();

    expect(find.text('Your resume'), findsOneWidget);
    expect(find.text('Start with your resume'), findsOneWidget);
    expect(find.text('No resume selected'), findsOneWidget);
  });

  testWidgets('home keeps paste and local file selection entry points', (
    tester,
  ) async {
    await tester.pumpWidget(const AiresumeApp());
    await _scrollHomeTo(tester, 'Paste resume');

    await tester.tap(find.text('Paste resume'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Enter resume text to run basic rule-based checks on this device.',
      ),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    await _scrollHomeTo(tester, 'Select a file locally');
    await tester.tap(find.text('Select a file locally'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a resume file'), findsOneWidget);
    expect(
      find.textContaining('Files are selected locally and are not uploaded.'),
      findsOneWidget,
    );
  });

  testWidgets('pasted resume validates and displays rule-based feedback', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ResumeInputScreen()));

    await tester.dragUntilVisible(
      find.text('Check resume'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.tap(find.text('Check resume'));
    await tester.pump();
    expect(find.text('Enter resume text to continue.'), findsOneWidget);

    await tester.tap(find.text('Load sample resume'));
    await tester.pump();
    expect(find.text('Software Engineer'), findsOneWidget);
    expect(find.textContaining('Jordan Lee'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Check resume'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.tap(find.text('Check resume'));
    await tester.pumpAndSettle();
    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Basic resume checks'), findsOneWidget);
    expect(find.text('Edit resume'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Quantified experience'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Quantified experience'), findsOneWidget);
  });

  testWidgets('local file-selection screen supports validation and retry UI', (
    tester,
  ) async {
    await tester.pumpWidget(const AiresumeApp());
    await _scrollHomeTo(tester, 'Select a file locally');
    await tester.tap(find.text('Select a file locally'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a resume file'), findsOneWidget);
    expect(find.text('Choose file'), findsOneWidget);
    expect(
      find.textContaining('Files are selected locally and are not uploaded.'),
      findsOneWidget,
    );
  });

  testWidgets('unsupported-file and retry designs offer a user action', (
    tester,
  ) async {
    await tester.pumpWidget(const AiresumeApp());
    await _openResumeSelection(tester);
    await _scrollTo(tester, 'Preview unsupported-file and retry states');
    await tester.tap(find.text('Preview unsupported-file and retry states'));
    await tester.pumpAndSettle();

    expect(find.text('This file type is not supported'), findsOneWidget);
    await _scrollTo(tester, 'Try again');
    await _scrollFurther(tester);
    expect(find.text('We could not connect'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(
      find.text('Retry is not connected in this preview.'),
      findsOneWidget,
    );
  });

  testWidgets('feedback component supports loading, empty, error and success', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FeedbackState.loading(title: 'Loading', message: 'Please wait'),
              FeedbackState.empty(title: 'Empty', message: 'Nothing here'),
              FeedbackState.error(title: 'Error', message: 'Try again'),
              FeedbackState.success(title: 'Success', message: 'Complete'),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });
}

Future<void> _scrollHomeTo(WidgetTester tester, String text) async {
  await tester.dragUntilVisible(
    find.text(text),
    find.byType(ListView).first,
    const Offset(0, -300),
  );
  await tester.pumpAndSettle();
}

Future<void> _openResumeSelection(WidgetTester tester) async {
  await _scrollHomeTo(tester, 'Choose a resume');
  await tester.tap(find.text('Choose a resume'));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, String text) async {
  await tester.dragUntilVisible(
    find.text(text),
    find.byType(ListView).last,
    const Offset(0, -280),
  );
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> _scrollFurther(WidgetTester tester) async {
  await tester.drag(find.byType(ListView).last, const Offset(0, -180));
  await tester.pumpAndSettle();
}

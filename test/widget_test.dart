import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airesume/main.dart';
import 'package:airesume/widgets/feedback_state.dart';

void main() {
  testWidgets('home opens the resume-selection design preview', (tester) async {
    await tester.pumpWidget(const AiresumeApp());

    expect(find.text('Make your next move\nwith confidence.'), findsOneWidget);
    expect(find.text('Add your resume'), findsOneWidget);
    expect(find.text('Tell us about your next role'), findsOneWidget);
    expect(find.text('Review focused suggestions'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Preview the workflow'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.tap(find.text('Preview the workflow'));
    await tester.pumpAndSettle();

    expect(find.text('Your resume'), findsOneWidget);
    expect(find.text('Start with your resume'), findsOneWidget);
    expect(find.text('Design preview · no file is processed'), findsOneWidget);
    expect(find.text('No resume selected'), findsOneWidget);
  });

  testWidgets('file selection preview explains the action is not connected', (
    tester,
  ) async {
    await tester.pumpWidget(const AiresumeApp());
    await _openResumePreview(tester);
    await _scrollTo(tester, 'Choose a resume');
    await _scrollFurther(tester);
    await tester.tap(find.text('Choose a resume'));
    await tester.pumpAndSettle();

    expect(find.text('File selection is not connected'), findsOneWidget);
    expect(
      find.textContaining('No file is selected or uploaded.'),
      findsOneWidget,
    );
  });

  testWidgets('prototype connects resume, progress and results designs', (
    tester,
  ) async {
    await tester.pumpWidget(const AiresumeApp());
    await _openResumePreview(tester);
    await _scrollTo(tester, 'Preview analysis progress screen');
    await tester.tap(find.text('Preview analysis progress screen'));
    await tester.pumpAndSettle();

    expect(find.text('Reviewing your resume'), findsOneWidget);
    expect(find.text('Review experience and skills'), findsOneWidget);
    await _scrollTo(
      tester,
      'The steps and timing shown here are illustrative. No analysis is running.',
    );
    expect(find.textContaining('No analysis is running.'), findsOneWidget);
    await _scrollTo(tester, 'Preview results layout');
    await tester.tap(find.text('Preview results layout'));
    await tester.pumpAndSettle();

    expect(find.text('Resume feedback'), findsOneWidget);
    expect(find.text('Overall feedback'), findsOneWidget);
    await _scrollTo(tester, 'Strengths');
    expect(find.text('Strengths'), findsOneWidget);
    await _scrollTo(tester, 'Ways to improve');
    expect(find.text('Ways to improve'), findsOneWidget);
    await _scrollTo(
      tester,
      'Placeholder content only · no resume was analyzed',
    );
    expect(
      find.text('Placeholder content only · no resume was analyzed'),
      findsOneWidget,
    );
  });

  testWidgets('unsupported-file and retry designs offer a user action', (
    tester,
  ) async {
    await tester.pumpWidget(const AiresumeApp());
    await _openResumePreview(tester);
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

Future<void> _openResumePreview(WidgetTester tester) async {
  await tester.dragUntilVisible(
    find.text('Preview the workflow'),
    find.byType(ListView).first,
    const Offset(0, -300),
  );
  await tester.tap(find.text('Preview the workflow'));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, String text) async {
  await tester.dragUntilVisible(
    find.text(text),
    find.byType(ListView).last,
    const Offset(0, -280),
  );
  await tester.ensureVisible(find.text(text));
}

Future<void> _scrollFurther(WidgetTester tester) async {
  await tester.drag(find.byType(ListView).last, const Offset(0, -180));
  await tester.pumpAndSettle();
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airesume/main.dart';

void main() {
  testWidgets('home opens the pasted resume input screen', (tester) async {
    await tester.pumpWidget(const AiresumeApp());

    expect(find.text('Make your next move\nwith confidence.'), findsOneWidget);
    expect(find.text('Add your resume'), findsOneWidget);
    expect(find.text('Tell us about your next role'), findsOneWidget);
    expect(find.text('Review focused suggestions'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Add resume text'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Add resume text'), findsOneWidget);

    await tester.tap(find.text('Add resume text'));
    await tester.pumpAndSettle();

    expect(find.text('Paste your resume'), findsOneWidget);
    expect(find.text('Pasted resume text'), findsOneWidget);
    expect(find.text('Target role (optional)'), findsOneWidget);
    expect(find.textContaining('File upload is future work.'), findsOneWidget);
  });

  testWidgets(
    'resume input validates empty text and loads a fictional sample',
    (tester) async {
      await tester.pumpWidget(const AiresumeApp());
      await tester.dragUntilVisible(
        find.text('Add resume text'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.tap(find.text('Add resume text'));
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Continue'),
        find.byType(ListView),
        const Offset(0, -300),
      );
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Paste your resume text to continue.'), findsOneWidget);

      await tester.tap(find.text('Use fictional sample resume'));
      await tester.pump();
      expect(find.text('Software Engineer'), findsOneWidget);
      expect(find.textContaining('Jordan Lee'), findsOneWidget);
    },
  );
}

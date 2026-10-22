import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airesume/main.dart';

void main() {
  testWidgets('home opens the pasted resume input screen', (tester) async {
    await tester.pumpWidget(const AiresumeApp());

    expect(find.text('Make your next move\nwith confidence.'), findsOneWidget);
    expect(find.text('Paste resume'), findsOneWidget);
    expect(find.text('Tell us about your next role'), findsOneWidget);
    expect(find.text('Review basic checks'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Paste resume'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Paste resume'), findsOneWidget);

    await tester.tap(find.text('Paste resume'));
    await tester.pumpAndSettle();

    expect(find.text('Paste resume'), findsNWidgets(2));
  });

  testWidgets('resume input validates empty text and loads a sample', (
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
    expect(find.textContaining('basic rule-based checks'), findsOneWidget);
    expect(find.text('Edit resume'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Quantified experience'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Quantified experience'), findsOneWidget);
  });

  testWidgets('upload entry explains that file selection is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(const AiresumeApp());
    await tester.dragUntilVisible(
      find.text('Upload resume'),
      find.byType(ListView),
      const Offset(0, -300),
    );

    await tester.tap(find.text('Upload resume'));
    await tester.pumpAndSettle();

    expect(find.text('Upload resume'), findsOneWidget);
    expect(find.text('File selection is not available yet'), findsOneWidget);
    expect(
      find.textContaining('No file was uploaded or analyzed.'),
      findsOneWidget,
    );
    expect(find.text('Paste resume'), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Paste resume'), findsNWidgets(2));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airesume/main.dart';

void main() {
  testWidgets('home explains the workflow and upload limitation', (
    tester,
  ) async {
    await tester.pumpWidget(const AiresumeApp());

    expect(find.text('Make your next move\nwith confidence.'), findsOneWidget);
    expect(find.text('Add your resume'), findsOneWidget);
    expect(find.text('Tell us about your next role'), findsOneWidget);
    expect(find.text('Review focused suggestions'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Choose a resume'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('Choose a resume'), findsOneWidget);

    await tester.tap(find.text('Choose a resume'));
    await tester.pumpAndSettle();

    expect(find.text('Resume upload is coming next'), findsOneWidget);
    expect(
      find.textContaining('does not upload or analyze files yet'),
      findsOneWidget,
    );
  });
}

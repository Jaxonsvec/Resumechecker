import 'package:flutter_test/flutter_test.dart';

import 'package:airesume/resume_checker.dart';

void main() {
  const checker = ResumeChecker();

  test(
    'passes checks when common sections and measurable bullets are present',
    () {
      final feedback = checker.check('''
Summary
Software engineer focused on reliable products.

Experience
- Increased delivery speed by 25%.
- Supported 100+ users.

Education
State University

Skills
Dart, Flutter
''');

      expect(feedback.passedCount, 6);
      expect(feedback.checks.every((check) => check.passed), isTrue);
    },
  );

  test('reports specific failures for a sparse resume', () {
    final feedback = checker.check('Taylor Smith\nCustomer support specialist');

    expect(feedback.passedCount, 0);
    expect(feedback.checks.first.explanation, contains('Add a short summary'));
    expect(feedback.checks.last.explanation, contains('measurable results'));
  });

  test('keeps the source text and optional role in reusable feedback', () {
    final feedback = checker.check(
      'Experience\n- Improved response time by 10%',
      targetRole: 'Support Engineer',
    );

    expect(feedback.resumeText, contains('Improved response time'));
    expect(feedback.targetRole, 'Support Engineer');
  });
}

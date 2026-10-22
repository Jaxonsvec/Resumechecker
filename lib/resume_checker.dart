class ResumeCheck {
  const ResumeCheck({
    required this.title,
    required this.explanation,
    required this.passed,
  });

  final String title;
  final String explanation;
  final bool passed;
}

class ResumeFeedback {
  const ResumeFeedback({
    required this.resumeText,
    required this.targetRole,
    required this.checks,
  });

  final String resumeText;
  final String targetRole;
  final List<ResumeCheck> checks;

  int get passedCount => checks.where((check) => check.passed).length;
}

class ResumeChecker {
  const ResumeChecker();

  ResumeFeedback check(String resumeText, {String targetRole = ''}) {
    final text = resumeText.trim();
    final lowerText = text.toLowerCase();

    final hasSummary = _containsAny(lowerText, [
      'summary',
      'professional summary',
      'objective',
      'profile',
    ]);
    final hasExperience = _containsAny(lowerText, [
      'experience',
      'work history',
      'employment',
      'professional experience',
    ]);
    final hasEducation = _containsAny(lowerText, [
      'education',
      'academic background',
    ]);
    final hasSkills = _containsAny(lowerText, [
      'skills',
      'technical skills',
      'core competencies',
    ]);
    final hasBullets = RegExp(
      r'^\s*(?:[-*•]|\d+[.)])\s+',
      multiLine: true,
    ).hasMatch(text);
    final hasQuantifiedExperience = RegExp(
      r'(?:\d+\s*%|\$\s*\d[\d,.]*|\d[\d,.]*\s*\+|\b(?:increased|decreased|reduced|grew|improved)\b[^\n]{0,60}\d)',
      caseSensitive: false,
    ).hasMatch(text);

    return ResumeFeedback(
      resumeText: resumeText,
      targetRole: targetRole.trim(),
      checks: [
        ResumeCheck(
          title: 'Summary or profile section',
          passed: hasSummary,
          explanation: hasSummary
              ? 'A summary-style section was found near the top-level content.'
              : 'Add a short summary, profile, or objective to introduce your focus.',
        ),
        ResumeCheck(
          title: 'Experience section',
          passed: hasExperience,
          explanation: hasExperience
              ? 'A work or experience section was found.'
              : 'Add an experience or work history section with your recent roles.',
        ),
        ResumeCheck(
          title: 'Education section',
          passed: hasEducation,
          explanation: hasEducation ? 'An education section was found.' : 'Add an education section if it is relevant to your target role.',
        ),
        ResumeCheck(
          title: 'Skills section',
          passed: hasSkills,
          explanation: hasSkills
              ? 'A skills or competencies section was found.'
              : 'Add a skills section so relevant tools and capabilities are easy to find.',
        ),
        ResumeCheck(
          title: 'Bullet points',
          passed: hasBullets,
          explanation: hasBullets
              ? 'Bullet-style lines were found to organize your experience.'
              : 'Use bullet points to make accomplishments easier to scan.',
        ),
        ResumeCheck(
          title: 'Quantified experience',
          passed: hasQuantifiedExperience,
          explanation: hasQuantifiedExperience
              ? 'At least one accomplishment includes a number or measurable result.'
              : 'Add measurable results such as percentages, amounts, counts, or time saved.',
        ),
      ],
    );
  }

  bool _containsAny(String text, List<String> terms) {
    return terms.any(
      (term) => RegExp(
        r'(^|\n)\s*' + RegExp.escape(term) + r'\s*(?:$|\n|:)',
        caseSensitive: false,
      ).hasMatch(text),
    );
  }
}

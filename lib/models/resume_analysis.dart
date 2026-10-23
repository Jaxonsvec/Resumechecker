class ResumeAnalysis {
  const ResumeAnalysis({
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.missingInformation,
  });

  final String summary;
  final List<ResumeStrength> strengths;
  final List<ResumeImprovement> improvements;
  final List<String> missingInformation;

  factory ResumeAnalysis.fromJson(Map<String, dynamic> json) {
    final strengths = json['strengths'];
    final improvements = json['improvements'];
    final missingInformation = json['missing_information'];
    if (strengths is! List ||
        strengths.length > 6 ||
        improvements is! List ||
        improvements.length > 8 ||
        missingInformation is! List ||
        missingInformation.length > 8) {
      throw const FormatException(
        'The analysis response has invalid sections.',
      );
    }
    return ResumeAnalysis(
      summary: _requiredText(json['summary'], 'summary', maxLength: 1200),
      strengths: strengths
          .map((value) => ResumeStrength.fromJson(_object(value, 'strength')))
          .toList(growable: false),
      improvements: improvements
          .map(
            (value) =>
                ResumeImprovement.fromJson(_object(value, 'improvement')),
          )
          .toList(growable: false),
      missingInformation: missingInformation
          .map(
            (value) =>
                _requiredText(value, 'missing information', maxLength: 240),
          )
          .toList(growable: false),
    );
  }
}

class ResumeStrength {
  const ResumeStrength({required this.title, required this.evidence});

  final String title;
  final String evidence;

  factory ResumeStrength.fromJson(Map<String, dynamic> json) => ResumeStrength(
    title: _requiredText(json['title'], 'strength title', maxLength: 120),
    evidence: _requiredText(
      json['evidence'],
      'strength evidence',
      maxLength: 500,
    ),
  );
}

class ResumeImprovement {
  const ResumeImprovement({
    required this.title,
    required this.evidence,
    required this.recommendation,
  });

  final String title;
  final String evidence;
  final String recommendation;

  factory ResumeImprovement.fromJson(Map<String, dynamic> json) =>
      ResumeImprovement(
        title: _requiredText(
          json['title'],
          'improvement title',
          maxLength: 120,
        ),
        evidence: _requiredText(
          json['evidence'],
          'improvement evidence',
          maxLength: 500,
        ),
        recommendation: _requiredText(
          json['recommendation'],
          'improvement recommendation',
          maxLength: 700,
        ),
      );
}

Map<String, dynamic> _object(Object? value, String label) {
  if (value is Map<String, dynamic>) return value;
  throw FormatException('The analysis response has an invalid $label.');
}

String _requiredText(Object? value, String label, {required int maxLength}) {
  if (value is String && value.trim().isNotEmpty && value.length <= maxLength) {
    return value.trim();
  }
  throw FormatException('The analysis response has invalid $label.');
}

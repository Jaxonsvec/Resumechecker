class ResumeAnalysis {
  const ResumeAnalysis({
    required this.overallScore,
    required this.categoryScores,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.missingInformation,
    required this.suggestedRewrites,
    required this.jobRelevance,
    this.sourceResumeText = '',
    this.targetRole,
  });

  final int overallScore;
  final Map<String, ResumeCategoryScore> categoryScores;
  final String summary;
  final List<ResumeStrength> strengths;
  final List<ResumeImprovement> improvements;
  final List<String> missingInformation;
  final List<ResumeRewrite> suggestedRewrites;
  final ResumeJobRelevance? jobRelevance;
  final String sourceResumeText;
  final String? targetRole;

  factory ResumeAnalysis.fromJson(Map<String, dynamic> json) {
    final strengths = json['strengths'];
    final improvements = json['improvements'];
    final missingInformation = json['missing_information'];
    final categoryScores = json['category_scores'];
    final rewrites = json['suggested_rewrites'];
    final relevance = json['job_relevance'];
    if (strengths is! List ||
        strengths.length > 6 ||
        improvements is! List ||
        improvements.length > 8 ||
        missingInformation is! List ||
        missingInformation.length > 8 ||
        categoryScores is! Map<String, dynamic> ||
        categoryScores.length != 5 ||
        rewrites is! List ||
        rewrites.length > 8 ||
        (relevance != null && relevance is! Map<String, dynamic>)) {
      throw const FormatException(
        'The analysis response has invalid sections.',
      );
    }
    final result = ResumeAnalysis(
      overallScore: _score(json['overall_score'], 'overall score'),
      categoryScores: {
        for (final key in const [
          'clarity',
          'impact',
          'measurable_results',
          'skills_experience',
          'formatting_organization',
        ])
          key: ResumeCategoryScore.fromJson(
            _object(categoryScores[key], 'category score'),
          ),
      },
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
      suggestedRewrites: rewrites
          .map((value) => ResumeRewrite.fromJson(_object(value, 'rewrite')))
          .toList(growable: false),
      jobRelevance: relevance == null
          ? null
          : ResumeJobRelevance.fromJson(relevance as Map<String, dynamic>),
      sourceResumeText: json['_source_resume_text'] is String
          ? json['_source_resume_text'] as String
          : '',
      targetRole: json['_target_role'] is String
          ? (json['_target_role'] as String).trim()
          : null,
    );
    final expectedOverall =
        (result.categoryScores.values.fold<int>(
                  0,
                  (sum, item) => sum + item.score,
                ) /
                result.categoryScores.length)
            .round();
    if (result.overallScore != expectedOverall) {
      throw const FormatException(
        'The analysis score does not match its category scores.',
      );
    }
    return result;
  }
}

class ResumeCategoryScore {
  const ResumeCategoryScore({required this.score, required this.explanation});
  final int score;
  final String explanation;

  factory ResumeCategoryScore.fromJson(Map<String, dynamic> json) =>
      ResumeCategoryScore(
        score: _score(json['score'], 'category score'),
        explanation: _requiredText(
          json['explanation'],
          'score explanation',
          maxLength: 500,
        ),
      );
}

class ResumeRewrite {
  const ResumeRewrite({
    required this.section,
    required this.originalText,
    required this.revisedText,
    required this.rationale,
  });
  final String section;
  final String originalText;
  final String revisedText;
  final String rationale;

  factory ResumeRewrite.fromJson(Map<String, dynamic> json) => ResumeRewrite(
    section: _requiredText(json['section'], 'rewrite section', maxLength: 120),
    originalText: _requiredText(
      json['original_text'],
      'original text',
      maxLength: 700,
    ),
    revisedText: _requiredText(
      json['revised_text'],
      'revised text',
      maxLength: 700,
    ),
    rationale: _requiredText(
      json['rationale'],
      'rewrite rationale',
      maxLength: 500,
    ),
  );
}

class ResumeJobRelevance {
  const ResumeJobRelevance({
    required this.score,
    required this.relevantSkills,
    required this.missingSkills,
    required this.transferableSkills,
  });
  final int score;
  final List<String> relevantSkills;
  final List<String> missingSkills;
  final List<String> transferableSkills;

  factory ResumeJobRelevance.fromJson(Map<String, dynamic> json) =>
      ResumeJobRelevance(
        score: _score(json['score'], 'job relevance score'),
        relevantSkills: _textList(json['relevant_skills'], 'relevant skills'),
        missingSkills: _textList(json['missing_skills'], 'missing skills'),
        transferableSkills: _textList(
          json['transferable_skills'],
          'transferable skills',
        ),
      );
}

List<String> _textList(Object? value, String label) {
  if (value is! List || value.length > 20) {
    throw FormatException('The analysis response has invalid $label.');
  }
  return value
      .map((item) => _requiredText(item, label, maxLength: 120))
      .toList(growable: false);
}

int _score(Object? value, String label) {
  if (value is int && value >= 0 && value <= 100) return value;
  throw FormatException('The analysis response has invalid $label.');
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

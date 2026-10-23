import 'package:flutter/material.dart';

import '../models/resume_analysis.dart';
import '../theme/app_theme.dart';
import '../widgets/workflow_components.dart';
import 'resume_comparison_screen.dart';
import 'resume_editor_screen.dart';

class AnalysisResultsScreen extends StatefulWidget {
  const AnalysisResultsScreen({
    super.key,
    required this.result,
    required this.resumeName,
  });

  final ResumeAnalysis result;
  final String resumeName;

  @override
  State<AnalysisResultsScreen> createState() => _AnalysisResultsScreenState();
}

class _AnalysisResultsScreenState extends State<AnalysisResultsScreen> {
  late ResumeAnalysis _result;
  late final String _originalResumeText;
  String _workingText = '';
  final List<ResumeAnalysis> _assessmentHistory = [];

  @override
  void initState() {
    super.initState();
    _result = widget.result;
    _workingText = widget.result.sourceResumeText;
    _originalResumeText = widget.result.sourceResumeText;
  }

  void _updateWorkingText(String text) => setState(() => _workingText = text);

  void _updateAnalysis(ResumeAnalysis analysis) => setState(() {
    _assessmentHistory.add(_result);
    _result = analysis;
    _workingText = analysis.sourceResumeText;
  });

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Resume feedback')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const WorkflowStepHeader(step: 3, label: 'Your feedback'),
                const SizedBox(height: 24),
                Text(
                  'A clear view of your next steps',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Based on ${widget.resumeName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                _ResultSection(
                  icon: Icons.summarize_outlined,
                  title: 'Overall feedback',
                  body: result.summary,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resume score: ${result.overallScore}/100',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Text(
                          'Assessment tool only; this score does not predict hiring success or ATS performance.',
                        ),
                        for (final entry in result.categoryScores.entries)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(_categoryLabel(entry.key)),
                            subtitle: Text(entry.value.explanation),
                            trailing: Text('${entry.value.score}/100'),
                          ),
                      ],
                    ),
                  ),
                ),
                if (result.jobRelevance case final relevance?)
                  _ResultSection(
                    icon: Icons.work_outline,
                    title: 'Job relevance: ${relevance.score}/100',
                    children: [
                      Text(
                        'Relevant skills: ${relevance.relevantSkills.join(', ').ifEmpty('None identified')}',
                      ),
                      Text(
                        'Missing skills: ${relevance.missingSkills.join(', ').ifEmpty('None identified')}',
                      ),
                      Text(
                        'Transferable skills: ${relevance.transferableSkills.join(', ').ifEmpty('None identified')}',
                      ),
                    ],
                  ),
                if (result.suggestedRewrites.isNotEmpty)
                  _ResultSection(
                    icon: Icons.auto_fix_high_outlined,
                    title: 'Suggested rewrites',
                    children: [
                      for (final rewrite in result.suggestedRewrites)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${rewrite.section}\nBefore: ${rewrite.originalText}\nSuggested: ${rewrite.revisedText}\nWhy: ${rewrite.rationale}',
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                _ResultSection(
                  icon: Icons.thumb_up_alt_outlined,
                  title: 'Strengths',
                  body: result.strengths.isEmpty
                      ? 'No specific strengths were identified from the available resume text.'
                      : null,
                  children: [
                    for (final strength in result.strengths)
                      _EvidenceItem(
                        title: strength.title,
                        evidence: strength.evidence,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _ResultSection(
                  icon: Icons.lightbulb_outline,
                  title: 'Ways to improve',
                  body: result.improvements.isEmpty
                      ? 'No specific improvements were identified from the available resume text.'
                      : null,
                  children: [
                    for (final improvement in result.improvements)
                      _EvidenceItem(
                        title: improvement.title,
                        evidence: improvement.evidence,
                        recommendation: improvement.recommendation,
                      ),
                  ],
                ),
                if (result.missingInformation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ResultSection(
                    icon: Icons.find_in_page_outlined,
                    title: 'Details to consider adding',
                    children: [
                      for (final item in result.missingInformation)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('•  '),
                              Expanded(child: Text(item)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Suggestions are based only on the text extracted from your resume. Review them for accuracy before making changes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                if (_assessmentHistory.isNotEmpty)
                  _ResultSection(
                    icon: Icons.compare_arrows,
                    title: 'Regrade history',
                    children: [
                      Text(
                        'Original extracted text remains available separately from the working revision.',
                      ),
                      for (
                        var index = 0;
                        index < _assessmentHistory.length;
                        index++
                      )
                        Text(
                          'Assessment ${index + 1}: ${_assessmentHistory[index].overallScore}/100',
                        ),
                      Text('Current assessment: ${result.overallScore}/100'),
                    ],
                  ),
                ExpansionTile(
                  title: const Text('View original extracted text'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(_originalResumeText),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ResumeEditorScreen(
                        initialAnalysis: result,
                        initialText: _workingText,
                        previousAssessments: _assessmentHistory,
                        onWorkingTextChanged: _updateWorkingText,
                        onRegraded: _updateAnalysis,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Resume'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ResumeComparisonScreen(
                        userAnalysis: result,
                        workingText: _workingText,
                        previousAssessments: _assessmentHistory,
                        onWorkingTextChanged: _updateWorkingText,
                        onRegraded: _updateAnalysis,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Compare with Example'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.replay_outlined),
                  label: const Text('Analyze another resume'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _categoryLabel(String key) => switch (key) {
  'clarity' => 'Clarity and readability',
  'impact' => 'Impact and achievements',
  'measurable_results' => 'Measurable results',
  'skills_experience' => 'Skills and experience',
  _ => 'Formatting and organization',
};

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.icon,
    required this.title,
    this.body,
    this.children = const [],
  });

  final IconData icon;
  final String title;
  final String? body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (body case final text?) ...[
                  const SizedBox(height: 6),
                  Text(text, style: Theme.of(context).textTheme.bodyMedium),
                ],
                ...children,
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _EvidenceItem extends StatelessWidget {
  const _EvidenceItem({
    required this.title,
    required this.evidence,
    this.recommendation,
  });

  final String title;
  final String evidence;
  final String? recommendation;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('From your resume: $evidence'),
        if (recommendation case final value?) ...[
          const SizedBox(height: 4),
          Text('Suggestion: $value'),
        ],
      ],
    ),
  );
}

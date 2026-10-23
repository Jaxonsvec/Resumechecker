import 'package:flutter/material.dart';

import '../models/resume_analysis.dart';
import '../models/resume_example.dart';
import 'resume_editor_screen.dart';

class ResumeComparisonScreen extends StatefulWidget {
  const ResumeComparisonScreen({
    super.key,
    required this.userAnalysis,
    this.workingText,
    this.previousAssessments = const [],
    this.onWorkingTextChanged,
    this.onRegraded,
  });
  final ResumeAnalysis userAnalysis;
  final String? workingText;
  final List<ResumeAnalysis> previousAssessments;
  final ValueChanged<String>? onWorkingTextChanged;
  final ValueChanged<ResumeAnalysis>? onRegraded;
  @override
  State<ResumeComparisonScreen> createState() => _ResumeComparisonScreenState();
}

class _ResumeComparisonScreenState extends State<ResumeComparisonScreen> {
  ResumeExample? selected;

  late ResumeAnalysis _analysis;
  late String _workingText;

  @override
  void initState() {
    super.initState();
    _analysis = widget.userAnalysis;
    _workingText = widget.workingText ?? widget.userAnalysis.sourceResumeText;
  }

  void _textChanged(String text) => setState(() => _workingText = text);

  void _analysisChanged(ResumeAnalysis analysis) =>
      setState(() => _analysis = analysis);

  @override
  Widget build(BuildContext context) {
    final example = selected;
    return Scaffold(
      appBar: AppBar(title: const Text('Compare with example')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose a fictional example. Differences can reflect career stage, role, and available experience; use transferable writing techniques, never another person’s claims.',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ResumeExample>(
            initialValue: example,
            decoration: const InputDecoration(labelText: 'Resume example'),
            items: [
              for (final item in resumeExamples)
                DropdownMenuItem(
                  value: item,
                  child: Text('${item.title} (${item.level})'),
                ),
            ],
            onChanged: (value) => setState(() => selected = value),
          ),
          if (example != null) ...[
            const SizedBox(height: 16),
            Text(
              'Overall scores',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ListTile(
              title: const Text('Your analyzed resume'),
              trailing: Text('${_analysis.overallScore}/100'),
            ),
            ListTile(
              title: Text('Fictional ${example.title}'),
              trailing: Text('${example.overallScore}/100'),
            ),
            const Text(
              'Scores use the same equally weighted five-category rubric.',
            ),
            const SizedBox(height: 12),
            for (final entry in _analysis.categoryScores.entries)
              _comparisonRow(
                entry.key,
                entry.value,
                example.categoryScores[entry.key]!,
              ),
            const SizedBox(height: 12),
            Text(
              'Where your resume is strong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _analysis.strengths
                  .map((item) => '• ${item.title}: ${item.evidence}')
                  .join('\n')
                  .ifEmpty(
                    'Review the rubric scores and your original text for strengths.',
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Techniques this example demonstrates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(example.whyItWorks),
            for (final item in _analysis.improvements)
              ListTile(
                title: Text(item.title),
                subtitle: Text(item.recommendation),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ResumeEditorScreen(
                    initialAnalysis: _analysis,
                    initialText: _workingText,
                    previousAssessments: widget.previousAssessments,
                    onWorkingTextChanged: (text) {
                      _textChanged(text);
                      widget.onWorkingTextChanged?.call(text);
                    },
                    onRegraded: (analysis) {
                      _analysisChanged(analysis);
                      widget.onRegraded?.call(analysis);
                    },
                  ),
                ),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Open editor and improve resume'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _comparisonRow(
    String key,
    ResumeCategoryScore user,
    ResumeCategoryScore example,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _label(key),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('You: ${user.score}'),
              Text('Example: ${example.score}'),
              Text(
                'Δ ${user.score - example.score >= 0 ? '+' : ''}${user.score - example.score}',
              ),
            ],
          ),
          Text('Your resume: ${user.explanation}'),
          Text('Example: ${example.explanation}'),
        ],
      ),
    ),
  );
}

String _label(String key) => switch (key) {
  'clarity' => 'Clarity and readability',
  'impact' => 'Impact and achievements',
  'measurable_results' => 'Measurable results',
  'skills_experience' => 'Skills and experience',
  _ => 'Formatting and organization',
};

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

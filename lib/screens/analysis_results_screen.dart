import 'package:flutter/material.dart';

import '../models/resume_analysis.dart';
import '../theme/app_theme.dart';
import '../widgets/workflow_components.dart';

class AnalysisResultsScreen extends StatelessWidget {
  const AnalysisResultsScreen({
    super.key,
    required this.result,
    required this.resumeName,
  });

  final ResumeAnalysis result;
  final String resumeName;

  @override
  Widget build(BuildContext context) {
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
                  'Based on $resumeName',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                _ResultSection(
                  icon: Icons.summarize_outlined,
                  title: 'Overall feedback',
                  body: result.summary,
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

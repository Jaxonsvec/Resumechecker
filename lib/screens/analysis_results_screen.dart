import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/workflow_components.dart';

class AnalysisResultsScreen extends StatelessWidget {
  const AnalysisResultsScreen({super.key});

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
                const PrototypeBanner(),
                const SizedBox(height: 24),
                const WorkflowStepHeader(step: 3, label: 'Your feedback'),
                const SizedBox(height: 24),
                Text(
                  'A clear view of your next steps',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'The proposed results layout groups feedback into a summary, strengths, and suggested improvements. The team still needs to agree on scoring and analysis criteria.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                const _ResultSection(
                  icon: Icons.summarize_outlined,
                  title: 'Overall feedback',
                  body: 'A concise summary based on the agreed review criteria will appear here.',
                ),
                const SizedBox(height: 12),
                const _ResultSection(
                  icon: Icons.thumb_up_alt_outlined,
                  title: 'Strengths',
                  body: 'Specific strengths, with evidence from the resume, will appear here.',
                ),
                const SizedBox(height: 12),
                const _ResultSection(
                  icon: Icons.lightbulb_outline,
                  title: 'Ways to improve',
                  body: 'Prioritized, actionable suggestions will appear here.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Placeholder content only · no resume was analyzed',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.replay_outlined),
                  label: const Text('Return to home'),
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
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

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
                const SizedBox(height: 6),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

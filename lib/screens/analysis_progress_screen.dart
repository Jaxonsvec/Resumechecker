import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'analysis_results_screen.dart';
import '../widgets/workflow_components.dart';

class AnalysisProgressScreen extends StatelessWidget {
  const AnalysisProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviewing your resume')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const PrototypeBanner(),
                const SizedBox(height: 24),
                const WorkflowStepHeader(step: 2, label: 'Review in progress'),
                const SizedBox(height: 24),
                Text(
                  'A little room to think',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'A future analysis will review the document and prepare focused feedback. This preview does not start a request.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: const [
                        LinearProgressIndicator(value: 0.55),
                        SizedBox(height: 24),
                        _ProgressRow(
                          icon: Icons.check_circle,
                          label: 'Confirm document details',
                          complete: true,
                        ),
                        SizedBox(height: 18),
                        _ProgressRow(
                          icon: Icons.hourglass_top,
                          label: 'Review experience and skills',
                          complete: false,
                        ),
                        SizedBox(height: 18),
                        _ProgressRow(
                          icon: Icons.circle_outlined,
                          label: 'Prepare recommendations',
                          complete: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'The steps and timing shown here are illustrative. No analysis is running.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AnalysisResultsScreen(),
                    ),
                  ),
                  child: const Text('Preview results layout'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Back to resume selection'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.complete,
  });

  final IconData icon;
  final String label;
  final bool complete;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: complete ? AppColors.teal : AppColors.muted),
      const SizedBox(width: 12),
      Expanded(child: Text(label)),
      if (complete) const Icon(Icons.check, color: AppColors.teal, size: 18),
    ],
  );
}

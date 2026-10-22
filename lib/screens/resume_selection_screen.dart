import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/workflow_components.dart';
import 'analysis_progress_screen.dart';
import 'workflow_issues_screen.dart';

class ResumeSelectionScreen extends StatelessWidget {
  const ResumeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your resume')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const PrototypeBanner(),
                const SizedBox(height: 24),
                const WorkflowStepHeader(step: 1, label: 'Add your resume'),
                const SizedBox(height: 16),
                Text(
                  'Start with your resume',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a document to prepare for feedback. Supported formats and size limits will be confirmed before upload is implemented.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.upload_file_outlined,
                          color: AppColors.teal,
                          size: 36,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No resume selected',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No file is read or uploaded in this preview.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => _showNotImplemented(context),
                          icon: const Icon(Icons.folder_open_outlined),
                          label: const Text('Choose a resume'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target role (optional)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'e.g. Product designer',
                            helperText:
                                'Not saved or sent in this design preview.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: null, child: const Text('Continue')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _open(context, const WorkflowIssuesScreen()),
                  child: const Text(
                    'Preview unsupported-file and retry states',
                  ),
                ),
                OutlinedButton(
                  onPressed: () =>
                      _open(context, const AnalysisProgressScreen()),
                  child: const Text('Preview analysis progress screen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotImplemented(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File selection is not connected'),
        content: const Text(
          'This screen is a design preview. No file is selected or uploaded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

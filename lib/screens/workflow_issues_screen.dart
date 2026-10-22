import 'package:flutter/material.dart';

import '../widgets/feedback_state.dart';
import '../widgets/workflow_components.dart';

class WorkflowIssuesScreen extends StatelessWidget {
  const WorkflowIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('When something goes wrong')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const PrototypeBanner(),
                const SizedBox(height: 24),
                Text(
                  'Clear next steps, even when there is a problem',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FeedbackState.error(
                      title: 'This file type is not supported',
                      message: 'Choose a PDF or DOCX file up to 10 MiB.',
                      actionLabel: 'Choose another file',
                      onAction: () => _showPreviewMessage(
                        context,
                        'File picker is not connected in this preview.',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FeedbackState.error(
                      title: 'We could not connect',
                      message: 'Your resume should remain available so you can retry when the service is back.',
                      actionLabel: 'Try again',
                      onAction: () => _showPreviewMessage(
                        context,
                        'Retry is not connected in this preview.',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'These are proposed messages. File type and size are checked during local selection; network retry is not connected.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Return to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPreviewMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

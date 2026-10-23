import 'package:flutter/material.dart';

import '../resume_upload_screen.dart';
import 'resume_input_screen.dart';
import '../theme/app_theme.dart';
import 'resume_selection_screen.dart';
import 'resume_examples_screen.dart';
import 'resume_image_input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('airesume'),
        actions: [
          IconButton(
            tooltip: 'About Airesume',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Airesume',
              applicationVersion: 'Project foundation',
              children: const [
                Text(
                  'Airesume sends selected resume text to the configured backend and AI service to prepare feedback.',
                ),
              ],
            ),
            icon: const Icon(Icons.info_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.teal,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Make your next move\nwith confidence.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 14),
                Text(
                  'Get thoughtful feedback on your resume and see where it can better support your career goals.',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: AppColors.muted, fontSize: 16),
                ),
                const SizedBox(height: 32),
                const _WorkflowCard(),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ResumeSelectionScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.explore_outlined),
                  label: const Text('Choose a resume'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ResumeInputScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('Paste resume'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ResumeUploadScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Select a file locally'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ResumeExamplesScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Resume Examples'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ResumeImageInputScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: const Text('Upload a resume picture'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose a resume to send it to the configured analysis service, paste text for on-device checks, or select a file locally for a preview.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF687572),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  const _WorkflowCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'A clear path to better feedback',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 18),
            _WorkflowStep(number: '01', label: 'Add your resume'),
            SizedBox(height: 14),
            _WorkflowStep(number: '02', label: 'Tell us about your next role'),
            SizedBox(height: 14),
            _WorkflowStep(number: '03', label: 'Review focused suggestions'),
          ],
        ),
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  const _WorkflowStep({required this.number, required this.label});
  final String number;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        number,
        style: const TextStyle(
          color: AppColors.teal,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(width: 14),
      Expanded(child: Text(label)),
    ],
  );
}

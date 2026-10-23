import 'package:flutter/material.dart';

import '../resume_checker.dart';
import '../resume_results_screen.dart';

class ResumeInputScreen extends StatefulWidget {
  const ResumeInputScreen({super.key});

  @override
  State<ResumeInputScreen> createState() => _ResumeInputScreenState();
}

class _ResumeInputScreenState extends State<ResumeInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _resumeController = TextEditingController();
  final _targetRoleController = TextEditingController();

  @override
  void dispose() {
    _resumeController.dispose();
    _targetRoleController.dispose();
    super.dispose();
  }

  void _useSampleResume() {
    _resumeController.text = '''Jordan Lee
jordan.lee@example.com | Austin, TX

Summary
Product-minded software engineer with experience building reliable web tools.

Experience
Software Engineer, Northstar Labs - 2022-Present
- Built internal dashboards used by 120+ teammates.
- Reduced report generation time by 35% through targeted automation.

Education
B.S. Computer Science, State University''';
    _targetRoleController.text = 'Software Engineer';
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final feedback = const ResumeChecker().check(
      _resumeController.text,
      targetRole: _targetRoleController.text,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResumeResultsScreen(feedback: feedback),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paste resume')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            children: [
              Text(
                'Paste resume',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter resume text to run basic rule-based checks on this device.',
                style: TextStyle(color: Color(0xFF53615E), height: 1.5),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _resumeController,
                minLines: 12,
                maxLines: 18,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Resume text',
                  hintText: 'Paste the text from your resume here',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter resume text to continue.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetRoleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Target role',
                  hintText: 'Optional - for example, Product Designer',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _useSampleResume,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Load sample resume'),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                child: const Text('Check resume'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

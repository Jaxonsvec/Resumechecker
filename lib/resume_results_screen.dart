import 'package:flutter/material.dart';

import 'resume_checker.dart';

class ResumeResultsScreen extends StatelessWidget {
  const ResumeResultsScreen({required this.feedback, super.key});

  final ResumeFeedback feedback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'Basic resume checks',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '${feedback.passedCount} of ${feedback.checks.length} checks passed',
              style: const TextStyle(
                color: Color(0xFF1F766A),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Feedback uses basic rule-based checks for common resume patterns. It is not AI analysis and does not produce a hiring or ATS score.',
              style: TextStyle(color: Color(0xFF53615E), height: 1.5),
            ),
            if (feedback.targetRole.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Target role: ${feedback.targetRole}'),
            ],
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit resume'),
              ),
            ),
            const SizedBox(height: 8),
            ...feedback.checks.map((check) => _CheckCard(check: check)),
          ],
        ),
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  const _CheckCard({required this.check});

  final ResumeCheck check;

  @override
  Widget build(BuildContext context) {
    final color = check.passed
        ? const Color(0xFF1F766A)
        : const Color(0xFF9A5B18);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E8E3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            check.passed ? Icons.check_circle_outline : Icons.info_outline,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  check.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(check.explanation),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

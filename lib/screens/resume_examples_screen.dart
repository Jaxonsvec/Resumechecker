import 'package:flutter/material.dart';

import '../models/resume_example.dart';

class ResumeExamplesScreen extends StatelessWidget {
  const ResumeExamplesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Resume Examples')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Fictional demonstrations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text(
          'Scores are curated examples using the same five-category rubric. They are not live analyses or hiring predictions.',
        ),
        const SizedBox(height: 12),
        for (final example in resumeExamples)
          Card(
            child: ListTile(
              title: Text(example.title),
              subtitle: Text(
                '${example.field} • ${example.level}\nCurated score: ${example.overallScore}/100',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _ExampleDetail(example: example),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _ExampleDetail extends StatelessWidget {
  const _ExampleDetail({required this.example});
  final ResumeExample example;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(example.title)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${example.field} • ${example.level} • fictional demonstration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(example.text, style: const TextStyle(height: 1.5)),
        const SizedBox(height: 16),
        Text(
          'Curated score: ${example.overallScore}/100',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        for (final entry in example.categoryScores.entries)
          ListTile(
            title: Text(_label(entry.key)),
            subtitle: Text(entry.value.explanation),
            trailing: Text('${entry.value.score}'),
          ),
        Text(
          'Why this example works',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(example.whyItWorks),
        const SizedBox(height: 16),
        const Text(
          'Use the structure and writing techniques as references. Never copy fictional personal details or experience.',
        ),
        const SizedBox(height: 12),
        const Text(
          'To compare this reference with your own, open your live analysis results and choose “Compare with Example”.',
        ),
      ],
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

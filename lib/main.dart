import 'package:flutter/material.dart';

import 'resume_input.dart';

void main() {
  runApp(const AiresumeApp());
}

class AiresumeApp extends StatelessWidget {
  const AiresumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF192C2A);
    return MaterialApp(
      title: 'Airesume',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F766A),
          surface: const Color(0xFFFAF9F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF9F5),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: ink,
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
          bodyLarge: TextStyle(color: ink, height: 1.5),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('airesume'),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
          color: const Color(0xFF192C2A),
        ),
        backgroundColor: const Color(0xFFFAF9F5),
        actions: [
          IconButton(
            tooltip: 'About Airesume',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Airesume',
              applicationVersion: 'Project foundation',
              children: const [
                Text(
                  'Resume analysis will be available when the secure API is connected.',
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
                    color: const Color(0xFFE8F1EB),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF1F766A),
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
                      ?.copyWith(color: const Color(0xFF53615E), fontSize: 16),
                ),
                const SizedBox(height: 32),
                const _WorkflowCard(),
                const SizedBox(height: 16),
                const ResumeInput(),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E8E3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  const _WorkflowStep({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Color(0xFF1F766A),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label)),
      ],
    );
  }
}

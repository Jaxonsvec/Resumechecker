import 'package:flutter/material.dart';

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
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ResumeInputScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('Add resume text'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFF1F766A),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'PDF or DOCX · Your resume is personal. It will only be sent after secure upload is implemented.',
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resume text is ready for the next step.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add your resume')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            children: [
              Text(
                'Paste your resume',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'This demo accepts pasted text only. File upload is future work.',
                style: TextStyle(color: Color(0xFF53615E), height: 1.5),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _resumeController,
                minLines: 12,
                maxLines: 18,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Pasted resume text',
                  hintText: 'Paste the text from your resume here',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Paste your resume text to continue.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetRoleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Target role (optional)',
                  hintText: 'For example, Product Designer',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _useSampleResume,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Use fictional sample resume'),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: const Color(0xFF1F766A),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: const Text('Continue'),
              ),
            ],
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

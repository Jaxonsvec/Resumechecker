import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/resume_analysis.dart';
import '../services/resume_analysis_api.dart';
import '../theme/app_theme.dart';
import '../widgets/workflow_components.dart';
import 'analysis_results_screen.dart';

class AnalysisProgressScreen extends StatefulWidget {
  const AnalysisProgressScreen({
    super.key,
    required this.api,
    required this.fileName,
    required this.readBytes,
    this.targetRole,
  });

  final ResumeAnalysisApi api;
  final String fileName;
  final Future<Uint8List> Function() readBytes;
  final String? targetRole;

  @override
  State<AnalysisProgressScreen> createState() => _AnalysisProgressScreenState();
}

class _AnalysisProgressScreenState extends State<AnalysisProgressScreen> {
  late Future<ResumeAnalysis> _analysis;

  @override
  void initState() {
    super.initState();
    _analysis = _requestAnalysis();
  }

  Future<ResumeAnalysis> _requestAnalysis() => widget.api.analyze(
    fileName: widget.fileName,
    readBytes: widget.readBytes,
    targetRole: widget.targetRole,
  );

  void _retry() {
    setState(() {
      _analysis = _requestAnalysis();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResumeAnalysis>(
      future: _analysis,
      builder: (context, snapshot) {
        final result = snapshot.data;
        final error = snapshot.error;
        return Scaffold(
          appBar: AppBar(title: const Text('Reviewing your resume')),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const WorkflowStepHeader(step: 2, label: 'Resume review'),
                    const SizedBox(height: 24),
                    Text(
                      result != null
                          ? 'Your feedback is ready'
                          : error != null
                          ? 'We could not finish the analysis'
                          : 'Reviewing your resume',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      _buildLoading(context)
                    else if (result != null)
                      _buildSuccess(context, result)
                    else
                      _buildFailure(context, error),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const LinearProgressIndicator(),
          const SizedBox(height: 24),
          const Icon(
            Icons.description_outlined,
            color: AppColors.teal,
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(widget.fileName, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Uploading the document and preparing focused feedback. This may take a few moments.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    ),
  );

  Widget _buildSuccess(BuildContext context, ResumeAnalysis result) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.teal,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text('Analysis complete'),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => AnalysisResultsScreen(
                  result: result,
                  resumeName: widget.fileName,
                ),
              ),
            ),
            child: const Text('View resume feedback'),
          ),
        ],
      ),
    ),
  );

  Widget _buildFailure(BuildContext context, Object? error) {
    final message = error is ResumeAnalysisException
        ? error.message
        : 'An unexpected error occurred. Please try again.';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to resume selection'),
            ),
          ],
        ),
      ),
    );
  }
}

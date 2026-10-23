import 'package:flutter/material.dart';

import '../models/resume_analysis.dart';
import '../services/resume_analysis_api.dart';

class ResumeEditorScreen extends StatefulWidget {
  const ResumeEditorScreen({
    super.key,
    required this.initialAnalysis,
    this.api,
    this.initialText,
    this.previousAssessments = const [],
    this.onWorkingTextChanged,
    this.onRegraded,
  });
  final ResumeAnalysis initialAnalysis;
  final ResumeAnalysisApi? api;
  final String? initialText;
  final List<ResumeAnalysis> previousAssessments;
  final ValueChanged<String>? onWorkingTextChanged;
  final ValueChanged<ResumeAnalysis>? onRegraded;
  @override
  State<ResumeEditorScreen> createState() => _ResumeEditorScreenState();
}

class _ResumeEditorScreenState extends State<ResumeEditorScreen> {
  late final TextEditingController _controller;
  late ResumeAnalysis _current;
  final List<ResumeAnalysis> _history = [];
  final Map<ResumeRewrite, bool> _suggestionDecisions = {};
  bool _busy = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _current = widget.initialAnalysis;
    _history.addAll(widget.previousAssessments);
    _controller = TextEditingController(
      text: widget.initialText ?? widget.initialAnalysis.sourceResumeText,
    );
    _controller.addListener(
      () => _dirty = _controller.text != _current.sourceResumeText,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard unsaved edits?'),
            content: const Text('Your current working revision will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _apply(ResumeRewrite rewrite) async {
    final original = rewrite.originalText;
    final index = _controller.text.indexOf(original);
    if (index < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'That original passage has changed. Apply the suggestion manually if it still fits.',
          ),
        ),
      );
      return;
    }
    setState(() {
      _controller.text = _controller.text.replaceRange(
        index,
        index + original.length,
        rewrite.revisedText,
      );
      _suggestionDecisions[rewrite] = true;
    });
    widget.onWorkingTextChanged?.call(_controller.text);
  }

  Future<void> _regrade() async {
    if (_controller.text.trim().isEmpty) return;
    final consent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send this revision for analysis?'),
        content: const Text(
          'The current resume text will be sent to the AI provider configured for your Airesume backend, just like your original analysis.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send and regrade'),
          ),
        ],
      ),
    );
    if (consent != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final api = widget.api ?? HttpResumeAnalysisApi();
      final next = await api.analyzeText(
        resumeText: _controller.text,
        targetRole: _current.targetRole,
      );
      if (!mounted) return;
      setState(() {
        _history.add(_current);
        _current = next;
        _dirty = false;
      });
      widget.onRegraded?.call(next);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Regrade complete. Scores are based on the revised text.',
          ),
        ),
      );
    } on ResumeAnalysisException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit resume')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Original upload and extracted text remain unchanged. This working revision is reconstructed from extracted text; it does not preserve the source PDF/DOCX layout.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          onChanged: (_) => setState(() {
            _dirty = _controller.text != _current.sourceResumeText;
            widget.onWorkingTextChanged?.call(_controller.text);
          }),
          minLines: 14,
          maxLines: null,
          decoration: const InputDecoration(
            labelText: 'Working resume text',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'AI rewrite suggestions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (_current.suggestedRewrites.isEmpty)
          const Text('No rewrite suggestions were returned for this version.'),
        for (final rewrite in _current.suggestedRewrites)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rewrite.section,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('Original'),
                  Text(rewrite.originalText),
                  const SizedBox(height: 6),
                  const Text('Suggested'),
                  Text(rewrite.revisedText),
                  const SizedBox(height: 6),
                  Text(rewrite.rationale),
                  if (_suggestionDecisions.containsKey(rewrite))
                    Text(
                      _suggestionDecisions[rewrite]! ? 'Accepted' : 'Rejected',
                    ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _suggestionDecisions.containsKey(rewrite)
                            ? null
                            : () => _apply(rewrite),
                        child: const Text('Accept'),
                      ),
                      TextButton(
                        onPressed: _suggestionDecisions.containsKey(rewrite)
                            ? null
                            : () => setState(
                                () => _suggestionDecisions[rewrite] = false,
                              ),
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (_history.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Previous vs latest regrade',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          ListTile(
            title: Text(
              'Previous ${_history.last.overallScore}/100 → Current ${_current.overallScore}/100',
            ),
            subtitle: Text(
              'Change ${_current.overallScore - _history.last.overallScore >= 0 ? '+' : ''}${_current.overallScore - _history.last.overallScore} points',
            ),
          ),
          for (final key in _current.categoryScores.keys)
            ListTile(
              title: Text(_label(key)),
              subtitle: Text(
                '${_history.last.categoryScores[key]!.score} → ${_current.categoryScores[key]!.score}',
              ),
            ),
          for (final item in _current.improvements)
            ListTile(
              title: Text(item.title),
              subtitle: Text(item.recommendation),
            ),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _busy ? null : _regrade,
          icon: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: Text(_busy ? 'Regrading…' : 'Regrade Resume'),
        ),
        OutlinedButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            if (await _confirmDiscard() && navigator.mounted) {
              _controller.text = _current.sourceResumeText;
              widget.onWorkingTextChanged?.call(_controller.text);
              navigator.pop();
            }
          },
          child: const Text('Discard changes'),
        ),
      ],
    ),
  );
}

String _label(String key) => switch (key) {
  'clarity' => 'Clarity',
  'impact' => 'Impact',
  'measurable_results' => 'Measurable results',
  'skills_experience' => 'Skills and experience',
  _ => 'Formatting and organization',
};

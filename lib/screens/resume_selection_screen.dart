import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/picked_resume.dart';
import '../services/resume_analysis_api.dart';
import '../services/resume_file_picker.dart';
import '../theme/app_theme.dart';
import 'analysis_progress_screen.dart';
import 'workflow_issues_screen.dart';

class ResumeSelectionScreen extends StatefulWidget {
  const ResumeSelectionScreen({super.key, this.picker, this.analysisApi});

  final ResumeFilePicker? picker;
  final ResumeAnalysisApi? analysisApi;

  @override
  State<ResumeSelectionScreen> createState() => _ResumeSelectionScreenState();
}

class _ResumeSelectionScreenState extends State<ResumeSelectionScreen> {
  PickedResume? _resume;
  ResumeFileValidationError? _validationError;
  bool _isPicking = false;
  bool _understandsProcessing = false;
  late final TextEditingController _targetRoleController;

  ResumeFilePicker get _picker =>
      widget.picker ?? const PlatformResumeFilePicker();

  ResumeAnalysisApi get _analysisApi =>
      widget.analysisApi ?? HttpResumeAnalysisApi();

  @override
  void initState() {
    super.initState();
    _targetRoleController = TextEditingController();
  }

  @override
  void dispose() {
    _targetRoleController.dispose();
    super.dispose();
  }

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
                const _WorkflowStepHeader(),
                const SizedBox(height: 16),
                Text(
                  'Start with your resume',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a PDF or Word document up to 10 MiB. Airesume will upload it to the configured analysis server for feedback.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _buildResumeCard(context),
                if (_validationError case final error?) ...[
                  const SizedBox(height: 12),
                  _buildError(context, _messageFor(error)),
                ],
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
                        TextField(
                          controller: _targetRoleController,
                          maxLength: 200,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'e.g. Product designer',
                            helperText: 'Used only for this analysis.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  key: const ValueKey('analysis-consent'),
                  value: _understandsProcessing,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) =>
                      setState(() => _understandsProcessing = value ?? false),
                  title: const Text(
                    'I understand my resume text will be sent to the configured AI service for feedback.',
                  ),
                  subtitle: const Text(
                    'The app backend does not save the uploaded file. Review the AI provider’s privacy terms before using sensitive documents.',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _resume != null && _understandsProcessing
                      ? _beginAnalysis
                      : null,
                  child: const Text('Analyze resume'),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can replace or remove the selected file before analysis.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _open(context, const WorkflowIssuesScreen()),
                  child: const Text(
                    'Preview unsupported-file and retry states',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context) {
    final resume = _resume;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              resume == null ? Icons.upload_file_outlined : Icons.description,
              color: AppColors.teal,
              size: 36,
            ),
            const SizedBox(height: 12),
            if (resume == null) ...[
              Text(
                'No resume selected',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Select a PDF or DOCX file from your device.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ] else ...[
              Text(
                resume.name,
                key: const ValueKey('selected-resume-name'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '${resume.name.split('.').last.toUpperCase()} · ${_formatSize(resume.sizeBytes!)}',
                key: const ValueKey('selected-resume-details'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            if (_isPicking)
              const CircularProgressIndicator()
            else if (resume == null)
              OutlinedButton.icon(
                onPressed: _chooseResume,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Choose a resume'),
              )
            else
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _chooseResume,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Replace resume'),
                  ),
                  TextButton.icon(
                    onPressed: _removeResume,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove resume'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const ValueKey('resume-selection-error'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseResume() async {
    setState(() {
      _isPicking = true;
      _validationError = null;
    });

    try {
      final result = await _picker.pickResume();
      if (!mounted) return;
      if (result == null) {
        setState(() => _isPicking = false);
        return;
      }

      final validationError = ResumeFileValidator.validate(
        fileName: result.name,
        sizeBytes: result.sizeBytes,
      );
      setState(() {
        _isPicking = false;
        if (validationError == null) {
          _resume = result;
        } else {
          _validationError = validationError;
        }
      });
    } on ResumePickerAccessException {
      if (!mounted) return;
      setState(() {
        _isPicking = false;
        _validationError = ResumeFileValidationError.fileAccessFailed;
      });
    } on PlatformException {
      if (!mounted) return;
      setState(() {
        _isPicking = false;
        _validationError = ResumeFileValidationError.fileAccessFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPicking = false;
        _validationError = ResumeFileValidationError.fileAccessFailed;
      });
    }
  }

  void _removeResume() {
    setState(() {
      _resume = null;
      _validationError = null;
    });
  }

  void _beginAnalysis() {
    final selected = _resume;
    final source = selected?.source;
    if (selected == null) return;
    _open(
      context,
      AnalysisProgressScreen(
        api: _analysisApi,
        fileName: selected.name,
        readBytes: source == null
            ? _missingFileBytes
            : () => _readResumeBytes(source),
        targetRole: _targetRoleController.text.trim(),
      ),
    );
  }

  Future<Uint8List> _missingFileBytes() => Future.error(
    const ResumeAnalysisException(
      'The selected file is no longer available. Please choose it again.',
    ),
  );

  Future<Uint8List> _readResumeBytes(PlatformFile source) async {
    final currentSize = await source.length();
    if (currentSize == null ||
        currentSize <= 0 ||
        currentSize > ResumeFileValidator.maxSizeBytes) {
      throw const ResumeAnalysisException(
        'The selected file is empty, unavailable, or larger than 10 MiB. Choose it again.',
      );
    }
    return source.readAsBytes();
  }

  String _messageFor(ResumeFileValidationError error) => switch (error) {
    ResumeFileValidationError.unsupportedType =>
      'Choose a PDF or DOCX file. The previous selection is kept.',
    ResumeFileValidationError.sizeUnavailable => 'We could not check this file size. Choose it again or select another file. The previous selection is kept.',
    ResumeFileValidationError.fileAccessFailed => 'We could not open the file chooser. Check device access and try again. The previous selection is kept.',
    ResumeFileValidationError.emptyFile =>
      'This file is empty. Choose a different resume.',
    ResumeFileValidationError.fileTooLarge =>
      'This file exceeds the 10 MiB limit. The previous selection is kept.',
  };

  String _formatSize(int? bytes) {
    if (bytes == null) return 'Size unavailable';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KiB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MiB';
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _WorkflowStepHeader extends StatelessWidget {
  const _WorkflowStepHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.teal.withValues(alpha: 0.12),
          foregroundColor: AppColors.teal,
          child: const Text('1'),
        ),
        const SizedBox(width: 12),
        Text('Add your resume', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

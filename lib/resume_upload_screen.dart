import 'package:flutter/material.dart';

import 'resume_file_picker.dart';
import 'screens/resume_input_screen.dart';

class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({
    super.key,
    this.filePicker = const ResumeFilePicker(),
  });

  final ResumeFilePicker filePicker;

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  SelectedResumeFile? _selectedFile;
  String? _error;
  bool _isPicking = false;

  Future<void> _chooseFile() async {
    if (_isPicking) return;
    setState(() {
      _isPicking = true;
      _error = null;
    });

    try {
      final selected = await widget.filePicker.pick();
      if (!mounted) return;
      if (selected != null) setState(() => _selectedFile = selected);
    } on ResumeSelectionException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error =
              'Could not open this file. Check access and try again, '
              'or paste your resume text.';
        });
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  String _fileSize(int bytes) {
    if (bytes < 1024) return '$bytes bytes';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedFile;
    return Scaffold(
      appBar: AppBar(title: const Text('Upload resume')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            Text(
              'Choose a resume file',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text('PDF or DOCX, up to 5 MiB.'),
            const SizedBox(height: 24),
            if (selected != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.description_outlined),
                      const SizedBox(height: 12),
                      Text(
                        selected.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(_fileSize(selected.size)),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _isPicking
                            ? null
                            : () => setState(() {
                                _selectedFile = null;
                                _error = null;
                              }),
                        icon: const Icon(Icons.close),
                        label: const Text('Remove file'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_error != null) ...[
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed: _isPicking ? null : _chooseFile,
              icon: _isPicking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder_open_outlined),
              label: Text(
                _isPicking
                    ? 'Opening files…'
                    : selected == null
                    ? 'Choose file'
                    : 'Replace file',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Files are selected locally and are not uploaded. Text extraction '
              'and file analysis are not available yet. To run basic checks, '
              'paste your resume text.',
              style: TextStyle(color: Color(0xFF53615E), height: 1.5),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isPicking
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ResumeInputScreen(),
                      ),
                    ),
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Paste resume instead'),
            ),
          ],
        ),
      ),
    );
  }
}

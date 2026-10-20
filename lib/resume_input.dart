import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

const maxResumeBytes = 5 * 1024 * 1024;
const resumeExtensions = ['pdf', 'docx'];

typedef ResumePicker = Future<ResumeFile?> Function();

/// An in-session reference to a document. Contents are never uploaded here.
class ResumeFile {
  const ResumeFile({required this.name, required this.size, this.source});

  final String name;
  final int size;
  final PlatformFile? source;

  String get extension => name.split('.').last.toLowerCase();

  String? get validationError {
    if (!name.contains('.') || !resumeExtensions.contains(extension)) {
      return 'Choose a PDF or DOCX file.';
    }
    if (size <= 0) return 'This file is empty. Choose another resume.';
    if (size > maxResumeBytes) return 'Choose a file no larger than 5 MiB.';
    return null;
  }

  String get details =>
      '${extension.toUpperCase()} · ${(size / 1024).toStringAsFixed(1)} KiB';
}

Future<ResumeFile?> pickResumeFile() async {
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: resumeExtensions,
  );
  if (file == null) return null;
  final size = await file.length();
  if (size == null) throw StateError('File size unavailable');
  return ResumeFile(name: file.name, size: size, source: file);
}

class ResumeInput extends StatefulWidget {
  const ResumeInput({super.key, this.picker = pickResumeFile});

  final ResumePicker picker;

  @override
  State<ResumeInput> createState() => _ResumeInputState();
}

class _ResumeInputState extends State<ResumeInput> {
  ResumeFile? _file;
  String? _error;
  bool _picking = false;

  Future<void> _choose() async {
    if (_picking) return;
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      final file = await widget.picker();
      if (!mounted || file == null) return;
      setState(() {
        _error = file.validationError;
        if (_error == null) _file = file;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not access that file. Check access and try again.';
      });
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = _file;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (file != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected resume'),
                  const SizedBox(height: 8),
                  Text(
                    file.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(file.details),
                  TextButton.icon(
                    onPressed: _picking
                        ? null
                        : () => setState(() {
                            _file = null;
                            _error = null;
                          }),
                    icon: const Icon(Icons.close),
                    label: const Text('Remove resume'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        FilledButton.icon(
          onPressed: _picking ? null : _choose,
          icon: _picking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file_outlined),
          label: Text(
            _picking
                ? 'Opening files…'
                : file == null
                ? 'Choose a resume'
                : 'Replace resume',
          ),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
        const SizedBox(height: 12),
        const Text(
          'PDF or DOCX · Up to 5 MiB\nSelection stays on this device for this session. Upload and analysis are not available yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF687572), fontSize: 12, height: 1.5),
        ),
      ],
    );
  }
}

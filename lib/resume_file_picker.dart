import 'package:file_selector/file_selector.dart';

/// Local selection only; document extraction and uploading are separate work.
class ResumeFilePicker {
  const ResumeFilePicker({this.selectFile});

  static const maxFileBytes = 10 * 1024 * 1024;
  static const supportedExtensions = ['pdf', 'docx'];

  final Future<XFile?> Function()? selectFile;

  Future<SelectedResumeFile?> pick() async {
    final file = await (selectFile ?? _openResumeFile)();
    if (file == null) return null;

    final name = _safeFileName(file.name);
    final extension = name.split('.').last.toLowerCase();
    if (!name.contains('.') || !supportedExtensions.contains(extension)) {
      throw const ResumeSelectionException('Choose a PDF or DOCX file.');
    }

    final size = await file.length();
    if (size <= 0) {
      throw const ResumeSelectionException(
        'This file is empty. Choose another resume.',
      );
    }
    if (size > maxFileBytes) {
      throw const ResumeSelectionException(
        'This file is larger than 10 MB. Choose a smaller resume.',
      );
    }

    return SelectedResumeFile(file: file, name: name, size: size);
  }

  static String _safeFileName(String value) =>
      value.split(RegExp(r'[/\\]')).last;

  static Future<XFile?> _openResumeFile() => openFile(
    acceptedTypeGroups: const [
      XTypeGroup(
        label: 'Resume documents',
        extensions: supportedExtensions,
        mimeTypes: [
          'application/pdf',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ],
        uniformTypeIdentifiers: [
          'com.adobe.pdf',
          'org.openxmlformats.wordprocessingml.document',
        ],
      ),
    ],
  );
}

class SelectedResumeFile {
  const SelectedResumeFile({
    required this.file,
    required this.name,
    required this.size,
  });

  final XFile file;
  final String name;
  final int size;
}

class ResumeSelectionException implements Exception {
  const ResumeSelectionException(this.message);

  final String message;
}

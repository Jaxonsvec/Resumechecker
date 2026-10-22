import 'dart:typed_data';

import 'package:airesume/resume_file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('picker cancellation returns no selection', () async {
    final picker = ResumeFilePicker(selectFile: () async => null);
    expect(await picker.pick(), isNull);
  });

  for (final name in ['resume.pdf', 'resume.DOCX']) {
    test('accepts $name at the size limit without reading contents', () async {
      final file = SyntheticResumeFile(
        name,
        size: ResumeFilePicker.maxFileBytes,
      );
      final picker = ResumeFilePicker(selectFile: () async => file);
      final selection = await picker.pick();
      expect(selection?.file, same(file));
      expect(selection?.size, ResumeFilePicker.maxFileBytes);
    });
  }

  for (final name in ['resume.txt', 'resume', 'resume.pdf.exe']) {
    test('rejects unsupported filename $name', () async {
      final picker = ResumeFilePicker(
        selectFile: () async => SyntheticResumeFile(name),
      );
      await expectLater(
        picker.pick(),
        throwsA(
          isA<ResumeSelectionException>().having(
            (error) => error.message,
            'message',
            'Choose a PDF or DOCX file.',
          ),
        ),
      );
    });
  }

  test('rejects a file one byte over the limit', () async {
    final picker = ResumeFilePicker(
      selectFile: () async => SyntheticResumeFile(
        'large.pdf',
        size: ResumeFilePicker.maxFileBytes + 1,
      ),
    );
    await expectLater(picker.pick(), throwsA(isA<ResumeSelectionException>()));
  });

  test('rejects an empty document', () async {
    final picker = ResumeFilePicker(
      selectFile: () async => SyntheticResumeFile('empty.docx', size: 0),
    );
    await expectLater(picker.pick(), throwsA(isA<ResumeSelectionException>()));
  });
}

/// Synthetic metadata only; never reads or stores a real resume.
class SyntheticResumeFile extends XFile {
  SyntheticResumeFile(String name, {this.size = 2048})
    : super('/synthetic/$name', name: name);

  final int size;

  @override
  Future<int> length() async => size;

  @override
  Future<Uint8List> readAsBytes() =>
      throw StateError('Selection must not read document contents.');
}

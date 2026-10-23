import 'dart:async';

import 'package:airesume/resume_file_picker.dart';
import 'package:airesume/resume_upload_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'resume_file_picker_test.dart' show SyntheticResumeFile;

void main() {
  testWidgets('choose, cancel, reject, replace, remove, and paste fallback', (
    tester,
  ) async {
    XFile? nextFile = SyntheticResumeFile('resume.pdf');
    await tester.pumpWidget(
      MaterialApp(
        home: ResumeUploadScreen(
          filePicker: ResumeFilePicker(selectFile: () async => nextFile),
        ),
      ),
    );

    await tester.tap(find.text('Choose file'));
    await tester.pumpAndSettle();
    expect(find.text('resume.pdf'), findsOneWidget);
    expect(find.text('2.0 KB'), findsOneWidget);

    nextFile = null;
    await tester.tap(find.text('Replace file'));
    await tester.pumpAndSettle();
    expect(find.text('resume.pdf'), findsOneWidget);
    expect(find.textContaining('Could not open'), findsNothing);

    nextFile = SyntheticResumeFile('resume.txt');
    await tester.tap(find.text('Replace file'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a PDF or DOCX file.'), findsOneWidget);
    expect(find.text('resume.pdf'), findsOneWidget);

    nextFile = SyntheticResumeFile('updated.docx', size: 4096);
    await tester.tap(find.text('Replace file'));
    await tester.pumpAndSettle();
    expect(find.text('updated.docx'), findsOneWidget);
    expect(find.text('4.0 KB'), findsOneWidget);
    expect(find.text('resume.pdf'), findsNothing);
    expect(find.text('Choose a PDF or DOCX file.'), findsNothing);

    await tester.tap(find.text('Remove file'));
    await tester.pumpAndSettle();
    expect(find.text('updated.docx'), findsNothing);
    expect(find.text('Choose file'), findsOneWidget);

    await tester.tap(find.text('Paste resume instead'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Resume text'), findsOneWidget);
  });

  testWidgets('permission errors allow retry', (tester) async {
    var fail = true;
    await tester.pumpWidget(
      MaterialApp(
        home: ResumeUploadScreen(
          filePicker: ResumeFilePicker(
            selectFile: () async {
              if (fail) throw PlatformException(code: 'permission_denied');
              return SyntheticResumeFile('retry.pdf');
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Choose file'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Check access and try again'), findsOneWidget);
    expect(find.textContaining('permission_denied'), findsNothing);

    fail = false;
    await tester.tap(find.text('Choose file'));
    await tester.pumpAndSettle();
    expect(find.text('retry.pdf'), findsOneWidget);
    expect(find.textContaining('Check access and try again'), findsNothing);
  });

  testWidgets(
    'file metadata access failure preserves selection and allows retry',
    (tester) async {
      XFile nextFile = SyntheticResumeFile('original.pdf');
      await tester.pumpWidget(
        MaterialApp(
          home: ResumeUploadScreen(
            filePicker: ResumeFilePicker(selectFile: () async => nextFile),
          ),
        ),
      );
      await tester.tap(find.text('Choose file'));
      await tester.pumpAndSettle();

      nextFile = _UnreadableResumeFile();
      await tester.tap(find.text('Replace file'));
      await tester.pumpAndSettle();
      expect(find.text('original.pdf'), findsOneWidget);
      expect(find.textContaining('Check access and try again'), findsOneWidget);
      expect(find.textContaining('private native path'), findsNothing);

      nextFile = SyntheticResumeFile('replacement.pdf');
      await tester.tap(find.text('Replace file'));
      await tester.pumpAndSettle();
      expect(find.text('replacement.pdf'), findsOneWidget);
      expect(find.textContaining('Check access and try again'), findsNothing);
    },
  );

  testWidgets('initial cancellation keeps the screen ready to choose', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResumeUploadScreen(
          filePicker: ResumeFilePicker(selectFile: () async => null),
        ),
      ),
    );
    await tester.tap(find.text('Choose file'));
    await tester.pumpAndSettle();
    expect(find.text('Choose file'), findsOneWidget);
    expect(find.text('Replace file'), findsNothing);
    expect(find.textContaining('Could not open'), findsNothing);
  });

  testWidgets(
    'prevents duplicate picks and ignores completion after disposal',
    (tester) async {
      final pending = Completer<XFile?>();
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: ResumeUploadScreen(
            filePicker: ResumeFilePicker(
              selectFile: () {
                calls++;
                return pending.future;
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Choose file'));
      await tester.pump();
      expect(find.text('Opening files…'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(calls, 1);

      await tester.pumpWidget(const SizedBox());
      pending.complete(SyntheticResumeFile('late.pdf'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}

class _UnreadableResumeFile extends SyntheticResumeFile {
  _UnreadableResumeFile() : super('unreadable.pdf');

  @override
  Future<int> length() async => throw Exception('private native path');
}

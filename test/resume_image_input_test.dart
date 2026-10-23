import 'dart:typed_data';

import 'package:airesume/screens/resume_image_input_screen.dart';
import 'package:airesume/services/resume_image_ocr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  testWidgets('previews editable text extracted from a selected picture', (
    tester,
  ) async {
    ImageSource? selectedSource;
    await tester.pumpWidget(
      MaterialApp(
        home: ResumeImageInputScreen(
          imagePicker: (source) async {
            selectedSource = source;
            return XFile.fromData(
              Uint8List.fromList([1, 2, 3]),
              path: 'resume.png',
              name: 'resume.png',
            );
          },
          ocr: _FakeOcr('Taylor Example\nExperience'),
        ),
      ),
    );
    await tester.tap(find.text('Choose picture'));
    await tester.pumpAndSettle();
    expect(selectedSource, ImageSource.gallery);
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.controller!.text, 'Taylor Example\nExperience');
    await tester.enterText(find.byType(TextField).first, 'Corrected OCR text');
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'Corrected OCR text',
    );
  });

  testWidgets('shows a helpful empty OCR result message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResumeImageInputScreen(
          imagePicker: (_) async => XFile.fromData(
            Uint8List.fromList([1, 2, 3]),
            path: 'resume.png',
            name: 'resume.png',
          ),
          ocr: _FakeOcr('  '),
        ),
      ),
    );
    await tester.tap(find.text('Choose picture'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No readable text was found'), findsOneWidget);
  });
}

class _FakeOcr implements ResumeImageOcr {
  _FakeOcr(this.value);
  final String value;
  @override
  Future<String> recognizeText(String imagePath) async => value;
}

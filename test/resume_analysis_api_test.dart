import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:airesume/models/resume_analysis.dart';
import 'package:airesume/services/resume_analysis_api.dart';

void main() {
  final analysisJson = {
    'summary': 'A focused resume with relevant experience.',
    'strengths': [
      {'title': 'Leadership', 'evidence': 'Led a team of four.'},
    ],
    'improvements': [
      {
        'title': 'Show measurable impact',
        'evidence': 'The role lists responsibilities without outcomes.',
        'recommendation': 'Add a truthful result or scale where available.',
      },
    ],
    'missing_information': ['Education details'],
  };

  test(
    'uploads a PDF and parses structured analysis without logging contents',
    () async {
      http.Request? capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({'analysis': analysisJson}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final api = HttpResumeAnalysisApi(
        client: client,
        baseUrl: 'http://localhost:3000',
      );

      final result = await api.analyze(
        fileName: 'Resume.pdf',
        readBytes: () async =>
            Uint8List.fromList('%PDF-1.4\nsynthetic'.codeUnits),
        targetRole: 'Product engineer',
      );

      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.url.path, '/api/v1/analyses');
      expect(
        capturedRequest!.headers['content-type'],
        startsWith('multipart/form-data;'),
      );
      expect(
        capturedRequest!.body,
        contains('name="resume"; filename="Resume.pdf"'),
      );
      expect(capturedRequest!.body, contains('name="targetRole"'));
      expect(capturedRequest!.body, contains('Product engineer'));
      expect(result.summary, analysisJson['summary']);
      expect(result.strengths.single.title, 'Leadership');
      expect(
        result.improvements.single.recommendation,
        contains('truthful result'),
      );
      expect(result.missingInformation, ['Education details']);
      client.close();
    },
  );

  test('maps provider-unavailable errors to user-safe copy', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'error': {
            'code': 'ANALYSIS_UNAVAILABLE',
            'message': 'Server-specific details are not shown.',
          },
        }),
        503,
      ),
    );
    final api = HttpResumeAnalysisApi(
      client: client,
      baseUrl: 'http://localhost',
    );

    await expectLater(
      api.analyze(
        fileName: 'Resume.docx',
        readBytes: () async => Uint8List.fromList([0x50, 0x4b, 0x03, 0x04]),
      ),
      throwsA(
        isA<ResumeAnalysisException>().having(
          (error) => error.message,
          'message',
          contains('not configured'),
        ),
      ),
    );
    client.close();
  });

  test('rejects malformed analysis response data', () {
    expect(
      () => ResumeAnalysis.fromJson({'summary': 'Missing sections'}),
      throwsFormatException,
    );
  });
}

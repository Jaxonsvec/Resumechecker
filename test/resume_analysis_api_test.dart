import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode({
          'error': {
            'code': 'ANALYSIS_UNAVAILABLE',
            'message':
                'Set OPENAI_API_KEY in backend/.env and restart the backend.',
          },
        }),
        503,
      );
    });
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
          contains('backend/.env'),
        ),
      ),
    );
    client.close();
  });

  test('defaults to the host-loopback URL for Android and Windows', () async {
    final originalPlatform = debugDefaultTargetPlatformOverride;
    const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
    final configuredUri = configuredBaseUrl.isEmpty
        ? null
        : Uri.tryParse(configuredBaseUrl);
    final requestedUrls = <Uri>[];
    final client = MockClient((request) async {
      requestedUrls.add(request.url);
      return http.Response(jsonEncode({'analysis': analysisJson}), 200);
    });

    try {
      for (final entry in [
        (TargetPlatform.android, '10.0.2.2'),
        (TargetPlatform.windows, 'localhost'),
      ]) {
        debugDefaultTargetPlatformOverride = entry.$1;
        final api = HttpResumeAnalysisApi(client: client);
        await api.analyze(
          fileName: 'Resume.pdf',
          readBytes: () async => Uint8List.fromList([1]),
        );
        expect(requestedUrls.last.host, configuredUri?.host ?? entry.$2);
        expect(
          requestedUrls.last.port,
          configuredUri?.hasPort == true ? configuredUri!.port : 3000,
        );
      }
    } finally {
      debugDefaultTargetPlatformOverride = originalPlatform;
      client.close();
    }
  });

  const configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  test(
    'uses the API_BASE_URL compile-time override',
    () async {
      Uri? requestedUrl;
      final client = MockClient((request) async {
        requestedUrl = request.url;
        return http.Response(jsonEncode({'analysis': analysisJson}), 200);
      });
      final api = HttpResumeAnalysisApi(client: client);

      await api.analyze(
        fileName: 'Resume.pdf',
        readBytes: () async => Uint8List.fromList([1]),
      );

      expect(requestedUrl, Uri.parse('$configuredBaseUrl/api/v1/analyses'));
      client.close();
    },
    skip: configuredBaseUrl.isEmpty
        ? 'Run with --dart-define=API_BASE_URL=http://example:3000'
        : false,
  );

  test('rejects malformed analysis response data', () {
    expect(
      () => ResumeAnalysis.fromJson({'summary': 'Missing sections'}),
      throwsFormatException,
    );
  });
}

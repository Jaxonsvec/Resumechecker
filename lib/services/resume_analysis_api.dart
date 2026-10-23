import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/resume_analysis.dart';
import 'resume_file_picker.dart';

abstract interface class ResumeAnalysisApi {
  Future<ResumeAnalysis> analyze({
    required String fileName,
    required Future<Uint8List> Function() readBytes,
    String? targetRole,
  });
}

class HttpResumeAnalysisApi implements ResumeAnalysisApi {
  HttpResumeAnalysisApi({http.Client? client, String? baseUrl})
    : this._(client, baseUrl ?? _defaultBaseUrl);

  HttpResumeAnalysisApi._(this._client, this._baseUrl);

  final http.Client? _client;
  final String _baseUrl;

  @override
  Future<ResumeAnalysis> analyze({
    required String fileName,
    required Future<Uint8List> Function() readBytes,
    String? targetRole,
  }) async {
    final client = _client ?? http.Client();
    final ownsClient = _client == null;
    try {
      final bytes = await readBytes();
      final validationError = ResumeFileValidator.validate(
        fileName: fileName,
        sizeBytes: bytes.length,
      );
      if (validationError != null) {
        throw const ResumeAnalysisException(
          'The selected file is no longer available. Please choose it again.',
        );
      }
      final cleanedTargetRole = targetRole?.trim() ?? '';
      if (cleanedTargetRole.length > 200) {
        throw const ResumeAnalysisException(
          'The target role must be 200 characters or fewer.',
        );
      }

      final uri = Uri.parse('$_baseUrl/api/v1/analyses');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes('resume', bytes, filename: fileName),
        );
      if (cleanedTargetRole.isNotEmpty) {
        request.fields['targetRole'] = cleanedTargetRole;
      }

      final streamedResponse = await client
          .send(request)
          .timeout(const Duration(minutes: 3, seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      final payload = _decodeJson(response.bodyBytes);
      if (response.statusCode != 200) {
        throw _apiException(payload, response.statusCode);
      }
      final analysis = payload['analysis'];
      if (analysis is! Map<String, dynamic>) {
        throw const ResumeAnalysisException(
          'The analysis service returned an incomplete result. Please try again.',
        );
      }
      try {
        return ResumeAnalysis.fromJson(analysis);
      } on FormatException {
        throw const ResumeAnalysisException(
          'The analysis service returned an incomplete result. Please try again.',
        );
      }
    } on ResumeAnalysisException {
      rethrow;
    } on http.ClientException {
      throw const ResumeAnalysisException(
        'Could not reach the analysis server. Check the connection and try again.',
      );
    } on TimeoutException {
      throw const ResumeAnalysisException(
        'The analysis server took too long to respond. Please try again.',
      );
    } on FormatException {
      throw const ResumeAnalysisException(
        'The analysis server returned an unreadable response. Please try again.',
      );
    } on Exception {
      throw const ResumeAnalysisException(
        'Could not read or send the selected file. Choose it again and retry.',
      );
    } finally {
      if (ownsClient) client.close();
    }
  }

  Map<String, dynamic> _decodeJson(List<int> bytes) {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('Expected a JSON object.');
  }

  ResumeAnalysisException _apiException(
    Map<String, dynamic> payload,
    int statusCode,
  ) {
    final error = payload['error'];
    final code = error is Map<String, dynamic> ? error['code'] : null;
    final message = switch (code) {
      'FILE_TOO_LARGE' => 'This resume exceeds the server’s 10 MiB limit.',
      'UNSUPPORTED_FILE_TYPE' ||
      'INVALID_FILE' => 'Choose a valid PDF or DOCX resume.',
      'NO_EXTRACTABLE_TEXT' => 'This PDF has no selectable text. Scanned image PDFs are not supported yet.',
      'INVALID_RESUME_TEXT' =>
        'We could not find enough readable text in this resume.',
      'ANALYSIS_UNAVAILABLE' => 'Resume analysis is not configured. Set OPENAI_API_KEY in backend/.env and restart the backend.',
      'OLLAMA_UNAVAILABLE' =>
        'The local Ollama service is unavailable. Start Ollama and check OLLAMA_BASE_URL.',
      'OLLAMA_MODEL_NOT_FOUND' =>
        'The configured Ollama model is not installed. Pull OLLAMA_MODEL and retry.',
      'ANALYSIS_BUSY' || 'ANALYSIS_TIMEOUT' =>
        'The analysis service is busy. Please try again in a moment.',
      _ when statusCode >= 500 =>
        'The analysis could not be completed. Please try again.',
      _ => 'The resume could not be analyzed. Check the file and try again.',
    };
    return ResumeAnalysisException(message);
  }

  static String get _defaultBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:3000'
        : 'http://localhost:3000';
  }
}

class ResumeAnalysisException implements Exception {
  const ResumeAnalysisException(this.message);

  final String message;

  @override
  String toString() => message;
}

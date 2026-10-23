import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import '../models/picked_resume.dart';

abstract interface class ResumeFilePicker {
  Future<PickedResume?> pickResume();
}

class PlatformResumeFilePicker implements ResumeFilePicker {
  const PlatformResumeFilePicker();

  @override
  Future<PickedResume?> pickResume() async {
    PlatformFile? file;
    try {
      file = await FilePicker.pickFile(
        dialogTitle: 'Choose your resume',
        type: FileType.custom,
        allowedExtensions: ResumeFileValidator.allowedExtensions,
      );
    } on PlatformException {
      throw const ResumePickerAccessException();
    }
    if (file == null) return null;

    int? sizeBytes;
    try {
      sizeBytes = file.lengthSync() ?? await file.length();
    } catch (_) {
      // The screen reports an unavailable-size validation message.
    }
    return PickedResume(name: file.name, sizeBytes: sizeBytes, source: file);
  }
}

class ResumePickerAccessException implements Exception {
  const ResumePickerAccessException();
}

enum ResumeFileValidationError {
  unsupportedType,
  sizeUnavailable,
  fileAccessFailed,
  emptyFile,
  fileTooLarge,
}

class ResumeFileValidator {
  ResumeFileValidator._();

  static const allowedExtensions = <String>['pdf', 'docx'];
  static const maxSizeBytes = 10 * 1024 * 1024;

  static ResumeFileValidationError? validate({
    required String fileName,
    required int? sizeBytes,
  }) {
    final dotIndex = fileName.lastIndexOf('.');
    final extension = dotIndex < 0
        ? ''
        : fileName.substring(dotIndex + 1).toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      return ResumeFileValidationError.unsupportedType;
    }
    if (sizeBytes == null) {
      return ResumeFileValidationError.sizeUnavailable;
    }
    if (sizeBytes < 0) {
      return ResumeFileValidationError.sizeUnavailable;
    }
    if (sizeBytes == 0) {
      return ResumeFileValidationError.emptyFile;
    }
    if (sizeBytes > maxSizeBytes) {
      return ResumeFileValidationError.fileTooLarge;
    }
    return null;
  }
}

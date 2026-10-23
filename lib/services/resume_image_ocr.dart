import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract interface class ResumeImageOcr {
  Future<String> recognizeText(String imagePath);
}

class MlKitResumeImageOcr implements ResumeImageOcr {
  @override
  Future<String> recognizeText(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      return result.text;
    } finally {
      await recognizer.close();
    }
  }
}

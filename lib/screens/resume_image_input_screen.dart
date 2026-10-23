import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/resume_analysis_api.dart';
import '../services/resume_image_ocr.dart';
import 'analysis_results_screen.dart';

class ResumeImageInputScreen extends StatefulWidget {
  const ResumeImageInputScreen({
    super.key,
    this.api,
    this.imagePicker,
    this.ocr,
  });
  final ResumeAnalysisApi? api;
  final Future<XFile?> Function(ImageSource source)? imagePicker;
  final ResumeImageOcr? ocr;
  @override
  State<ResumeImageInputScreen> createState() => _ResumeImageInputScreenState();
}

class _ResumeImageInputScreenState extends State<ResumeImageInputScreen> {
  final _picker = ImagePicker();
  late final ResumeImageOcr _ocr = widget.ocr ?? MlKitResumeImageOcr();
  final _text = TextEditingController();
  final _role = TextEditingController();
  String? _imagePath;
  bool _reading = false;
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    _role.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final image = widget.imagePicker == null
          ? await _picker.pickImage(
              source: source,
              imageQuality: 90,
              maxWidth: 3000,
              maxHeight: 3000,
            )
          : await widget.imagePicker!(source);
      if (image == null || !mounted) return;
      final extension = image.name.toLowerCase().split('.').last;
      if (!const {'jpg', 'jpeg', 'png'}.contains(extension)) {
        _message('Choose a JPG, JPEG, or PNG resume picture.');
        return;
      }
      if (await image.length() > 15 * 1024 * 1024) {
        _message(
          'This image is too large to process. Choose an image under 15 MiB.',
        );
        return;
      }
      setState(() {
        _imagePath = image.path;
        _reading = true;
        _text.clear();
      });
      final extracted = (await _ocr.recognizeText(image.path)).trim();
      if (!mounted) return;
      setState(() {
        _text.text = extracted;
        _reading = false;
      });
      if (extracted.isEmpty) {
        _message(
          'No readable text was found. Try a sharper, upright photo with good lighting.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _reading = false);
      _message(
        'This image could not be read. Try another clear JPG or PNG, or rotate it upright and try again.',
      );
    }
  }

  Future<void> _analyze() async {
    if (_text.text.trim().isEmpty) {
      _message('Select a readable image before continuing.');
      return;
    }
    final consent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send extracted resume text for analysis?'),
        content: const Text(
          'OCR runs on this device. If you continue, the corrected text will be sent to the AI provider configured for your Airesume backend.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (consent != true || !mounted) return;
    setState(() => _sending = true);
    try {
      final result = await (widget.api ?? HttpResumeAnalysisApi()).analyzeText(
        resumeText: _text.text,
        targetRole: _role.text,
      );
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AnalysisResultsScreen(
              result: result,
              resumeName: 'Image resume',
            ),
          ),
        );
      }
    } on ResumeAnalysisException catch (error) {
      if (mounted) _message(error.message);
    } catch (_) {
      if (mounted) {
        _message('The image resume could not be analyzed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Resume photo')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Choose a JPG/PNG image or take a picture. Text recognition runs locally on this device. Review and correct the extracted text before sending it for AI analysis.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _reading ? null : () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose picture'),
            ),
            OutlinedButton.icon(
              onPressed: _reading ? null : () => _pick(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Take picture'),
            ),
          ],
        ),
        if (_imagePath != null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Picture selected. Review and correct the extracted text below.',
            ),
          ),
        if (_reading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _text,
          minLines: 12,
          maxLines: null,
          decoration: const InputDecoration(
            labelText: 'Review and correct extracted text',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _role,
          decoration: const InputDecoration(
            labelText: 'Target role (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _reading || _sending ? null : _analyze,
          child: _sending
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Analyzing…'),
                  ],
                )
              : const Text('Analyze extracted text'),
        ),
      ],
    ),
  );
}

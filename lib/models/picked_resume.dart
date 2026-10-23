import 'package:file_picker/file_picker.dart';

/// Metadata for a resume selected locally on the device.
///
/// [source] is retained for a future upload flow. The selection screen only
/// inspects the filename and byte length; it does not read file contents.
class PickedResume {
  const PickedResume({
    required this.name,
    required this.sizeBytes,
    this.source,
  });

  final String name;
  final int? sizeBytes;
  final PlatformFile? source;
}

/// What the user handed us. Exactly three kinds, per the design doc.
sealed class InputSource {
  const InputSource();
}

/// Text pasted or typed directly.
class TextInput extends InputSource {
  const TextInput(this.text);

  final String text;
}

/// A file picked from the device (txt/md/csv, pdf, docx, or an image).
class FileInput extends InputSource {
  const FileInput({required this.path, required this.name});

  /// Local, readable path (the picker copies content: URIs to cache).
  final String path;

  /// Display name with extension.
  final String name;

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }
}

/// A photo just taken with the camera, or picked from the photo library.
class CameraInput extends InputSource {
  const CameraInput({required this.path, required this.name});

  final String path;

  /// Display name: when the photo was taken or picked, e.g.
  /// `2026-09-17 15:28:04.jpg`.
  final String name;
}

/// Thrown when a file type or content cannot be turned into text.
class UnsupportedInputException implements Exception {
  const UnsupportedInputException(this.reason);

  /// Machine-readable reason: `extension`, `empty`.
  final String reason;

  @override
  String toString() => 'UnsupportedInputException($reason)';
}

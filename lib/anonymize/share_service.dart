import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Hands the anonymized text to other apps.
class ShareService {
  const ShareService();

  /// Share a file: the `.txt`, or the redacted PDF, Word file or image.
  Future<void> shareFile(String path, String fileName, {String mimeType = 'text/plain'}) =>
      SharePlus.instance.share(ShareParams(
        files: [XFile(path, mimeType: mimeType, name: fileName)],
        fileNameOverrides: [fileName],
      ));

  /// Share as plain text for apps that take text, not files.
  Future<void> shareText(String text) =>
      SharePlus.instance.share(ShareParams(text: text));

  Future<void> copy(String text) => Clipboard.setData(ClipboardData(text: text));
}

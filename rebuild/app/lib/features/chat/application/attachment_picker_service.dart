import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

import '../domain/chat_models.dart';

class AttachmentPickerException implements Exception {
  final String message;

  const AttachmentPickerException(this.message);

  @override
  String toString() => message;
}

abstract class AttachmentPickerService {
  Future<List<PendingAttachmentDraft>> pickAttachments();
}

class FilePickerAttachmentPicker implements AttachmentPickerService {
  final Uuid _uuid;

  FilePickerAttachmentPicker({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  @override
  Future<List<PendingAttachmentDraft>> pickAttachments() async {
    final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const <String>[
        'pdf',
        'txt',
        'md',
        'docx',
        'png',
        'jpg',
        'jpeg',
        'webp',
        'heic',
        'heif',
      ],
    );
    if (pickerResult == null) {
      return <PendingAttachmentDraft>[];
    }

    final List<PendingAttachmentDraft> drafts = <PendingAttachmentDraft>[];
    for (final PlatformFile platformFile in pickerResult.files) {
      final String? localPath = platformFile.path;
      if (localPath == null || localPath.trim().isEmpty) {
        throw const AttachmentPickerException(
          'Selected attachments must expose a local path on this platform.',
        );
      }

      final String mimeType =
          lookupMimeType(localPath) ??
          _fallbackMimeType(platformFile.extension ?? platformFile.name);
      final ChatAttachmentKind? kind = _kindForMimeType(mimeType);
      if (kind == null) {
        throw AttachmentPickerException(
          'Unsupported attachment type for ${platformFile.name}.',
        );
      }

      drafts.add(
        PendingAttachmentDraft(
          id: _uuid.v4(),
          kind: kind,
          displayName: platformFile.name,
          mimeType: mimeType,
          localPath: localPath,
          byteSize: platformFile.size,
        ),
      );
    }

    return drafts;
  }

  String _fallbackMimeType(String fileNameOrExtension) {
    final String normalizedValue = fileNameOrExtension.toLowerCase();
    if (normalizedValue.endsWith('.pdf') || normalizedValue == 'pdf') {
      return 'application/pdf';
    }
    if (normalizedValue.endsWith('.txt') || normalizedValue == 'txt') {
      return 'text/plain';
    }
    if (normalizedValue.endsWith('.md') || normalizedValue == 'md') {
      return 'text/markdown';
    }
    if (normalizedValue.endsWith('.docx') || normalizedValue == 'docx') {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (normalizedValue.endsWith('.png') || normalizedValue == 'png') {
      return 'image/png';
    }
    if (normalizedValue.endsWith('.jpg') ||
        normalizedValue.endsWith('.jpeg') ||
        normalizedValue == 'jpg' ||
        normalizedValue == 'jpeg') {
      return 'image/jpeg';
    }
    if (normalizedValue.endsWith('.webp') || normalizedValue == 'webp') {
      return 'image/webp';
    }
    if (normalizedValue.endsWith('.heic') || normalizedValue == 'heic') {
      return 'image/heic';
    }
    if (normalizedValue.endsWith('.heif') || normalizedValue == 'heif') {
      return 'image/heif';
    }
    return 'application/octet-stream';
  }

  ChatAttachmentKind? _kindForMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return ChatAttachmentKind.image;
    }
    if (mimeType == 'application/pdf' ||
        mimeType == 'text/plain' ||
        mimeType == 'text/markdown' ||
        mimeType ==
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return ChatAttachmentKind.document;
    }
    return null;
  }
}

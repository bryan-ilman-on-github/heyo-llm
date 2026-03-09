import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

import '../data/chat_api_client.dart';
import '../data/local/app_database.dart';
import '../domain/chat_models.dart';

class AttachmentIngestionException implements Exception {
  final String message;

  const AttachmentIngestionException(this.message);

  @override
  String toString() => message;
}

class AttachmentIngestionResult {
  final List<ChatAttachmentRecord> attachments;

  const AttachmentIngestionResult({required this.attachments});
}

class LocalAttachmentExtraction {
  final PendingAttachmentDraft attachment;
  final String? rawText;
  final AttachmentInspectRequestItem? inspectItem;
  final String? failureReason;

  const LocalAttachmentExtraction({
    required this.attachment,
    required this.rawText,
    required this.inspectItem,
    required this.failureReason,
  });

  bool get isFailure => failureReason != null;
}

abstract class PdfEmbeddedTextExtractor {
  Future<String> extractText(String filePath);
}

class SyncfusionPdfEmbeddedTextExtractor implements PdfEmbeddedTextExtractor {
  @override
  Future<String> extractText(String filePath) async {
    final File file = File(filePath);
    final List<int> bytes = await file.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    try {
      final String extractedText = PdfTextExtractor(document).extractText();
      return extractedText.trim();
    } finally {
      document.dispose();
    }
  }
}

class AttachmentIngestionService {
  final AppDatabase appDatabase;
  final ChatApiClient chatApiClient;
  final PdfEmbeddedTextExtractor pdfEmbeddedTextExtractor;

  AttachmentIngestionService({
    required this.appDatabase,
    required this.chatApiClient,
    PdfEmbeddedTextExtractor? pdfEmbeddedTextExtractor,
  }) : pdfEmbeddedTextExtractor =
           pdfEmbeddedTextExtractor ?? SyncfusionPdfEmbeddedTextExtractor();

  Future<AttachmentIngestionResult> ingestAttachments({
    required String messageId,
    required String messageText,
    required List<PendingAttachmentDraft> pendingAttachments,
  }) async {
    if (pendingAttachments.isEmpty) {
      return const AttachmentIngestionResult(
        attachments: <ChatAttachmentRecord>[],
      );
    }

    await appDatabase.insertPendingAttachments(
      messageId: messageId,
      pendingAttachments: pendingAttachments,
    );

    final List<LocalAttachmentExtraction> extractionResults =
        <LocalAttachmentExtraction>[];
    for (final PendingAttachmentDraft attachment in pendingAttachments) {
      try {
        extractionResults.add(await _extractAttachment(attachment));
      } catch (error) {
        extractionResults.add(
          LocalAttachmentExtraction(
            attachment: attachment,
            rawText: null,
            inspectItem: null,
            failureReason: error.toString(),
          ),
        );
      }
    }

    final List<AttachmentInspectRequestItem> inspectItems = extractionResults
        .where((LocalAttachmentExtraction extraction) => !extraction.isFailure)
        .map((LocalAttachmentExtraction extraction) => extraction.inspectItem)
        .whereType<AttachmentInspectRequestItem>()
        .toList(growable: false);

    for (final LocalAttachmentExtraction extraction in extractionResults.where(
      (LocalAttachmentExtraction extraction) => extraction.isFailure,
    )) {
      await appDatabase.markAttachmentFailed(
        attachmentId: extraction.attachment.id,
        failureReason:
            extraction.failureReason ?? 'Attachment processing failed.',
      );
    }

    List<AttachmentInspectResult> inspectResults = <AttachmentInspectResult>[];
    if (inspectItems.isNotEmpty) {
      try {
        inspectResults = await chatApiClient.inspectAttachments(
          messageText: messageText,
          attachments: inspectItems,
        );
      } catch (error) {
        final String failureReason = error.toString();
        for (final AttachmentInspectRequestItem inspectItem in inspectItems) {
          await appDatabase.markAttachmentFailed(
            attachmentId: inspectItem.clientAttachmentId,
            failureReason: failureReason,
          );
        }
        rethrow;
      }
    }

    final Map<String, LocalAttachmentExtraction> extractionByAttachmentId =
        <String, LocalAttachmentExtraction>{
          for (final LocalAttachmentExtraction extraction in extractionResults)
            extraction.attachment.id: extraction,
        };
    final Set<String> processedAttachmentIds = <String>{};

    for (final AttachmentInspectResult inspectResult in inspectResults) {
      processedAttachmentIds.add(inspectResult.clientAttachmentId);
      if (inspectResult.status == ChatAttachmentStatus.failed ||
          inspectResult.memoryWritePlan == null) {
        await appDatabase.markAttachmentFailed(
          attachmentId: inspectResult.clientAttachmentId,
          failureReason:
              inspectResult.failureReason ??
              'Attachment inspection did not return a usable summary.',
        );
        continue;
      }

      final LocalAttachmentExtraction? extraction =
          extractionByAttachmentId[inspectResult.clientAttachmentId];
      final String summaryMemoryId = await appDatabase.insertMemoryPlan(
        sourceMessageId: messageId,
        memoryWritePlan: inspectResult.memoryWritePlan!,
      );
      await appDatabase.markAttachmentReady(
        attachmentId: inspectResult.clientAttachmentId,
        rawText: extraction?.rawText,
        summary: inspectResult.summary,
        summaryMemoryId: summaryMemoryId,
      );
    }

    for (final AttachmentInspectRequestItem inspectItem in inspectItems) {
      if (processedAttachmentIds.contains(inspectItem.clientAttachmentId)) {
        continue;
      }
      await appDatabase.markAttachmentFailed(
        attachmentId: inspectItem.clientAttachmentId,
        failureReason: 'Attachment inspection did not return a result.',
      );
    }

    final List<ChatAttachmentRecord> attachments = await appDatabase
        .fetchAttachmentsForMessage(messageId);
    return AttachmentIngestionResult(attachments: attachments);
  }

  Future<LocalAttachmentExtraction> _extractAttachment(
    PendingAttachmentDraft attachment,
  ) async {
    if (attachment.kind == ChatAttachmentKind.image) {
      final File imageFile = File(attachment.localPath);
      final String imageBase64 = base64Encode(await imageFile.readAsBytes());
      return LocalAttachmentExtraction(
        attachment: attachment,
        rawText: null,
        inspectItem: AttachmentInspectRequestItem(
          clientAttachmentId: attachment.id,
          kind: attachment.kind,
          fileName: attachment.displayName,
          mimeType: attachment.mimeType,
          documentText: null,
          imageBase64: imageBase64,
        ),
        failureReason: null,
      );
    }

    final String rawText = await _extractDocumentText(attachment);
    if (rawText.trim().isEmpty) {
      return LocalAttachmentExtraction(
        attachment: attachment,
        rawText: null,
        inspectItem: null,
        failureReason:
            'No embedded text was found in ${attachment.displayName}. OCR is disabled.',
      );
    }

    return LocalAttachmentExtraction(
      attachment: attachment,
      rawText: rawText,
      inspectItem: AttachmentInspectRequestItem(
        clientAttachmentId: attachment.id,
        kind: attachment.kind,
        fileName: attachment.displayName,
        mimeType: attachment.mimeType,
        documentText: rawText,
        imageBase64: null,
      ),
      failureReason: null,
    );
  }

  Future<String> _extractDocumentText(PendingAttachmentDraft attachment) async {
    final String lowerMimeType = attachment.mimeType.toLowerCase();
    if (lowerMimeType == 'text/plain' || lowerMimeType == 'text/markdown') {
      final File documentFile = File(attachment.localPath);
      return (await documentFile.readAsString()).trim();
    }

    if (lowerMimeType ==
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      return _extractDocxText(attachment.localPath);
    }

    if (lowerMimeType == 'application/pdf') {
      return pdfEmbeddedTextExtractor.extractText(attachment.localPath);
    }

    throw AttachmentIngestionException(
      'Unsupported document type for ${attachment.displayName}.',
    );
  }

  Future<String> _extractDocxText(String filePath) async {
    final File documentFile = File(filePath);
    final List<int> bytes = await documentFile.readAsBytes();
    final Archive archive = ZipDecoder().decodeBytes(bytes);
    final ArchiveFile? documentXml = archive.files
        .where((ArchiveFile file) => file.name == 'word/document.xml')
        .cast<ArchiveFile?>()
        .firstOrNull;
    if (documentXml == null) {
      return '';
    }

    final List<int>? content = documentXml.content as List<int>?;
    if (content == null || content.isEmpty) {
      return '';
    }

    final XmlDocument xmlDocument = XmlDocument.parse(utf8.decode(content));
    final Iterable<String> textNodes = xmlDocument
        .findAllElements('t')
        .map((XmlElement element) => element.innerText.trim())
        .where((String text) => text.isNotEmpty);
    return textNodes.join(' ').trim();
  }
}

extension _NullableFirstOrNull<T> on Iterable<T?> {
  T? get firstOrNull {
    for (final T? value in this) {
      if (value != null) {
        return value;
      }
    }
    return null;
  }
}

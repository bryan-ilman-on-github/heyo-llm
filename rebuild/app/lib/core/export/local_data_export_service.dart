import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/chat/data/local/app_database.dart';

class LocalExportPreview {
  final DateTime exportedAt;
  final Map<String, Object?> payload;
  final Map<String, int> tableCounts;
  final String prettyJson;

  const LocalExportPreview({
    required this.exportedAt,
    required this.payload,
    required this.tableCounts,
    required this.prettyJson,
  });
}

abstract class ExportDirectoryProvider {
  Future<Directory> resolveDirectory();
}

class ApplicationDocumentsExportDirectoryProvider
    implements ExportDirectoryProvider {
  const ApplicationDocumentsExportDirectoryProvider();

  @override
  Future<Directory> resolveDirectory() async {
    return getApplicationDocumentsDirectory();
  }
}

class LocalDataExportService {
  final AppDatabase appDatabase;
  final String clientId;
  final ExportDirectoryProvider exportDirectoryProvider;

  const LocalDataExportService({
    required this.appDatabase,
    required this.clientId,
    this.exportDirectoryProvider =
        const ApplicationDocumentsExportDirectoryProvider(),
  });

  Future<LocalExportPreview> buildPreview() async {
    final LocalExportSnapshot snapshot = await appDatabase.exportSnapshot();
    final DateTime exportedAt = DateTime.now().toUtc();
    final Map<String, Object?> payload = <String, Object?>{
      'schema_version': appDatabase.schemaVersion,
      'exported_at': exportedAt.toIso8601String(),
      'client_id': clientId,
      'data': snapshot.toJson(),
    };
    final Map<String, int> tableCounts = <String, int>{
      'messages': snapshot.messages.length,
      'message_revisions': snapshot.messageRevisions.length,
      'memories': snapshot.memories.length,
      'embedding_vectors': snapshot.embeddingVectors.length,
      'memory_tags': snapshot.memoryTags.length,
      'entities': snapshot.entities.length,
      'entity_aliases': snapshot.entityAliases.length,
      'entity_links': snapshot.entityLinks.length,
      'attachments': snapshot.attachments.length,
      'message_pairs': snapshot.messagePairs.length,
    };
    final String prettyJson = const JsonEncoder.withIndent('  ').convert(payload);
    return LocalExportPreview(
      exportedAt: exportedAt.toLocal(),
      payload: payload,
      tableCounts: tableCounts,
      prettyJson: prettyJson,
    );
  }

  Future<String> savePreview(LocalExportPreview preview) async {
    final Directory directory = await exportDirectoryProvider.resolveDirectory();
    final String fileName = 'heyo-export-${_fileSafeTimestamp(preview.exportedAt)}.json';
    final File outputFile = File(join(directory.path, fileName));
    await outputFile.writeAsString(preview.prettyJson);
    return outputFile.path;
  }

  String _fileSafeTimestamp(DateTime timestamp) {
    final String isoValue = timestamp.toUtc().toIso8601String();
    return isoValue.replaceAll(':', '-');
  }
}

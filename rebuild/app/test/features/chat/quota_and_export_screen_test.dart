import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:heyo_rebuild_app/core/export/local_data_export_service.dart';
import 'package:heyo_rebuild_app/features/chat/data/chat_api_client.dart';
import 'package:heyo_rebuild_app/features/chat/data/local/app_database.dart';
import 'package:heyo_rebuild_app/features/chat/domain/chat_models.dart';
import 'package:heyo_rebuild_app/features/chat/presentation/quota_and_export_screen.dart';

void main() {
  testWidgets('loads quota, renders preview, and shows saved path', (
    WidgetTester tester,
  ) async {
    final AppDatabase appDatabase = AppDatabase.inMemory();
    addTearDown(appDatabase.close);
    final _FakeQuotaChatApiClient fakeChatApiClient = _FakeQuotaChatApiClient();
    final _FakeLocalDataExportService fakeExportService =
        _FakeLocalDataExportService(appDatabase);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: appDatabase),
          Provider<ChatApiClient>.value(value: fakeChatApiClient),
          Provider<LocalDataExportService>.value(value: fakeExportService),
        ],
        child: const MaterialApp(home: QuotaAndExportScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('196 remaining of 200'), findsOneWidget);
    expect(find.text('Prepare: 1'), findsOneWidget);

    await tester.tap(find.text('Generate preview'));
    await tester.pumpAndSettle();

    expect(find.textContaining('"client_id": "quota-client"'), findsOneWidget);

    await tester.tap(find.text('Save JSON'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Saved to:'), findsOneWidget);
    expect(find.textContaining('heyo-export'), findsOneWidget);
  });
}

class _FakeQuotaChatApiClient extends ChatApiClient {
  _FakeQuotaChatApiClient() : super(clientId: 'quota-client');

  @override
  Future<QuotaSnapshot> fetchQuota() async {
    return QuotaSnapshot(
      clientId: 'quota-client',
      quotaDay: '2026-03-09',
      dailyLimit: 200,
      totalUsed: 4,
      remainingTotal: 196,
      prepareCount: 1,
      respondCount: 1,
      entitySummaryCount: 1,
      attachmentInspectCount: 1,
      updatedAt: DateTime(2026, 3, 9, 10, 30),
      remainingPrepare: 196,
      remainingRespond: 196,
    );
  }
}

class _FakeLocalDataExportService extends LocalDataExportService {
  _FakeLocalDataExportService(AppDatabase appDatabase)
    : super(appDatabase: appDatabase, clientId: 'quota-client');

  @override
  Future<LocalExportPreview> buildPreview() async {
    return LocalExportPreview(
      exportedAt: DateTime(2026, 3, 9, 10, 45),
      payload: <String, Object?>{
        'schema_version': 3,
        'exported_at': '2026-03-09T10:45:00.000',
        'client_id': 'quota-client',
        'data': <String, Object?>{
          'messages': <Object?>[],
        },
      },
      tableCounts: const <String, int>{
        'messages': 0,
        'message_revisions': 0,
        'memories': 0,
        'embedding_vectors': 0,
        'memory_tags': 0,
        'entities': 0,
        'entity_aliases': 0,
        'entity_links': 0,
        'attachments': 0,
        'message_pairs': 0,
      },
      prettyJson: '{\n  "client_id": "quota-client"\n}',
    );
  }

  @override
  Future<String> savePreview(LocalExportPreview preview) async {
    return 'C:/exports/heyo-export-2026-03-09T10-45-00.000.json';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/storage/client_identity_store.dart';
import 'core/storage/database_key_store.dart';
import 'features/chat/data/chat_api_client.dart';
import 'features/chat/data/local/app_database.dart';
import 'features/chat/presentation/chat_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final databaseKeyStore = DatabaseKeyStore();
  final clientIdentityStore = ClientIdentityStore();
  final databaseKey = await databaseKeyStore.readOrCreateKey();
  final clientId = await clientIdentityStore.readOrCreateClientId();
  final appDatabase = AppDatabase.open(databaseKey);
  final chatApiClient = ChatApiClient(clientId: clientId);
  final chatController = ChatController(
    appDatabase: appDatabase,
    chatApiClient: chatApiClient,
  );

  await chatController.loadInitialState();

  runApp(
    HeyoApp(
      appDatabase: appDatabase,
      chatApiClient: chatApiClient,
      chatController: chatController,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/export/local_data_export_service.dart';
import 'core/theme/heyo_theme.dart';
import 'features/chat/data/chat_api_client.dart';
import 'features/chat/data/local/app_database.dart';
import 'features/chat/presentation/chat_controller.dart';
import 'features/chat/presentation/chat_screen.dart';

class HeyoApp extends StatelessWidget {
  final AppDatabase appDatabase;
  final ChatApiClient chatApiClient;
  final ChatController chatController;

  const HeyoApp({
    super.key,
    required this.appDatabase,
    required this.chatApiClient,
    required this.chatController,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: appDatabase),
        Provider<ChatApiClient>.value(value: chatApiClient),
        Provider<LocalDataExportService>(
          create: (BuildContext context) => LocalDataExportService(
            appDatabase: appDatabase,
            clientId: chatApiClient.clientId,
          ),
        ),
        ChangeNotifierProvider<ChatController>.value(value: chatController),
      ],
      child: MaterialApp(
        title: 'Heyo',
        debugShowCheckedModeBanner: false,
        theme: HeyoTheme.light,
        darkTheme: HeyoTheme.dark,
        home: const ChatScreen(),
      ),
    );
  }
}

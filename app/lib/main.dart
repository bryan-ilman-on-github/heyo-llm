import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/chat/domain/chat_service.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'shared/theme/heyo_theme.dart';

void main() {
  runApp(const HeyoApp());
}

class HeyoApp extends StatelessWidget {
  const HeyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatService(),
      child: MaterialApp(
        title: 'Heyo',
        debugShowCheckedModeBanner: false,
        theme: HeyoTheme.light,
        home: const ChatScreen(),
      ),
    );
  }
}

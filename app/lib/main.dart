import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/chat/domain/chat_service.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/theme/heyo_theme.dart';

void main() {
  runApp(const HeyoApp());
}

class HeyoApp extends StatelessWidget {
  const HeyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Heyo',
            debugShowCheckedModeBanner: false,
            theme: HeyoTheme.light,
            darkTheme: HeyoTheme.dark,
            themeMode: themeProvider.themeMode,
            themeAnimationDuration: const Duration(milliseconds: 250),
            themeAnimationCurve: Curves.easeInOut,
            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}

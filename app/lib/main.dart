import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'features/chat/domain/chat_service.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'shared/providers/settings_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/theme/heyo_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize settings provider with persisted values
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(HeyoApp(settingsProvider: settingsProvider));
}

class HeyoApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const HeyoApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider.value(value: settingsProvider),
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

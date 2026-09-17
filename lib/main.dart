import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:superthai/core/services/auth_service.dart';
import 'package:superthai/core/services/data_service.dart';
import 'package:superthai/core/services/progress_service.dart';
import 'package:superthai/core/services/theme_service.dart';
import 'package:superthai/firebase_options.dart';
import 'package:superthai/ui/screens/main_container.dart';
import 'package:superthai/ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: progressService),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: dataService),
      ],
      child: const SuperThaiApp(),
    ),
  );
}

class SuperThaiApp extends StatelessWidget {
  const SuperThaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'SuperThai',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightTheme(theme.primaryColor),
          darkTheme: AppTheme.getDarkTheme(theme.primaryColor),
          themeMode: theme.themeMode,
          home: StreamBuilder<User?>(
            stream: authService.userChanges,
            builder: (context, snapshot) {
              // ไม่ต้องดัก waiting แบบสนิท เพื่อให้แอปขึ้นหน้าหลักได้ทันที
              // Snapshot จะอัปเดตเองเมื่อ Firebase พร้อม
              return const MainContainer();
            },
          ),
        );
      },
    );
  }
}

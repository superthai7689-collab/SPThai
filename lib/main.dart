import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
        Provider.value(value: dataService),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'SuperThai',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: theme.themeMode,
          home: StreamBuilder(
            stream: AuthService.instance.userChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              // ให้ไปหน้า MainContainer เสมอ เพื่อให้ลองใช้ได้ก่อน
              return const MainContainer();
            },
          ),
        );
      },
    );
  }
}

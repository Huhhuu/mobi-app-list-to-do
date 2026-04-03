import 'package:flutter/material.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quan Ly Cong Viec',
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.login,
      routes: {
        AppRouter.login: (context) => const LoginScreen(),
        AppRouter.home: (context) => const HomeShell(),
      },
    );
  }
}

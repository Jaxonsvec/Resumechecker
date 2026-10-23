import 'package:flutter/material.dart';

import 'app_scroll_behavior.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

export 'screens/resume_input_screen.dart' show ResumeInputScreen;

void main() {
  runApp(const AiresumeApp());
}

class AiresumeApp extends StatelessWidget {
  const AiresumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airesume',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}

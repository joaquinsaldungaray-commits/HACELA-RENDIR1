import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/onboarding/welcome_screen.dart';

class HacelaRendirApp extends StatelessWidget {
  const HacelaRendirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacela Rendir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
    );
  }
}
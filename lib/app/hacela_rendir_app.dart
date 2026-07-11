import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router/app_router.dart';

class HacelaRendirApp extends StatelessWidget {
  const HacelaRendirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hacela Rendir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
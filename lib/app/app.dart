import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'router.dart';
import '../design_system/themes/app_theme.dart';

/// Application principale de ForeverCare AI.
class ForeverCareApp extends StatelessWidget {
  const ForeverCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,

        title: 'ForeverCare AI',

        theme: AppTheme.light,

        darkTheme: AppTheme.dark,

        themeMode: ThemeMode.system,

        routerConfig: AppRouter.router,
      ),
    );
  }
}

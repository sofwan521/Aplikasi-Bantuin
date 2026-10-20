import 'package:flutter/material.dart';

import 'pages/main_shell.dart';
import 'routes/app_routes.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BantuinApp());
}

/// Aplikasi Bantuin dengan tema, state bersama, dan kerangka navigasi utama.
class BantuinApp extends StatefulWidget {
  const BantuinApp({super.key});

  @override
  State<BantuinApp> createState() => _BantuinAppState();
}

class _BantuinAppState extends State<BantuinApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: 'Bantuin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MainShell(),
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

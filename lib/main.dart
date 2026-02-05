import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gf_qr/core/app_theme.dart';
import 'package:gf_qr/ui/pages/main_navigation_page.dart';
import 'package:gf_qr/features/history/history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HistoryService.init();
  runApp(
    const ProviderScope(
      child: GFQRApp(),
    ),
  );
}

class GFQRApp extends StatelessWidget {
  const GFQRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gravity-Free QR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationPage(),
    );
  }
}

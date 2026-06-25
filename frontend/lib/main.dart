import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/validation_provider.dart';
import 'screens/unified_dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ValidationProvider()),
      ],
      child: MaterialApp(
        title: 'CNAB Validador',
        theme: AppTheme.lightTheme,
        home: const UnifiedDashboardScreen(),
      ),
    );
  }
}


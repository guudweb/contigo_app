import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/setup_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await StorageService.init();

  // Initialize date formatting for Spanish
  await initializeDateFormatting('es', null);

  runApp(const ContigoApp());
}

class ContigoApp extends StatelessWidget {
  const ContigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contigo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if config exists
    final hasConfig = StorageService.hasConfig();

    // Navigate to appropriate screen
    if (hasConfig) {
      return const HomeScreen();
    } else {
      return const SetupScreen();
    }
  }
}

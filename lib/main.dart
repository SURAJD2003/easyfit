import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;
import 'features/tracking/services/activity_background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ActivityBackgroundService.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Easyfit Clinics',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B2B),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
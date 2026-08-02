import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'features/admin/presentation/providers/admin_provider.dart';
import 'features/tracking/services/activity_background_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ================= MASSIVE DEBUG DUMP =================
  final prefs = await SharedPreferences.getInstance();
  debugPrint('===================================================');
  debugPrint('🔍 MASSIVE LOCAL STORAGE DUMP (PROOF OF MOBILE DATA)');
  final keys = prefs.getKeys();
  
  int totalHourlyLocal = 0;
  int totalHourlySynced = 0;
  final Map<String, int> sessionTotalsLocal = {};
  final Map<String, int> sessionTotalsSynced = {};
  
  debugPrint('--- 🕒 RAW HOURLY BUCKETS (What mobile tracked) ---');
  final rawKeys = keys.where((k) => k.startsWith('hourly_steps_') && !k.startsWith('synced_hourly_steps_')).toList()..sort();
  for (final key in rawKeys) {
    final val = prefs.getInt(key) ?? 0;
    debugPrint('   $key : $val');
    totalHourlyLocal += val;
    
    // Extract session ID (format: hourly_steps_SESSIONID_hour)
    final parts = key.split('_');
    if (parts.length >= 4) {
      final sId = parts.sublist(2, parts.length - 1).join('_');
      final current = sessionTotalsLocal[sId] ?? 0;
      sessionTotalsLocal[sId] = current + val;
    }
  }
  
  debugPrint('--- ☁️ SYNCED BUCKETS (What mobile sent to server) ---');
  final syncKeys = keys.where((k) => k.startsWith('synced_hourly_steps_')).toList()..sort();
  for (final key in syncKeys) {
    final val = prefs.getInt(key) ?? 0;
    debugPrint('   $key : $val');
    totalHourlySynced += val;

    // Extract session ID (format: synced_hourly_steps_SESSIONID_hour)
    final parts = key.split('_');
    if (parts.length >= 5) {
      final sId = parts.sublist(3, parts.length - 1).join('_');
      final current = sessionTotalsSynced[sId] ?? 0;
      sessionTotalsSynced[sId] = current + val;
    }
  }
  
  debugPrint('--- 🏃‍♂️ ACTIVE SESSION DATA ---');
  debugPrint('   active_session_id: ${prefs.getString("active_session_id")}');
  debugPrint('   session_accumulated_steps (Current Pedometer Total): ${prefs.getInt("session_accumulated_steps")}');
  debugPrint('   session_date: ${prefs.getString("session_date")}');
  debugPrint('   last_step_timestamp: ${prefs.getString("last_step_timestamp")}');
  
  debugPrint('--- 📊 CACHED DAILY TOTALS (What Dashboard sees) ---');
  debugPrint('   completed_steps_date: ${prefs.getString("completed_steps_date")}');
  debugPrint('   completed_steps_today: ${prefs.getInt("completed_steps_today")}');
  
  debugPrint('--- 📴 OFFLINE & LOCAL SYNC DATA ---');
  final offlineKeys = keys.where((k) => k.contains('local_') || k.contains('pending')).toList()..sort();
  for (final key in offlineKeys) {
    debugPrint('   $key : ${prefs.get(key)}');
  }

  debugPrint('--- 📈 MATHEMATICAL TOTALS PER SESSION ---');
  for (final sId in sessionTotalsLocal.keys) {
    final tracked = sessionTotalsLocal[sId] ?? 0;
    final synced = sessionTotalsSynced[sId] ?? 0;
    final pending = tracked - synced;
    debugPrint('   Session [$sId]: Tracked=$tracked | Synced=$synced | Pending=$pending');
  }

  debugPrint('--- 📈 GRAND TOTALS ---');
  debugPrint('   Total Steps sitting in Local Hourly Buckets: $totalHourlyLocal');
  debugPrint('   Total Steps marked as Synced to Backend: $totalHourlySynced');
  debugPrint('   GRAND UNSYNCED PENDING STEPS: ${totalHourlyLocal - totalHourlySynced}');
  debugPrint('===================================================');
  // =======================================================

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register FCM background handler (must be top-level function)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await PushNotificationService().initialize();

  unawaited(_initializeBackgroundService());

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> _initializeBackgroundService() async {
  if (kIsWeb) return;

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      break;
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return;
  }

  try {
    await ActivityBackgroundService.initialize().timeout(
      const Duration(seconds: 5),
    );
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'activity background service',
        context: ErrorDescription(
            'while initializing the background service'),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ Your existing provider — untouched
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        // ✅ NEW — AdminProvider added
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => AdminProvider(),
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:play_integrity_flutter/play_integrity_flutter.dart';
import 'package:provider/provider.dart';
import 'Models/user.dart';
import 'Services/Authentication/auth.dart';
import 'Wrappers/main_wrapper.dart';
import 'firebase_options.dart';


Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Manually initialize App Check
    const isDebug = kDebugMode; // Detect if app is in debug mode

    await FirebaseAppCheck.instance.activate(
      androidProvider: isDebug
          ? AndroidProvider.debug // Use debug provider for debug mode
          : AndroidProvider.playIntegrity, // Use Play Integrity for release
    );

    // Log the debug token (for debugging purposes)
    if (isDebug) {
      final token = await FirebaseAppCheck.instance.getToken(true);
      debugPrint('Debug Token: $token');
    }

    // Configure Firestore settings
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    debugPrint('Firebase initialized successfully with App Check');
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization error: $e');
    debugPrint(stackTrace.toString());
    rethrow;
  }
}

/// Initialize Play Integrity API
Future<void> initializePlayIntegrity() async {
  try {
    final playIntegrity = PlayIntegrityFlutter();

    // Debug logging for Play Integrity instance
    debugPrint('Play Integrity initialized successfully: $playIntegrity');
  } catch (e, stackTrace) {
    debugPrint('Play Integrity initialization error: $e');
    debugPrint(stackTrace.toString());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 35, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Check your internet connection and try again.',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style:
                ElevatedButton.styleFrom(backgroundColor: Colors.grey[50]),
                onPressed: () async {
                  try {
                    await initializeFirebase();
                    await initializePlayIntegrity();
                    runApp(const MyApp());
                  } catch (error) {
                    debugPrint('Reinitialization failed: $error');
                  }
                },
                child: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<F_User?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mtush',
        home: const Wrapper(),
      ),
    );
  }
}

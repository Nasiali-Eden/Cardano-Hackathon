import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'Community/Activities/activities_list.dart';
import 'Community/Activities/activity_detail.dart';
import 'Community/Activities/create_activity.dart';
import 'Community/Contributions/contribution_confirmation.dart';
import 'Community/Contributions/log_contribution.dart';
import 'Community/Impact/impact_dashboard.dart';
import 'Community/Recognition/acknowledgements.dart';
import 'Community/Recognition/badges_screen.dart';
import 'Community/Communication/announcement_detail.dart';
import 'Community/Communication/announcements_list.dart';
import 'Community/Communication/notification_center.dart';
import 'Community/Profile/community_info.dart';
import 'Community/Profile/edit_profile.dart';
import 'Community/Profile/roadmap_screen.dart';
import 'Community/Profile/settings_screen.dart';
import 'Community/Blockchain/blockchain_settings.dart';
import 'Community/Blockchain/proof_preview.dart';
import 'Community/Blockchain/transparency_preview.dart';
import 'Organization/Home/org_home.dart';
import 'Models/user.dart';
import 'Providers/theme_provider.dart';
import 'Services/Authentication/auth.dart';
import 'Community/Home/community_home.dart';
import 'Shared/Authentication/join_community.dart';
import 'Shared/Pages/community_guidelines.dart';
import 'Shared/Pages/splash_screen.dart';
import 'Shared/Pages/welcome_screen.dart';
import 'Shared/Pages/login.dart';
import 'Shared/theme/app_theme.dart';
import 'firebase_options.dart';

/// Initialize Firebase safely (only once)
Future<void> initializeFirebase() async {
  try {
    // Check if Firebase is already initialized by the native platform
    // (This happens automatically on Android/iOS when google-services.json is present)
    if (Firebase.apps.isNotEmpty) {
      debugPrint('Firebase already initialized by native platform');
      _configureFirestore();
      return;
    }

    // Only attempt to initialize if no apps exist
    // (This shouldn't happen on Android with google-services.json, but handles other cases)
    try {
      debugPrint('Initializing Firebase from Dart...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
              'Firebase initialization timed out after 30 seconds');
        },
      );
      debugPrint('Firebase initialized successfully from Dart');
      _configureFirestore();
    } catch (e) {
      // If initialization fails, Firebase might still be available from native
      if (Firebase.apps.isNotEmpty) {
        debugPrint(
            'Firebase initialization attempt failed, but Firebase is available: $e');
        _configureFirestore();
      } else {
        rethrow;
      }
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    rethrow;
  }
}

/// Configure Firestore settings (safe to call multiple times)
void _configureFirestore() {
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    debugPrint('Firestore settings configured');
  } catch (e) {
    debugPrint('Error configuring Firestore settings: $e');
    // Continue anyway, Firestore might already be configured
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
                'Failed to initialize the app',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please restart the application.',
                style: TextStyle(fontSize: 14, color: Colors.black45),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                onPressed: () {
                  // Force app exit to restart
                  exit(1);
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Close App',
                  style: TextStyle(color: Colors.white),
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

  try {
    await initializeFirebase();
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
    // Still run the app but show error
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // CRITICAL FIX: Use a custom stream that doesn't trigger rebuilds
        // We provide the user stream but don't use it for automatic routing
        StreamProvider<F_User?>.value(
          value: AuthService().user,
          initialData: null,
          // This prevents automatic navigation on auth state changes
          catchError: (context, error) {
            debugPrint('Auth stream error: $error');
            return null;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = ThemeProvider();
            p.load();
            return p;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Impact Ledger',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.mode,
            // CRITICAL: Start at splash and use direct navigation from there
            // This prevents the app from auto-routing on auth changes
            home: const SplashScreen(),
            // Keep routes for nested navigation within the app
            routes: {
              '/activities': (context) => const ActivitiesListScreen(),
              '/activities/create': (context) => const CreateActivityScreen(),
              '/contributions/log': (context) => const LogContributionScreen(),
              '/impact': (context) => const ImpactDashboardScreen(),
              '/recognition/badges': (context) => const BadgesScreen(),
              '/recognition/acknowledgements': (context) => const AcknowledgementsScreen(),
              '/announcements': (context) => const AnnouncementsListScreen(),
              '/notifications': (context) => const NotificationCenterScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/profile/edit': (context) => const EditProfileScreen(),
              '/community/info': (context) => const CommunityInfoScreen(),
              '/roadmap': (context) => const RoadmapScreen(),
              '/blockchain/transparency': (context) => const TransparencyPreviewScreen(),
              '/blockchain/proof': (context) => const ProofPreviewScreen(),
              '/dev/blockchain': (context) => const BlockchainDevSettingsScreen(),
            },
            onGenerateRoute: (settings) {
              final name = settings.name ?? '/';

              // Handle routes with parameters
              if (name.startsWith('/activities/') && name != '/activities/create') {
                final parts = name.split('/');
                final id = parts.isNotEmpty ? parts.last : '';
                return MaterialPageRoute(
                  builder: (context) => ActivityDetailScreen(activityId: id),
                  settings: settings,
                );
              } else if (name.startsWith('/announcements/')) {
                final parts = name.split('/');
                final id = parts.isNotEmpty ? parts.last : '';
                return MaterialPageRoute(
                  builder: (context) => AnnouncementDetailScreen(announcementId: id),
                  settings: settings,
                );
              } else if (name == '/contributions/confirm') {
                final args = settings.arguments;
                final points = (args is Map && args['points'] is int)
                    ? args['points'] as int
                    : 0;
                return MaterialPageRoute(
                  builder: (context) => ContributionConfirmationScreen(points: points),
                  settings: settings,
                );
              }

              return null;
            },
          );
        },
      ),
    );
  }
}
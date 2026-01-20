import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'Community/Profile/hackathon_context.dart';
import 'Community/Profile/roadmap_screen.dart';
import 'Community/Profile/settings_screen.dart';
import 'Community/Blockchain/blockchain_settings.dart';
import 'Community/Blockchain/proof_preview.dart';
import 'Community/Blockchain/transparency_preview.dart';
import 'Models/user.dart';
import 'Providers/theme_provider.dart';
import 'Services/Authentication/auth.dart';
import 'Community/Home/community_home.dart';
import 'Shared/Authentication/join_community.dart';
import 'Shared/Pages/community_guidelines.dart';
import 'Shared/Pages/splash_screen.dart';
import 'Shared/Pages/welcome_screen.dart';
import 'Shared/theme/app_theme.dart';
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

  try {
    await initializeFirebase();
    runApp(const MyApp());
  } catch (_) {
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<F_User?>.value(
          value: AuthService().user,
          initialData: null,
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
            initialRoute: '/splash',
            onGenerateRoute: (settings) {
              final name = settings.name ?? '/splash';

              Widget page;
              if (name == '/splash') {
                page = const SplashScreen();
              } else if (name == '/welcome') {
                page = const WelcomeScreen();
              } else if (name == '/join') {
                page = const JoinCommunityScreen();
              } else if (name == '/guidelines') {
                page = const CommunityGuidelinesScreen();
              } else if (name == '/home') {
                page = const CommunityHomeScreen();
              } else if (name == '/activities') {
                page = const ActivitiesListScreen();
              } else if (name == '/activities/create') {
                page = const CreateActivityScreen();
              } else if (name.startsWith('/activities/')) {
                final parts = name.split('/');
                final id = parts.isNotEmpty ? parts.last : '';
                page = ActivityDetailScreen(activityId: id);
              } else if (name == '/contributions/log') {
                page = const LogContributionScreen();
              } else if (name == '/contributions/confirm') {
                final args = settings.arguments;
                final points = (args is Map && args['points'] is int)
                    ? args['points'] as int
                    : 0;
                page = ContributionConfirmationScreen(points: points);
              } else if (name == '/impact') {
                page = const ImpactDashboardScreen();
              } else if (name == '/recognition/badges') {
                page = const BadgesScreen();
              } else if (name == '/recognition/acknowledgements') {
                page = const AcknowledgementsScreen();
              } else if (name == '/announcements') {
                page = const AnnouncementsListScreen();
              } else if (name.startsWith('/announcements/')) {
                final parts = name.split('/');
                final id = parts.isNotEmpty ? parts.last : '';
                page = AnnouncementDetailScreen(announcementId: id);
              } else if (name == '/notifications') {
                page = const NotificationCenterScreen();
              } else if (name == '/settings') {
                page = const SettingsScreen();
              } else if (name == '/profile/edit') {
                page = const EditProfileScreen();
              } else if (name == '/community/info') {
                page = const CommunityInfoScreen();
              } else if (name == '/roadmap') {
                page = const RoadmapScreen();
              } else if (name == '/hackathon') {
                page = const HackathonContextScreen();
              } else if (name == '/blockchain/transparency') {
                page = const TransparencyPreviewScreen();
              } else if (name == '/blockchain/proof') {
                page = const ProofPreviewScreen();
              } else if (name == '/dev/blockchain') {
                page = const BlockchainDevSettingsScreen();
              } else {
                page = const SplashScreen();
              }

              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 350),
              );
            },
          );
        },
      ),
    );
  }
}

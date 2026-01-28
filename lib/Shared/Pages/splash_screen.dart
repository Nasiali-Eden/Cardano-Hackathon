import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/user.dart';
import '../../Services/Authentication/community_auth.dart';
import '../../Services/Demo/demo_seeder.dart';
import '../../Community/Home/community_home.dart';
import '../../Organization/Home/org_home.dart';
import '../../Shared/Pages/welcome_screen.dart';
import '../../Shared/Pages/community_guidelines.dart';
import '../../Shared/Authentication/join_community.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _navigated = false;
  bool _isNavigating = false;
  String _statusMessage = 'Initializing...';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup fade animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _animationController.forward();
    
    // Start initialization after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    // Prevent multiple calls
    if (_navigated || _isNavigating) {
      debugPrint('[SPLASH] Already navigating, ignoring call');
      return;
    }

    try {
      // Minimum splash display time for branding
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted || _navigated || _isNavigating) return;

      // Check authentication state
      _updateStatus('Checking authentication...');
      final user = Provider.of<F_User?>(context, listen: false);

      debugPrint('[SPLASH] User auth state: ${user?.uid ?? "null"}');

      if (user == null) {
        debugPrint('[SPLASH] No user, going to welcome');
        _goToWidget(const WelcomeScreen());
        return;
      }

      // For authenticated users, seed demo data first
      _updateStatus('Preparing your workspace...');
      await _seedDemoData(user.uid);

      // Small delay to show final status
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted || _navigated || _isNavigating) return;

      // Use role-based routing
      _updateStatus('Loading...');
      await _navigateToRoleBasedHome();
    } catch (e) {
      debugPrint('[SPLASH] Error: $e');
      if (!mounted || _navigated || _isNavigating) return;
      
      // On error, still attempt to navigate
      _updateStatus('Loading...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted || _navigated || _isNavigating) return;
      final user = Provider.of<F_User?>(context, listen: false);
      
      if (user == null) {
        _goToWidget(const WelcomeScreen());
      } else {
        _goToWidget(const CommunityHomeScreen());
      }
    }
  }

  Future<void> _navigateToRoleBasedHome() async {
    if (_navigated || _isNavigating) {
      debugPrint('[SPLASH] Navigation already in progress');
      return;
    }

    final user = Provider.of<F_User?>(context, listen: false);
    if (user == null) {
      debugPrint('[SPLASH] User is null during role routing');
      _goToWidget(const WelcomeScreen());
      return;
    }

    try {
      debugPrint('[SPLASH] Checking user role for uid: ${user.uid}');
      
      // Check if user exists in members collection
      final memberSnapshot = await FirebaseFirestore.instance
          .collection('members')
          .doc(user.uid)
          .get();

      debugPrint('[SPLASH] Members check: exists=${memberSnapshot.exists}');

      if (memberSnapshot.exists) {
        _handleUserRoute(memberSnapshot, 'Member', user.uid);
        return;
      }

      // Check if user exists in org_rep collection
      final orgSnapshot = await FirebaseFirestore.instance
          .collection('org_rep')
          .doc(user.uid)
          .get();

      debugPrint('[SPLASH] Org_rep check: exists=${orgSnapshot.exists}');

      if (orgSnapshot.exists) {
        _handleUserRoute(orgSnapshot, 'Org Rep', user.uid);
        return;
      }

      // User not found in either collection
      debugPrint('[SPLASH] User not found in any collection, going to join');
      _goToWidget(const JoinCommunityScreen());
    } catch (e) {
      debugPrint('[SPLASH] Role routing error: $e');
      _goToWidget(const CommunityHomeScreen()); // Fallback
    }
  }

  void _handleUserRoute(DocumentSnapshot userDoc, String role, String uid) {
    if (_navigated || _isNavigating) {
      debugPrint('[SPLASH] Already navigating, skipping route handler');
      return;
    }

    final data = userDoc.data() as Map<String, dynamic>?;
    final acceptedAt = data?['guidelinesAcceptedAt'];

    debugPrint('[SPLASH] Role: $role, uid: $uid');
    debugPrint('[SPLASH] Guidelines accepted: ${acceptedAt != null}');

    // Check if user has accepted guidelines
    if (acceptedAt == null) {
      debugPrint('[SPLASH] Guidelines not accepted, routing to guidelines');
      _goToWidget(const CommunityGuidelinesScreen());
      return;
    }

    // Route based on role
    if (role == 'Org Rep') {
      debugPrint('[SPLASH] ✅ Routing Org Rep to OrganizationHome');
      _goToWidget(const OrganizationHome());
    } else {
      debugPrint('[SPLASH] ✅ Routing Member to CommunityHomeScreen');
      _goToWidget(const CommunityHomeScreen());
    }
  }

  Future<void> _seedDemoData(String userId) async {
    try {
      final seeder = DemoSeeder();
      await Future.wait([
        seeder.seedIfNeeded(userId: userId),
        seeder.seedCommsIfNeeded(userId: userId),
      ]);
    } catch (e) {
      debugPrint('[SPLASH] Demo seeding error (non-critical): $e');
      // Ignore seeding errors - they're not critical
    }
  }

  void _updateStatus(String message) {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
    });
  }

  void _goToWidget(Widget widget) {
    // Triple check to prevent multiple navigation
    if (_navigated || _isNavigating) {
      debugPrint('[SPLASH] ⚠️ Navigation already in progress or completed');
      return;
    }

    debugPrint('[SPLASH] 🚀 Starting navigation to ${widget.runtimeType}');
    
    // Set both flags immediately
    _isNavigating = true;
    _navigated = true;

    // Fade out before navigation
    _animationController.reverse().then((_) {
      if (mounted) {
        debugPrint('[SPLASH] 🎯 Executing navigation to ${widget.runtimeType}');
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => widget),
          (route) => false, // Clear entire stack
        ).then((_) {
          debugPrint('[SPLASH] ✅ Navigation completed to ${widget.runtimeType}');
        }).catchError((error) {
          debugPrint('[SPLASH] ❌ Navigation error: $error');
        });
      }
    });
  }

  // CRITICAL: Override didChangeDependencies to prevent re-navigation
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // If we've already navigated, don't do anything
    if (_navigated) {
      debugPrint('[SPLASH] didChangeDependencies called but already navigated');
      return;
    }
    
    debugPrint('[SPLASH] didChangeDependencies called');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back button from interfering
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      // Logo with subtle scale animation
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Image.asset(
                          'pngs/logotext.png',
                          width: 200,
                          height: 120,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tagline
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Track real-world contributions. Build community impact.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Loading indicator
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Status message with smooth transition
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _statusMessage,
                          key: ValueKey(_statusMessage),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                
                // Version info
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Opacity(
                    opacity: 0.65,
                    child: Text(
                      'v1.0.0',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
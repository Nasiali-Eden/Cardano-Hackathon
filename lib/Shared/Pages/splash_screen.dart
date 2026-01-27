import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/user.dart';
import '../../Services/Authentication/community_auth.dart';
import '../../Services/Demo/demo_seeder.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _navigated = false;
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
    if (_navigated) return;

    try {
      // Minimum splash display time for branding
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      // Check authentication state
      _updateStatus('Checking authentication...');
      final user = Provider.of<F_User?>(context, listen: false);

      if (user == null) {
        _go('/welcome');
        return;
      }

      // Check community guidelines acceptance
      _updateStatus('Loading community data...');
      final communityAuth = CommunityAuthService();
      final accepted = await communityAuth.hasAcceptedGuidelines(uid: user.uid);
      
      if (!mounted) return;

      // Seed demo data if needed (best effort)
      _updateStatus('Preparing your workspace...');
      await _seedDemoData(user.uid);

      // Small delay to show final status
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // Navigate based on guidelines acceptance
      if (accepted) {
        _go('/home');
      } else {
        _go('/guidelines');
      }
    } catch (e) {
      debugPrint('Splash screen error: $e');
      if (!mounted) return;
      
      // On error, still attempt to navigate
      _updateStatus('Loading...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      final user = Provider.of<F_User?>(context, listen: false);
      _go(user == null ? '/welcome' : '/home');
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
      debugPrint('Demo seeding error (non-critical): $e');
      // Ignore seeding errors - they're not critical
    }
  }

  void _updateStatus(String message) {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
    });
  }

  void _go(String routeName) {
    if (_navigated) return;
    _navigated = true;

    // Fade out before navigation
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
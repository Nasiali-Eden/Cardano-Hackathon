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

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start();
    });
  }

  Future<void> _start() async {
    if (_navigated) return;
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final user = Provider.of<F_User?>(context, listen: false);

    if (user == null) {
      _go('/welcome');
      return;
    }

    final communityAuth = CommunityAuthService();
    final accepted = await communityAuth.hasAcceptedGuidelines(uid: user.uid);
    if (!mounted) return;

    try {
      await DemoSeeder().seedIfNeeded(userId: user.uid);
      await DemoSeeder().seedCommsIfNeeded(userId: user.uid);
    } catch (_) {
      // Best-effort only
    }

    if (accepted) {
      _go('/home');
    } else {
      _go('/guidelines');
    }
  }

  void _go(String routeName) {
    if (_navigated) return;
    _navigated = true;

    Navigator.of(context).pushReplacementNamed(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', width: 112, height: 112),
                    const SizedBox(height: 16),
                    Text(
                      'Track real-world contributions. Build community impact.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Opacity(
                  opacity: 0.65,
                  child: Text(
                    'v1.0.0',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimary,
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

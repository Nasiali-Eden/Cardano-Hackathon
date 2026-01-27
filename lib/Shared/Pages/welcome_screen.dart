import 'package:flutter/material.dart';
import '../../Shared/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Image.asset(
                    'pngs/logotext.png',
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primary
                                    .withAlpha((0.15 * 255).toInt()),
                                AppTheme.primary
                                    .withAlpha((0.08 * 255).toInt()),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.volunteer_activism,
                              size: 64,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Why This Matters',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 12),
                        _BenefitCard(
                          icon: Icons.analytics,
                          title: 'Transparent impact tracking',
                          description:
                              'See community progress and how each contribution adds up.',
                        ),
                        const SizedBox(height: 12),
                        _BenefitCard(
                          icon: Icons.group,
                          title: 'Community-powered activities',
                          description:
                              'Join cleanups, events, and tasks that matter locally.',
                        ),
                        const SizedBox(height: 12),
                        _BenefitCard(
                          icon: Icons.emoji_events,
                          title: 'Recognition that feels meaningful',
                          description:
                              'Earn badges and milestones without turning it into a game.',
                        ),
                        const SizedBox(height: 12),
                        _BenefitCard(
                          icon: Icons.verified,
                          title: 'Future-ready verification',
                          description:
                              'Built to support verifiable impact records in the future.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/join');
                  },
                  child: const Text('Get Started'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Already a member? Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha((0.12 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

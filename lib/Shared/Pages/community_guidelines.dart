import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/user.dart';
import '../../Services/Authentication/community_auth.dart';

class CommunityGuidelinesScreen extends StatefulWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  State<CommunityGuidelinesScreen> createState() =>
      _CommunityGuidelinesScreenState();
}

class _CommunityGuidelinesScreenState extends State<CommunityGuidelinesScreen> {
  bool _accepted = false;
  bool _saving = false;

  Future<void> _continue() async {
    final user = Provider.of<F_User?>(context, listen: false);
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/welcome');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await CommunityAuthService().setGuidelinesAccepted(uid: user.uid);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Community Guidelines'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Community Guidelines',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    _GuidelineCard(
                      icon: Icons.handshake_outlined,
                      title: 'Respect & inclusion',
                      description:
                          'Be kind and welcoming. Harassment and discrimination are not tolerated.',
                    ),
                    const SizedBox(height: 12),
                    _GuidelineCard(
                      icon: Icons.fact_check_outlined,
                      title: 'Honest contributions',
                      description:
                          'Log contributions accurately. Transparency builds trust for everyone.',
                    ),
                    const SizedBox(height: 12),
                    _GuidelineCard(
                      icon: Icons.shield_outlined,
                      title: 'Safety first',
                      description:
                          'Follow local safety guidance during activities. Never put yourself at risk.',
                    ),
                    const SizedBox(height: 12),
                    _GuidelineCard(
                      icon: Icons.photo_camera_outlined,
                      title: 'Privacy-aware sharing',
                      description:
                          'Avoid sharing private information or identifiable details without consent.',
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _accepted,
                    onChanged: (v) => setState(() => _accepted = v ?? false),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('I agree to follow these guidelines'),
                  ),
                  FilledButton(
                    onPressed: !_accepted || _saving ? null : _continue,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue to Community'),
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

class _GuidelineCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GuidelineCard({
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
                color: colorScheme.primary.withAlpha((0.10 * 255).toInt()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
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

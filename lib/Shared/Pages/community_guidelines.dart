import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Models/user.dart';
import '../../Services/Authentication/community_auth.dart';
import '../../Community/Home/community_home.dart';
import '../../Organization/Home/org_home.dart';
import '../../Shared/Pages/welcome_screen.dart';

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
    
    debugPrint('[GUIDELINES] Continue clicked, user: ${user?.uid}');
    
    if (user == null) {
      debugPrint('[GUIDELINES] ❌ User is null, going to welcome');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      debugPrint('[GUIDELINES] Setting guidelines accepted for uid: ${user.uid}');
      await CommunityAuthService().setGuidelinesAccepted(uid: user.uid);
      
      debugPrint('[GUIDELINES] Guidelines accepted, now checking user role...');

      // Add a small delay to ensure Firestore write completes
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Check user role to route to correct home
      // First check members collection
      debugPrint('[GUIDELINES] Checking members collection...');
      final memberDoc = await FirebaseFirestore.instance
          .collection('members')
          .doc(user.uid)
          .get();

      debugPrint('[GUIDELINES] Members exists: ${memberDoc.exists}');

      if (memberDoc.exists) {
        if (!mounted) return;
        debugPrint('[GUIDELINES] ✅ User is Member, routing to CommunityHomeScreen');
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CommunityHomeScreen()),
          (route) => false,
        );
        return;
      }

      // Check org_rep collection
      debugPrint('[GUIDELINES] Checking org_rep collection...');
      final orgDoc = await FirebaseFirestore.instance
          .collection('org_rep')
          .doc(user.uid)
          .get();

      debugPrint('[GUIDELINES] Org_rep exists: ${orgDoc.exists}');

      if (!mounted) return;

      if (orgDoc.exists) {
        debugPrint('[GUIDELINES] ✅ User is Org Rep, routing to OrganizationHome');
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OrganizationHome()),
          (route) => false,
        );
      } else {
        // User not found in either collection - this shouldn't happen
        debugPrint('[GUIDELINES] ⚠️ WARNING: User not found in members or org_rep!');
        debugPrint('[GUIDELINES] This should not happen - user should exist in one collection');
        
        // Fallback to home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CommunityHomeScreen()),
          (route) => false,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[GUIDELINES] ❌ Error: $e');
      debugPrint('[GUIDELINES] Stack trace: $stackTrace');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
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

    return WillPopScope(
      // Prevent back button from causing issues
      onWillPop: () async => !_saving,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Community Guidelines'),
          automaticallyImplyLeading: false, // Remove back button
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
                      onChanged: _saving ? null : (v) => setState(() => _accepted = v ?? false),
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
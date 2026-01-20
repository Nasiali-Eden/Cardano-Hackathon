import 'package:flutter/material.dart';

class HackathonContextScreen extends StatelessWidget {
  const HackathonContextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hackathon Context')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Impact Ledger — Community Impact Tracking',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This prototype demonstrates how a community can transparently track real-world contributions (time, effort, materials), visualize impact, and recognize contributors.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cardano integration is planned: we provide preview UX and an abstraction layer, but do not submit real transactions in this build.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Recommended demo flow'),
                subtitle: const Text(
                    'Welcome → Join → Home → Activities → Log Contribution → Impact → Badges → Notifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

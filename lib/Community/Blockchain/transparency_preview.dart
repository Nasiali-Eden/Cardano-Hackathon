import 'package:flutter/material.dart';

class TransparencyPreviewScreen extends StatelessWidget {
  const TransparencyPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Transparency Preview')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            colorScheme.primary.withAlpha((0.12 * 255).toInt()),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.verified_outlined,
                          color: colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'This is a prototype preview. Blockchain verification is planned, not live.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What will be verifiable later',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    const _Item(
                        icon: Icons.receipt_long_outlined,
                        title: 'Contribution metadata',
                        body:
                            'Type, timestamp window, anonymized contributor reference.'),
                    const SizedBox(height: 8),
                    const _Item(
                        icon: Icons.analytics_outlined,
                        title: 'Impact aggregates',
                        body: 'Community totals and milestone snapshots.'),
                    const SizedBox(height: 8),
                    const _Item(
                        icon: Icons.link_outlined,
                        title: 'Proof links',
                        body:
                            'A proof object mapping contribution → verification artifact.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fingerprint_outlined),
                title: const Text('Proof of Contribution (Preview)'),
                subtitle:
                    const Text('View a sample proof object and mock hashes.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/blockchain/proof'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _Item({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(body,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

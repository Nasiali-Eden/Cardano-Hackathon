import 'dart:math';

import 'package:flutter/material.dart';

class ProofPreviewScreen extends StatelessWidget {
  const ProofPreviewScreen({super.key});

  String _mockHash(String prefix) {
    const chars = 'abcdef0123456789';
    final rand = Random();
    final buf = StringBuffer(prefix);
    for (var i = 0; i < 32; i++) {
      buf.write(chars[rand.nextInt(chars.length)]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final tx = _mockHash('tx_');
    final datum = _mockHash('datum_');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Proof Preview')),
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
                      'Mock Proof Object',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _kv(context, 'Contribution ID', 'demo_contribution_001'),
                    const SizedBox(height: 8),
                    _kv(context, 'Mock Tx Hash', tx),
                    const SizedBox(height: 8),
                    _kv(context, 'Mock Datum Hash', datum),
                    const SizedBox(height: 12),
                    Text(
                      'These values are placeholders to demonstrate the UX. Real Cardano proofs are not implemented in this hackathon build.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.open_in_new_outlined),
                title: const Text('Verify on explorer'),
                subtitle:
                    const Text('Coming soon (Cardano integration planned).'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Explorer verification coming soon')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          SelectableText(v, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

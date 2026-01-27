import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/contribution.dart';
import '../../Models/user.dart';
import '../../Services/Impact/impact_service.dart';
import '../../Shared/theme/app_theme.dart';

class AcknowledgementsScreen extends StatelessWidget {
  const AcknowledgementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<F_User?>(context);

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Acknowledgements')),
        body: const Center(child: Text('Sign in to view acknowledgements')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Acknowledgements')),
      body: StreamBuilder<List<Contribution>>(
        stream: ImpactService().watchUserContributions(userId: user.uid),
        builder: (context, snapshot) {
          final list = snapshot.data ?? const [];

          final milestones = <_MilestoneItem>[
            _MilestoneItem(
              title: 'Started',
              description: 'Joined the community and accepted guidelines.',
              reached: true,
            ),
            _MilestoneItem(
              title: 'First contribution',
              description: 'Logged your first contribution.',
              reached: list.isNotEmpty,
            ),
            _MilestoneItem(
              title: '5 contributions',
              description: 'Built a habit of contributing consistently.',
              reached: list.length >= 5,
            ),
            _MilestoneItem(
              title: '10 contributions',
              description: 'A strong signal of long-term community support.',
              reached: list.length >= 10,
            ),
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_outline, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Milestones',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Recognizing steady, meaningful contributions.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...milestones.map((m) => _MilestoneTile(item: m)),
            ],
          );
        },
      ),
    );
  }
}

class _MilestoneItem {
  final String title;
  final String description;
  final bool reached;

  const _MilestoneItem(
      {required this.title, required this.description, required this.reached});
}

class _MilestoneTile extends StatelessWidget {
  final _MilestoneItem item;

  const _MilestoneTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.reached
              ? AppTheme.tertiary.withAlpha((0.12 * 255).toInt())
              : colorScheme.surfaceContainerHighest,
          child: Icon(
            item.reached ? Icons.check : Icons.timelapse,
            color:
                item.reached ? AppTheme.tertiary : colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(item.title),
        subtitle: Text(item.description),
      ),
    );
  }
}

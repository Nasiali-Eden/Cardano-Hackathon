import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../Models/contribution.dart';
import '../../Models/user.dart';
import '../../Services/Impact/impact_service.dart';
import 'progress_visuals.dart';

class ImpactDashboardScreen extends StatefulWidget {
  final bool embedded;

  const ImpactDashboardScreen({super.key, this.embedded = false});

  @override
  State<ImpactDashboardScreen> createState() => _ImpactDashboardScreenState();
}

class _ImpactDashboardScreenState extends State<ImpactDashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<F_User?>(context);

    final content = Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Community')),
              ButtonSegment(value: 1, label: Text('My Impact')),
            ],
            selected: {_tab},
            onSelectionChanged: (value) {
              setState(() {
                _tab = value.first;
              });
            },
          ),
        ),
        if (widget.embedded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                const Spacer(),
                IconButton(
                  onPressed: user == null
                      ? null
                      : () async {
                          final csv = await ImpactService()
                              .exportUserContributionsCsv(userId: user.uid);
                          await Clipboard.setData(ClipboardData(text: csv));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Exported CSV to clipboard')),
                            );
                          }
                        },
                  icon: const Icon(Icons.download_outlined),
                  tooltip: 'Export CSV',
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF export coming soon')),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  tooltip: 'Export PDF (coming soon)',
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Expanded(
          child: _tab == 0
              ? _CommunityImpactTab(
                  embedded: widget.embedded,
                )
              : _MyImpactTab(
                  embedded: widget.embedded,
                  userId: user?.uid,
                ),
        ),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact'),
        actions: [
          IconButton(
            onPressed: () async {
              if (user == null) {
                Navigator.pushReplacementNamed(context, '/welcome');
                return;
              }

              final csv = await ImpactService()
                  .exportUserContributionsCsv(userId: user.uid);
              await Clipboard.setData(ClipboardData(text: csv));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exported CSV to clipboard')),
                );
              }
            },
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: content,
    );
  }
}

class _CommunityImpactTab extends StatelessWidget {
  final bool embedded;

  const _CommunityImpactTab({required this.embedded});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<int>(
      stream: ImpactService().watchCommunityTotalImpactPoints(),
      builder: (context, snapshot) {
        final total = snapshot.data ?? 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            colorScheme.primary.withAlpha((0.12 * 255).toInt()),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.analytics_outlined,
                          color: colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Community Total Impact',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$total points',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Contribution>>(
              stream: ImpactService().watchCommunityContributions(),
              builder: (context, snapshot) {
                final list = snapshot.data ?? const [];
                return ProgressVisuals(contributions: list);
              },
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Export (PDF)'),
                subtitle: const Text(
                    'Planned — exportable reports will be added in a later step.'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PDF export coming soon')),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MyImpactTab extends StatelessWidget {
  final bool embedded;
  final String? userId;

  const _MyImpactTab({required this.embedded, required this.userId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final uid = userId;
    if (uid == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline,
                  size: 48, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                'Sign in to view your impact',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/welcome'),
                child: const Text('Go to Welcome'),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<int>(
      stream: ImpactService().watchUserImpactPoints(userId: uid),
      builder: (context, pointsSnap) {
        final points = pointsSnap.data ?? 0;

        return StreamBuilder<List<Contribution>>(
          stream: ImpactService().watchUserContributions(userId: uid),
          builder: (context, contribSnap) {
            final list = contribSnap.data ?? const [];
            final summary = ImpactService()
                .summarize(impactPoints: points, contributions: list);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Impact',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: _Metric(
                                    label: 'Impact Points',
                                    value: '${summary.impactPoints}')),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _Metric(
                                    label: 'Contributions',
                                    value: '${summary.contributionsCount}')),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _Metric(
                                    label: 'Hours',
                                    value: summary.hours.toStringAsFixed(1))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ProgressVisuals(contributions: list),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Contributions',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        if (list.isEmpty)
                          Text(
                            'No contributions yet. Log one to see progress here.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          )
                        else
                          ...list.take(10).map((c) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(Icons.bolt_outlined,
                                        color: colorScheme.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${c.type} contribution',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          c.createdAt == null
                                              ? 'Just now'
                                              : c.createdAt!
                                                  .toLocal()
                                                  .toString()
                                                  .split('.')
                                                  .first,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '+${c.estimatedImpactPoints}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

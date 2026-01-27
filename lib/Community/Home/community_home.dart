import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/user.dart';
import '../../Services/Community/community_service.dart';
import '../../Shared/theme/app_theme.dart';
import '../Activities/activities_list.dart';
import '../Impact/impact_dashboard.dart';
import '../Profile/profile_screen.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final user = Provider.of<F_User?>(context);

    final pages = [
      _HomeTab(
        userId: user?.uid,
        onJoinActivity: () => setState(() => _index = 1),
        onLogContribution: () {
          Navigator.pushNamed(context, '/contributions/log');
        },
        onViewImpact: () => setState(() => _index = 2),
      ),
      const ActivitiesListScreen(embedded: true),
      const ImpactDashboardScreen(embedded: true),
      const ProfileScreen(),
    ];

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation from home
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Impact Ledger'),
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined),
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: Icon(Icons.person, color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
        body: pages[_index],
        floatingActionButton: _index != 1 || user == null
            ? null
            : FutureBuilder<String?>(
                future: CommunityService().getUserRole(userId: user.uid),
                builder: (context, snapshot) {
                  final role = snapshot.data ?? 'Member';
                  final isOrganizer = role == 'Organizer';
                  if (!isOrganizer) return const SizedBox.shrink();

                  return FloatingActionButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/activities/create'),
                    child: const Icon(Icons.add),
                  );
                },
              ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.event_note_outlined), label: 'Activities'),
            NavigationDestination(
                icon: Icon(Icons.analytics_outlined), label: 'Impact'),
            NavigationDestination(
                icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String? userId;
  final VoidCallback onJoinActivity;
  final VoidCallback onLogContribution;
  final VoidCallback onViewImpact;

  const _HomeTab({
    required this.userId,
    required this.onJoinActivity,
    required this.onLogContribution,
    required this.onViewImpact,
  });

  @override
  Widget build(BuildContext context) {
    return _HomeTabBody(
      userId: userId,
      onJoinActivity: onJoinActivity,
      onLogContribution: onLogContribution,
      onViewImpact: onViewImpact,
    );
  }
}

class _HomeTabBody extends StatefulWidget {
  final String? userId;
  final VoidCallback onJoinActivity;
  final VoidCallback onLogContribution;
  final VoidCallback onViewImpact;

  const _HomeTabBody({
    required this.userId,
    required this.onJoinActivity,
    required this.onLogContribution,
    required this.onViewImpact,
  });

  @override
  State<_HomeTabBody> createState() => _HomeTabBodyState();
}

class _HomeTabBodyState extends State<_HomeTabBody> {
  int _feedLimit = 5;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder<CommunityOverview>(
            stream: CommunityService().watchOverview(),
            builder: (context, snapshot) {
              final overview = snapshot.data ??
                  const CommunityOverview(
                    activeInitiatives: 0,
                    membersParticipating: 0,
                    totalImpactPoints: 0,
                  );

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community Impact',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _Stat(
                              label: 'Active Initiatives',
                              value: '${overview.activeInitiatives}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 48,
                            color: colorScheme.outlineVariant,
                          ),
                          Expanded(
                            child: _Stat(
                              label: 'Members Participating',
                              value: '${overview.membersParticipating}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 48,
                            color: colorScheme.outlineVariant,
                          ),
                          Expanded(
                            child: _Stat(
                              label: 'Total Impact Points',
                              value: '${overview.totalImpactPoints}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: 'Join an Activity',
                  icon: Icons.event_available,
                  color: colorScheme.primary,
                  onTap: widget.onJoinActivity,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  title: 'Log Contribution',
                  icon: Icons.add_circle,
                  color: AppTheme.secondary,
                  onTap: widget.onLogContribution,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  title: 'View Impact',
                  icon: Icons.analytics,
                  color: AppTheme.accent,
                  onTap: widget.onViewImpact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream:
                CommunityService().watchRecentActivityFeed(limit: _feedLimit),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const [];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (items.isEmpty) {
                return Column(
                  children: List.generate(5, (i) {
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(
                          'Member logged a contribution',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        subtitle: Text(
                          'Just now',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        trailing: const Icon(Icons.bolt_outlined, size: 20),
                      ),
                    );
                  }),
                );
              }

              return Column(
                children: [
                  ...items.map((item) {
                    final text = (item['text'] ?? 'New activity') as String;
                    final subtitle = (item['subtitle'] ?? 'Update') as String;

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(text,
                            style: Theme.of(context).textTheme.bodyLarge),
                        subtitle: Text(
                          subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        trailing: const Icon(Icons.bolt_outlined, size: 20),
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() => _feedLimit += 5),
                      child: const Text('Load More'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        child: SizedBox(
          height: 96,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

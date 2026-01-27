import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/activity.dart';
import '../../Models/user.dart';
import '../../Services/Activities/activity_service.dart';
import '../../Services/Community/community_service.dart';
import '../../Shared/theme/app_theme.dart';

class ActivitiesListScreen extends StatefulWidget {
  final bool embedded;

  const ActivitiesListScreen({super.key, this.embedded = false});

  @override
  State<ActivitiesListScreen> createState() => _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends State<ActivitiesListScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<F_User?>(context);

    final content = Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chip('All'),
              _chip('Cleanups'),
              _chip('Events'),
              _chip('Tasks'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<Activity>>(
            stream: ActivityService().watchActivities(type: _filter),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final activities = snapshot.data ?? const [];
              if (activities.isEmpty) {
                return _EmptyState(
                  title: 'No activities yet',
                  subtitle: 'Create one or check back soon.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: activities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return _ActivityCard(activity: activity);
                },
              );
            },
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Activities'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _filter = 'All';
              });
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      floatingActionButton: user == null
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
      body: content,
    );
  }

  Widget _chip(String label) {
    final selected = _filter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _filter = label;
          });
        },
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color statusColor(String status) {
      switch (status) {
        case 'Ongoing':
          return AppTheme.accent; // Teal - active state
        case 'Completed':
          return AppTheme.tertiary; // Gold - success/achievement
        default:
          return AppTheme.secondary; // Medium Green - pending/neutral
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pushNamed(context, '/activities/${activity.id}');
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Chip(
                  label: Text(activity.type,
                      style: Theme.of(context).textTheme.labelMedium),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                activity.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      activity.location,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      activity.dateTime == null
                          ? 'Date TBD'
                          : '${activity.dateTime!.toLocal()}'.split('.').first,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.people_outline,
                      size: 18, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    '${activity.currentParticipants}/${activity.requiredParticipants} participants',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor(activity.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    activity.status,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: statusColor(activity.status)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/activities/${activity.id}');
                  },
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy,
                size: 52,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

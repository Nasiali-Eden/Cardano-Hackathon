import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/activity.dart';
import '../../Models/user.dart';
import '../../Services/Activities/activity_service.dart';

class ActivityDetailScreen extends StatelessWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<F_User?>(context);

    return FutureBuilder<Activity?>(
      future: ActivityService().getActivity(activityId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()));
        }

        final activity = snapshot.data;
        if (activity == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(title: const Text('Activity')),
            body: const Center(child: Text('Activity not found')),
          );
        }

        final joined =
            user != null && activity.participantIds.contains(user.uid);

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(activity.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  background: Container(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: activity.coverImageUrl == null
                        ? const Center(
                            child: Icon(Icons.image_outlined, size: 64))
                        : CachedNetworkImage(
                            imageUrl: activity.coverImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child:
                                  Icon(Icons.broken_image_outlined, size: 64),
                            ),
                          ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activity.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Chip(label: Text(activity.status)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('About',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(activity.description,
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      _DetailsGrid(activity: activity),
                      const SizedBox(height: 16),
                      Text("Who's Joining",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people_outline),
                          const SizedBox(width: 8),
                          Text('${activity.currentParticipants} participants'),
                        ],
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: user == null
                ? FilledButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/welcome'),
                    child: const Text('Sign in to Join'),
                  )
                : joined
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await ActivityService().leaveActivity(
                                    activityId: activityId, userId: user.uid);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('Leave Activity'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Check-in coming soon')),
                                );
                              },
                              child: const Text('Check In'),
                            ),
                          ),
                        ],
                      )
                    : FilledButton(
                        onPressed: () async {
                          await ActivityService().joinActivity(
                              activityId: activityId, userId: user.uid);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Join Activity'),
                      ),
          ),
        );
      },
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  final Activity activity;

  const _DetailsGrid({required this.activity});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget item(
        {required IconData icon,
        required String label,
        required String value}) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        item(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: activity.location),
        item(
          icon: Icons.calendar_today_outlined,
          label: 'Date & Time',
          value: activity.dateTime == null
              ? 'TBD'
              : '${activity.dateTime!.toLocal()}'.split('.').first,
        ),
        item(
            icon: Icons.people_outline,
            label: 'Required',
            value: '${activity.requiredParticipants}'),
        item(
            icon: Icons.group_outlined,
            label: 'Current',
            value: '${activity.currentParticipants}'),
      ],
    );
  }
}

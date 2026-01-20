import 'package:flutter/material.dart';

import '../../Models/announcement.dart';
import '../../Services/Announcements/announcement_service.dart';

class AnnouncementsListScreen extends StatelessWidget {
  const AnnouncementsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: StreamBuilder<List<Announcement>>(
        stream: AnnouncementService().watchAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data ?? const [];
          if (list.isEmpty) {
            return const Center(child: Text('No announcements yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final a = list[i];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(a.pinned
                        ? Icons.push_pin_outlined
                        : Icons.campaign_outlined),
                  ),
                  title: Text(a.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    a.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.pushNamed(context, '/announcements/${a.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../Models/announcement.dart';
import '../../Services/Announcements/announcement_service.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final String announcementId;

  const AnnouncementDetailScreen({super.key, required this.announcementId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Announcement?>(
      future: AnnouncementService()
          .getAnnouncement(communityId: 'default', id: announcementId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final a = snapshot.data;
        if (a == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(title: const Text('Announcement')),
            body: const Center(child: Text('Announcement not found')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Announcement'),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon')),
                  );
                },
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (a.pinned)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        label: const Text('Pinned'),
                        avatar: const Icon(Icons.push_pin_outlined, size: 18),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    a.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    a.createdAt == null
                        ? ''
                        : a.createdAt!.toLocal().toString().split('.').first,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        a.body,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

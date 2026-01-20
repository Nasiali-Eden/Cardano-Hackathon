import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Models/app_notification.dart';
import '../../Models/user.dart';
import '../../Services/Notifications/notification_service.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<F_User?>(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Sign in to view notifications')),
      );
    }

    final unreadOnly = _tab == 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('All')),
                ButtonSegment(value: 1, label: Text('Unread')),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<AppNotification>>(
              stream: NotificationService().watchNotifications(
                userId: user.uid,
                unreadOnly: unreadOnly,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = snapshot.data ?? const [];
                if (list.isEmpty) {
                  return const Center(child: Text('No notifications'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final n = list[i];

                    return Dismissible(
                      key: ValueKey(n.id),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981)
                              .withAlpha((0.20 * 255).toInt()),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.mark_email_read_outlined),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444)
                              .withAlpha((0.20 * 255).toInt()),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          await NotificationService()
                              .markRead(userId: user.uid, notificationId: n.id);
                          return false;
                        }

                        if (direction == DismissDirection.endToStart) {
                          await NotificationService()
                              .delete(userId: user.uid, notificationId: n.id);
                          return true;
                        }

                        return false;
                      },
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(n.read
                                ? Icons.notifications
                                : Icons.notifications_active),
                          ),
                          title: Text(n.title),
                          subtitle: Text(n.body,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: n.read
                              ? null
                              : const Icon(Icons.circle, size: 10),
                          onTap: () async {
                            await NotificationService().markRead(
                                userId: user.uid, notificationId: n.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

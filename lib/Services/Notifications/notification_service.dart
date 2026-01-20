import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Models/app_notification.dart';

class NotificationService {
  final FirebaseFirestore _db;

  NotificationService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<List<AppNotification>> watchNotifications(
      {required String userId, bool unreadOnly = false, int limit = 50}) {
    Query<Map<String, dynamic>> query = _db
        .collection('Users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map(AppNotification.fromDoc).toList();
      if (!unreadOnly) return list;
      return list.where((n) => !n.read).toList();
    });
  }

  Future<void> markRead(
      {required String userId, required String notificationId}) {
    return _db
        .collection('Users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .set({'read': true}, SetOptions(merge: true));
  }

  Future<void> delete(
      {required String userId, required String notificationId}) {
    return _db
        .collection('Users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}

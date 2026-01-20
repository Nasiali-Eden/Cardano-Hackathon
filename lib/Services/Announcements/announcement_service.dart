import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Models/announcement.dart';

class AnnouncementService {
  final FirebaseFirestore _db;

  AnnouncementService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<List<Announcement>> watchAnnouncements(
      {String communityId = 'default', int limit = 50}) {
    return _db
        .collection('communities')
        .doc(communityId)
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(Announcement.fromDoc).toList();
      list.sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  Future<Announcement?> getAnnouncement(
      {required String communityId, required String id}) async {
    final doc = await _db
        .collection('communities')
        .doc(communityId)
        .collection('announcements')
        .doc(id)
        .get();

    if (!doc.exists) return null;
    return Announcement.fromDoc(doc);
  }
}

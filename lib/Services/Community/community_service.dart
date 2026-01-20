import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityOverview {
  final int activeInitiatives;
  final int membersParticipating;
  final int totalImpactPoints;

  const CommunityOverview({
    required this.activeInitiatives,
    required this.membersParticipating,
    required this.totalImpactPoints,
  });
}

class CommunityService {
  final FirebaseFirestore _db;

  CommunityService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<CommunityOverview> watchOverview({String communityId = 'default'}) {
    return _db
        .collection('communities')
        .doc(communityId)
        .snapshots()
        .map((doc) {
      final data = doc.data() ?? {};
      return CommunityOverview(
        activeInitiatives: (data['activeInitiatives'] ?? 0) as int,
        membersParticipating: (data['membersParticipating'] ?? 0) as int,
        totalImpactPoints: (data['totalImpactPoints'] ?? 0) as int,
      );
    });
  }

  Stream<List<Map<String, dynamic>>> watchRecentActivityFeed({
    String communityId = 'default',
    int limit = 5,
  }) {
    return _db
        .collection('communities')
        .doc(communityId)
        .collection('activity_feed')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((d) => {'id': d.id, ...(d.data())}).toList();
    });
  }

  Future<String?> getUserRole({required String userId}) async {
    final doc = await _db.collection('Users').doc(userId).get();
    if (!doc.exists) return null;
    return (doc.data()?['role'] as String?) ?? 'Member';
  }

  Stream<bool> watchPrototypeMode({required String userId}) {
    return _db.collection('Users').doc(userId).snapshots().map((doc) {
      final data = doc.data();
      return (data?['isPrototypeMode'] as bool?) ?? false;
    });
  }
}

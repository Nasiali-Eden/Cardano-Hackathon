import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileData {
  final String name;
  final String location;
  final String? photoUrl;

  const ProfileData({
    required this.name,
    required this.location,
    required this.photoUrl,
  });
}

class ProfileService {
  final FirebaseFirestore _db;

  ProfileService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<ProfileData> watchProfile({required String userId}) {
    return _db.collection('Users').doc(userId).snapshots().map((doc) {
      final data = doc.data() ?? {};
      return ProfileData(
        name: (data['name'] ?? '') as String,
        location: (data['location'] ?? '') as String,
        photoUrl: data['photoUrl'] as String?,
      );
    });
  }

  Future<ProfileData?> getProfile({required String userId}) async {
    final doc = await _db.collection('Users').doc(userId).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    return ProfileData(
      name: (data['name'] ?? '') as String,
      location: (data['location'] ?? '') as String,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String location,
  }) {
    return _db.collection('Users').doc(userId).set({
      'name': name,
      'location': location,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

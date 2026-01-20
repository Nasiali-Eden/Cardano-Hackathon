import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ContributionService {
  final FirebaseFirestore? _db;
  final FirebaseStorage? _storage;

  ContributionService({FirebaseFirestore? db, FirebaseStorage? storage})
      : _db = db,
        _storage = storage;

  FirebaseFirestore get db => _db ?? FirebaseFirestore.instance;

  FirebaseStorage get storage => _storage ?? FirebaseStorage.instance;

  int estimateImpactPoints({
    required String type,
    double? hours,
    String? effort,
    List<String> materials = const [],
  }) {
    if (type == 'Time') {
      final h = hours ?? 0;
      return (h * 10).round().clamp(0, 500);
    }

    if (type == 'Effort') {
      final len = (effort ?? '').trim().length;
      if (len == 0) return 0;
      return (20 + (len / 50).floor() * 5).clamp(0, 200);
    }

    if (type == 'Materials') {
      return (materials.length * 8).clamp(0, 300);
    }

    return 0;
  }

  Future<int> createContribution({
    required String userId,
    String? activityId,
    required String type,
    double? hours,
    String? effort,
    List<String> materials = const [],
    String? notes,
    List<XFile> photos = const [],
    String communityId = 'default',
  }) async {
    final points = estimateImpactPoints(
      type: type,
      hours: hours,
      effort: effort,
      materials: materials,
    );

    final contributionRef = db.collection('contributions').doc();

    final photoUrls = <String>[];
    for (var i = 0; i < photos.length; i++) {
      final file = photos[i];
      final ref = storage.ref().child(
            'contributions/$userId/${contributionRef.id}_$i.jpg',
          );
      await ref.putFile(File(file.path));
      final url = await ref.getDownloadURL();
      photoUrls.add(url);
    }

    final batch = db.batch();

    batch.set(contributionRef, {
      'userId': userId,
      'activityId': activityId,
      'type': type,
      'hours': hours,
      'effort': effort,
      'materials': materials,
      'notes': notes,
      'photoUrls': photoUrls,
      'estimatedImpactPoints': points,
      'communityId': communityId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(
        db.collection('Users').doc(userId),
        {
          'impact_points': FieldValue.increment(points),
        },
        SetOptions(merge: true));

    batch.set(
        db.collection('communities').doc(communityId),
        {
          'totalImpactPoints': FieldValue.increment(points),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));

    batch.set(
      db
          .collection('communities')
          .doc(communityId)
          .collection('activity_feed')
          .doc(),
      {
        'text': 'New contribution logged',
        'subtitle': '$points points added to community impact',
        'createdAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();

    return points;
  }
}

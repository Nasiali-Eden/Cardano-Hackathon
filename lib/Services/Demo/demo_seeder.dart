import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DemoSeeder {
  static const _seedKey = 'demo_seed_v1';
  static const _seedCommsKey = 'demo_seed_comms_v1';

  final FirebaseFirestore _db;

  DemoSeeder({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Future<void> seedIfNeeded({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_seedKey) ?? false;
    if (alreadySeeded) return;

    final existing = await _db.collection('activities').limit(1).get();
    if (existing.docs.isNotEmpty) {
      await prefs.setBool(_seedKey, true);
      return;
    }

    final now = DateTime.now();

    final batch = _db.batch();

    final activity1 = _db.collection('activities').doc();
    batch.set(activity1, {
      'type': 'Cleanups',
      'title': 'Community Cleanup: Riverside Walkway',
      'description':
          'Join neighbors to clean up litter, sort recyclables, and restore the riverside walkway. Gloves and bags provided.',
      'location': 'Riverside Walkway',
      'dateTime':
          Timestamp.fromDate(now.add(const Duration(days: 2, hours: 3))),
      'requiredParticipants': 20,
      'participantIds': <String>[],
      'coverImageUrl': null,
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final activity2 = _db.collection('activities').doc();
    batch.set(activity2, {
      'type': 'Events',
      'title': 'Impact Workshop: Measuring What Matters',
      'description':
          'A short community workshop on how to track contributions, estimate impact points, and keep activity data transparent.',
      'location': 'Community Center - Hall B',
      'dateTime':
          Timestamp.fromDate(now.add(const Duration(days: 5, hours: 1))),
      'requiredParticipants': 40,
      'participantIds': <String>[],
      'coverImageUrl': null,
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final activity3 = _db.collection('activities').doc();
    batch.set(activity3, {
      'type': 'Tasks',
      'title': 'Neighborhood Tree Watering',
      'description':
          'Help water newly planted trees in the neighborhood. Great for short contributions (30–45 minutes).',
      'location': 'Greenway Loop',
      'dateTime':
          Timestamp.fromDate(now.add(const Duration(days: 1, hours: 2))),
      'requiredParticipants': 12,
      'participantIds': <String>[],
      'coverImageUrl': null,
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final community = _db.collection('communities').doc('default');
    batch.set(
        community,
        {
          'activeInitiatives': 3,
          'membersParticipating': 42,
          'totalImpactPoints': 1250,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));

    final feed = community.collection('activity_feed');
    batch.set(feed.doc(), {
      'text': 'New activity created: Neighborhood Tree Watering',
      'subtitle': 'Help keep new trees alive — short contributions welcome.',
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(feed.doc(), {
      'text': 'Community milestone: 1,250 impact points reached',
      'subtitle':
          'Thanks to everyone contributing time, effort, and materials.',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    await prefs.setBool(_seedKey, true);
  }

  Future<void> seedCommsIfNeeded({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_seedCommsKey) ?? false;
    if (alreadySeeded) return;

    final community = _db.collection('communities').doc('default');
    final announcements =
        await community.collection('announcements').limit(1).get();
    final notifications = await _db
        .collection('Users')
        .doc(userId)
        .collection('notifications')
        .limit(1)
        .get();

    if (announcements.docs.isNotEmpty || notifications.docs.isNotEmpty) {
      await prefs.setBool(_seedCommsKey, true);
      return;
    }

    final batch = _db.batch();

    batch.set(community.collection('announcements').doc(), {
      'title': 'Welcome to the Community Hub',
      'body':
          'This is a prototype build. You can join activities, log contributions, and view transparent impact totals.',
      'pinned': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(community.collection('announcements').doc(), {
      'title': 'How Impact Points Work',
      'body':
          'Points are an estimate designed for transparency. Time, effort, and materials each contribute differently. This will be refined with community feedback.',
      'pinned': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(
      _db.collection('Users').doc(userId).collection('notifications').doc(),
      {
        'title': 'You are all set',
        'body':
            'Explore the Impact tab to see your progress visuals and export your data.',
        'type': 'info',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
    await prefs.setBool(_seedCommsKey, true);
  }
}

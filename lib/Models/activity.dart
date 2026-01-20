import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String type;
  final String title;
  final String description;
  final String location;
  final DateTime? dateTime;
  final int requiredParticipants;
  final List<String> participantIds;
  final String? coverImageUrl;

  const Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.requiredParticipants,
    required this.participantIds,
    this.coverImageUrl,
  });

  int get currentParticipants => participantIds.length;

  String get status {
    final dt = dateTime;
    if (dt == null) return 'Upcoming';
    final now = DateTime.now();
    if (dt.isAfter(now)) return 'Upcoming';
    if (dt.isAfter(now.subtract(const Duration(hours: 3)))) return 'Ongoing';
    return 'Completed';
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'location': location,
      'dateTime': dateTime == null ? null : Timestamp.fromDate(dateTime!),
      'requiredParticipants': requiredParticipants,
      'participantIds': participantIds,
      'coverImageUrl': coverImageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static Activity fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    DateTime? _toDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return Activity(
      id: doc.id,
      type: (data['type'] ?? 'Events') as String,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      location: (data['location'] ?? '') as String,
      dateTime: _toDate(data['dateTime']),
      requiredParticipants: (data['requiredParticipants'] ?? 0) as int,
      participantIds:
          (data['participantIds'] as List?)?.cast<String>() ?? const [],
      coverImageUrl: data['coverImageUrl'] as String?,
    );
  }
}

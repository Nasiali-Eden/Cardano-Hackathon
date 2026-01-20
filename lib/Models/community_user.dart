class CommunityUser {
  final String id;
  final String name;
  final String location;
  final String role;
  final String? photoUrl;
  final int impactPoints;
  final DateTime? createdAt;
  final DateTime? guidelinesAcceptedAt;

  const CommunityUser({
    required this.id,
    required this.name,
    required this.location,
    required this.role,
    this.photoUrl,
    required this.impactPoints,
    this.createdAt,
    this.guidelinesAcceptedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'role': role,
      'photoUrl': photoUrl,
      'impact_points': impactPoints,
    };
  }

  static CommunityUser fromMap(
      {required String id, required Map<String, dynamic> map}) {
    DateTime? _toDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    return CommunityUser(
      id: id,
      name: (map['name'] ?? '') as String,
      location: (map['location'] ?? '') as String,
      role: (map['role'] ?? 'Member') as String,
      photoUrl: map['photoUrl'] as String?,
      impactPoints: (map['impact_points'] ?? 0) as int,
      createdAt: _toDate(map['createdAt']),
      guidelinesAcceptedAt: _toDate(map['guidelinesAcceptedAt']),
    );
  }
}

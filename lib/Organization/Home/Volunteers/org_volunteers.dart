import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrgVolunteers extends StatefulWidget {
  const OrgVolunteers({Key? key}) : super(key: key);

  @override
  State<OrgVolunteers> createState() => _OrgVolunteersState();
}

class _OrgVolunteersState extends State<OrgVolunteers> {
  /// Available skills (excluding "All").
  final List<String> _skillOptions = [
    'Medical',
    'Physical',
    'Financial',
    'Legal',
    'Emotional',
    'Shelter',
    'Office-Work',
  ];

  /// A set to handle multi-selection of skills; starts with "Medical" selected.
  final Set<String> _selectedSkills = {'Medical'};

  /// Fetch volunteers for the selected skills.
  Future<List<Map<String, dynamic>>> _fetchVolunteers() async {
    List<Map<String, dynamic>> volunteers = [];

    // If no skills are selected, return an empty list.
    if (_selectedSkills.isEmpty) {
      return volunteers;
    }

    // For each selected skill, fetch from that skill's "Members" subcollection.
    for (String skill in _selectedSkills) {
      final snapshot = await FirebaseFirestore.instance
          .collection('Volunteers')
          .doc(skill)
          .collection('Members')
          .get();

      for (var doc in snapshot.docs) {
        // Ensure the skill field is set (for display).
        final data = doc.data();
        data['skill'] = skill;
        volunteers.add(data);
      }
    }

    // Sort by timestamp descending.
    volunteers.sort((a, b) {
      final aTime = a['timestamp'] as Timestamp?;
      final bTime = b['timestamp'] as Timestamp?;
      return (bTime?.compareTo(aTime!) ?? 0);
    });

    return volunteers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurpleAccent.withAlpha((0.05 * 255).toInt()),
                blurRadius: 4.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Volunteers',
              style: TextStyle(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Multi-select filter bar (without "All").
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchVolunteers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text('No volunteers found.'));
                }
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final vol = data[index];
                    final skill = vol['skill'] ?? 'N/A';
                    final fullName = vol['fullName'] ?? 'N/A';
                    final contact = vol['contact'] ?? vol['userId'] ?? 'N/A';
                    final availability = vol['availability'] ?? 'N/A';
                    final photoUrl = vol['photoUrl'] ?? '';

                    return Card(
                      color: Colors.grey[50],
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListTile(
                        leading: Stack(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: photoUrl.isNotEmpty
                                  ? Image.network(photoUrl, fit: BoxFit.cover)
                                  : const Icon(Icons.person, size: 40),
                            ),
                            // Number overlay at the top-left corner.
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                color: Colors.deepPurpleAccent,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          '$fullName • $skill',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Contact: $contact\nAvailability: $availability',
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

  /// Builds the horizontal multi-select filter bar.
  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: _skillOptions.map((skill) {
          final bool isSelected = _selectedSkills.contains(skill);
          return GestureDetector(
            onTap: () {
              setState(() {
                // Toggle skill selection
                if (isSelected) {
                  _selectedSkills.remove(skill);
                } else {
                  _selectedSkills.add(skill);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurpleAccent : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.deepPurpleAccent, width: 1),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.deepPurpleAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

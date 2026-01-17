import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelpChildScreen extends StatefulWidget {
  final String title;

  const HelpChildScreen({super.key, required this.title});

  @override
  State<HelpChildScreen> createState() => _HelpChildScreenState();
}

class _HelpChildScreenState extends State<HelpChildScreen> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    final collectionRef = _getSubCollection(widget.title);

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
            title: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.deepPurpleAccent),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: collectionRef.snapshots(),
        builder: (context, snapshot) {
          if (widget.title == "Free Medical Services" ||
              widget.title == "Relief Aid") {
            if (!_dialogShown) {
              _dialogShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(widget.title),
                    content: Text(
                      "${widget.title} are not available at the moment.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              });
            }
            return Center(
              child: Text(
                "${widget.title} are not available at the moment.",
                style: const TextStyle(fontSize: 18, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text("No data found for ${widget.title}"));
          }

          return SingleChildScrollView(
            child: Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data['Name'] ?? '';
                final hrs = data['Hours'] ?? '';
                final location = data['Location'] ?? '';
                final contact = data['Contact'] ?? '';

                return _buildDataCard(
                  context: context,
                  name: name,
                  hrs: hrs,
                  location: location,
                  contact: contact,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  CollectionReference _getSubCollection(String title) {
    final helpRef = FirebaseFirestore.instance.collection('Help');

    switch (title) {
      case "Police Services":
        return helpRef.doc('Helplines').collection('Police');
      case "Ambulance Services":
        return helpRef.doc('Helplines').collection('Ambulance');
      case "Firefighters":
        return helpRef.doc('Helplines').collection('Firefighters');
      case "Hospitals":
        return helpRef.doc('Helplines').collection('Hospitals');
      case "Kenya Red Cross":
        return helpRef.doc('Helplines').collection('KRC');
      case "Refugee Camps":
        return helpRef.doc('Resources').collection('Refugee');
      case "Government Shelters":
        return helpRef.doc('Resources').collection('Shelters');
      case "Free Medical Services":
        return helpRef.doc('Resources').collection('Medical');
      case "Relief Aid":
        return helpRef.doc('Resources').collection('Aid');
      default:
        return helpRef.doc('Helplines').collection('Police');
    }
  }

  Widget _buildDataCard({
    required BuildContext context,
    required String name,
    required String hrs,
    required String location,
    required String contact,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.95;
    final String? imagePath = _getImageForCategory(widget.title);

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withAlpha((0.05 * 255).toInt()),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoText("Name: $name"),
                const SizedBox(height: 4),
                _infoText("Operating Hours: $hrs"),
                const SizedBox(height: 4),
                _infoText("Location: $location"),
                const SizedBox(height: 4),
                _infoText("Contact: $contact"),
              ],
            ),
          ),
          const SizedBox(width: 12),
          imagePath != null
              ? Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.cover)
              : Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.image,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String? _getImageForCategory(String title) {
    switch (title) {
      case "Police Services":
        return "assets/police.png";
      case "Ambulance Services":
      case "Hospitals":
        return "assets/hospital.png";
      case "Firefighters":
        return "assets/firefighter.png";
      case "Kenya Red Cross":
        return "assets/redcross.png";
      case "Refugee Camps":
      case "Government Shelters":
        return "assets/refugee.png";
      default:
        return null; // Placeholder for categories without images
    }
  }

  Widget _infoText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReadArticle extends StatelessWidget {
  final Map<String, dynamic> article;

  const ReadArticle({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String headline = article['headline'] ?? 'No Title';
    final Timestamp? timestamp = article['timestamp'] as Timestamp?;
    final String formattedDate = timestamp != null
        ? "${timestamp.toDate().year}-${timestamp.toDate().month}-${timestamp.toDate().day}"
        : "Unknown Date";
    final String content = article['content'] ?? '';

    return Scaffold(
backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}

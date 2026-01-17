import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ArticleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Upload article function
  Future<void> uploadArticle({
    required String headline,
    required String textContent,
    required String type, // Article type
    required File coverPhoto,
    required BuildContext context, // Context for navigation
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated.");
      }

      String articleId = _uuid.v4();

      // Validate word count
      int wordCount = textContent.trim().split(RegExp(r'\s+')).length;
      if (wordCount > 300) {
        throw Exception("Word limit exceeded (Max: 300 words).");
      }

      // Upload cover photo and get the URL
      String coverPhotoUrl = await _uploadCoverPhoto(coverPhoto, articleId);

      Map<String, dynamic> articleData = {
        "articleId": articleId,
        "headline": headline,
        "content": textContent.trim(),
        "type": type, // Store article type
        "coverPhotoUrl": coverPhotoUrl,
        "userId": user.uid,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // Save to Articles collection
      await _firestore.collection("Articles").doc(articleId).set(articleData);

      // Save under Organization's subcollection
      await _firestore
          .collection("Organizations")
          .doc(user.uid)
          .collection("Articles")
          .doc(articleId)
          .set(articleData);

      print("Article uploaded successfully!");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Article posted successfully!")),
      );

      // Navigate back to OrgDashboard (previous screen)
      Navigator.pop(context);
    } catch (e) {
      print("Error uploading article: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload article: $e")),
      );
    }
  }

  // Function to upload cover photo to Firebase Storage
  Future<String> _uploadCoverPhoto(File coverPhoto, String articleId) async {
    try {
      // Storage path
      String storagePath = "article_covers/$articleId.jpg";

      // Upload file
      TaskSnapshot snapshot = await _storage.ref(storagePath).putFile(coverPhoto);

      // Get download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading cover photo: $e");
      throw Exception("Failed to upload cover photo.");
    }
  }
}

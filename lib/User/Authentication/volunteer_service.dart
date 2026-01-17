import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class VolunteerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload passport-size photo with 1:1 aspect ratio.
  Future<String?> _uploadPhoto(File imageFile, String skill, String userId) async {
    try {
      Reference ref = _storage.ref().child("volunteers/$skill/$userId/passport.jpg");

      // Upload file to Firebase Storage.
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading photo: $e");
      return null;
    }
  }

  Future<void> registerVolunteer({
    required String fullName,
    required String skill,
    required String availability,
    required File photo,
    required String contact,
    required BuildContext context,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated.");
      }

      String userId = user.uid;

      // Upload photo and get URL.
      String? photoUrl = await _uploadPhoto(photo, skill, userId);
      if (photoUrl == null) {
        throw Exception("Photo upload failed.");
      }

      // Firestore path: Volunteers -> [skill] doc -> Members subcollection -> [userId] doc.
      DocumentReference volunteerDoc = _firestore
          .collection('Volunteers')
          .doc(skill)
          .collection('Members')
          .doc(userId);

      // Volunteer Data.
      Map<String, dynamic> volunteerData = {
        "fullName": fullName,
        "skill": skill,
        "availability": availability,
        "contact": contact, // Save contact information.
        "photoUrl": photoUrl,
        "userId": userId,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // Save to Firestore.
      await volunteerDoc.set(volunteerData);

      print("Volunteer registered successfully!");

      // Navigate to home screen (replace with your actual screen).
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print("Error registering volunteer: $e");
    }
  }
}

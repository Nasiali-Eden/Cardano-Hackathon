import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/user.dart';

class CommunityAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CommunityAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<F_User?> joinCommunity({
    required String name,
    required String location,
    required String role,
    XFile? profilePhoto,
  }) async {
    try {
      print('[CommunityAuth] join start');
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user == null) {
        print('[CommunityAuth] signInAnonymously returned null user');
        return null;
      }
      print('[CommunityAuth] signed in uid=${user.uid}');

      String? photoUrl;
      if (profilePhoto != null) {
        try {
          final ref = _storage
              .ref()
              .child('users/${user.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
          print('[CommunityAuth] uploading profile photo to ${ref.fullPath}');
          await ref.putFile(File(profilePhoto.path));
          photoUrl = await ref.getDownloadURL();
          print('[CommunityAuth] profile photo uploaded');
        } catch (e, st) {
          print('[CommunityAuth] photo upload error: $e');
          print(st);
          // Continue without photo, but surface error to caller
          rethrow;
        }
      }

      final data = {
        'name': name,
        'location': location,
        'role': role,
        'photoUrl': photoUrl,
        'impact_points': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'guidelinesAcceptedAt': null,
        'communityId': 'default',
        'isPrototypeMode': true,
      };
      print('[CommunityAuth] writing user doc to Users/${user.uid} => $data');
      await _db.collection('Users').doc(user.uid).set(
            data,
            SetOptions(merge: true),
          );

      print('[CommunityAuth] join completed for uid=${user.uid}');
      return F_User(uid: user.uid);
    } on FirebaseException catch (e, st) {
      print('[CommunityAuth] FirebaseException: ${e.code} ${e.message}');
      print(st);
      rethrow;
    } catch (e, st) {
      print('[CommunityAuth] error: $e');
      print(st);
      rethrow;
    }
  }

  Future<void> setGuidelinesAccepted({required String uid}) async {
    await _db.collection('Users').doc(uid).set({
      'guidelinesAcceptedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guidelinesKey(uid), true);
  }

  Future<bool> hasAcceptedGuidelines({required String uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getBool(_guidelinesKey(uid));
    if (local == true) return true;

    final doc = await _db.collection('Users').doc(uid).get();
    if (!doc.exists) return false;
    final acceptedAt = doc.data()?['guidelinesAcceptedAt'];
    final hasAccepted = acceptedAt != null;
    if (hasAccepted) {
      await prefs.setBool(_guidelinesKey(uid), true);
    }
    return hasAccepted;
  }

  String _guidelinesKey(String uid) => 'guidelines_accepted_$uid';
}

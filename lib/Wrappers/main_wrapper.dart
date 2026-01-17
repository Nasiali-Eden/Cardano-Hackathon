import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Home/landing_page.dart';
import '../Models/user.dart';
import '../Organization/Home/org_home.dart';
import '../User/Home/user_home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<F_User?>(context);

    if (user == null) {
      return const LandingPage(); // Unauthenticated user
    } else {
      return RoleBasedHome(userId: user.uid); // Authenticated user
    }
  }
}

class RoleBasedHome extends StatelessWidget {
  final String userId;

  const RoleBasedHome({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _fetchUserDocument(userId),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final role = snapshot.data!.get('role');
          if (role == "Organization") {
            return const OrganizationHome();
          } else {
            return const UserHome();
          }
        } else {
          return const LandingPage(); // User data not found
        }
      },
    );
  }

  Future<DocumentSnapshot> _fetchUserDocument(String userId) async {
    // Check in both 'vendors' and 'buyers' collections
    final orgDoc =
    await FirebaseFirestore.instance.collection('Organizations').doc(userId).get();
    if (orgDoc.exists) return orgDoc;

    final usersDoc =
    await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (usersDoc.exists) return usersDoc;

    // If no document is found in either collection, throw an error
    throw Exception('User not found in Firestore');
  }
}

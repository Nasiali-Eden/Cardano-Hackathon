import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../Shared/Pages/splash_screen.dart';
import '../Community/Home/community_home.dart';
import '../Organization/Home/org_home.dart';
import '../Shared/Pages/community_guidelines.dart';
import '../Shared/Authentication/join_community.dart';
import '../Models/user.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<F_User?>(context);

    if (user == null) {
      return const SplashScreen();
    } else {
      return RoleBasedRouter(user: user);
    }
  }
}

class RoleBasedRouter extends StatefulWidget {
  final F_User user;

  const RoleBasedRouter({super.key, required this.user});

  @override
  State<RoleBasedRouter> createState() => _RoleBasedRouterState();
}

class _RoleBasedRouterState extends State<RoleBasedRouter> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasError) {
          if (kDebugMode) {
            print('[ROUTER] Error determining route: ${snapshot.error}');
          }
          return const SplashScreen();
        } else {
          return snapshot.data ?? const SplashScreen();
        }
      },
    );
  }

  Future<Widget> _determineRoute() async {
    try {
      if (kDebugMode) {
        print('[ROUTER] Determining route for user: ${widget.user.uid}');
      }

      // Check if user exists in members collection
      DocumentSnapshot memberSnapshot = await FirebaseFirestore.instance
          .collection('members')
          .doc(widget.user.uid)
          .get();

      if (memberSnapshot.exists) {
        if (kDebugMode) {
          print('[ROUTER] User found in members collection');
        }
        return _handleUserRoute(memberSnapshot, 'Member');
      }

      // Check if user exists in org_rep collection
      DocumentSnapshot orgSnapshot = await FirebaseFirestore.instance
          .collection('org_rep')
          .doc(widget.user.uid)
          .get();

      if (orgSnapshot.exists) {
        if (kDebugMode) {
          print('[ROUTER] User found in org_rep collection');
        }
        return _handleUserRoute(orgSnapshot, 'Org Rep');
      }

      // User not found in either collection
      if (kDebugMode) {
        print('[ROUTER] User not found in any collection, redirecting to join');
      }
      return const JoinCommunityScreen();
    } catch (e) {
      if (kDebugMode) {
        print('[ROUTER] Error fetching user data: $e');
      }
      return const SplashScreen();
    }
  }

  Widget _handleUserRoute(DocumentSnapshot userDoc, String role) {
    final data = userDoc.data() as Map<String, dynamic>?;
    final acceptedAt = data?['guidelinesAcceptedAt'];

    if (kDebugMode) {
      print('[ROUTER] Role: $role, Guidelines accepted: ${acceptedAt != null}');
    }

    // Check if user has accepted guidelines
    if (acceptedAt == null) {
      if (kDebugMode) {
        print('[ROUTER] Guidelines not accepted, redirecting to guidelines');
      }
      return const CommunityGuidelinesScreen();
    }

    // Route based on role
    if (role == 'Org Rep') {
      if (kDebugMode) {
        print('[ROUTER] Routing to Organization Home');
      }
      return const OrganizationHome();
    } else {
      if (kDebugMode) {
        print('[ROUTER] Routing to Community Home');
      }
      return const CommunityHomeScreen();
    }
  }
}

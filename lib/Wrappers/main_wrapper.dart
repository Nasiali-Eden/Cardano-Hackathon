import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Shared/Pages/splash_screen.dart';
import '../Community/Home/community_home.dart';
import '../Models/user.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<F_User?>(context);

    if (user == null) {
      return const SplashScreen();
    } else {
      return const CommunityHomeScreen();
    }
  }
}

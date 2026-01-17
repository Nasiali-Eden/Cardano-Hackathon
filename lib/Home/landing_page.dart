import 'package:city_watch/Organization/Authentication/org_registration.dart';
import 'package:city_watch/User/Authentication/user_registration.dart';
import 'package:flutter/material.dart';
import '../Reusables/footer/logo.dart';
import '../Shared/Pages/login.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Positioned text at the top
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset('pngs/logotext.png', scale: 1.5)
            ),
          ),
          // Center section with containers
          Center(
            child: SizedBox(
              width: 0.90 * deviceWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Container for Normal User
                  _buildSquareContainer(
                    icon: Icons.person,
                    label: 'Normal User',
                    color: Colors.blue.shade100,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserRegistration(),
                        ),
                      );
                      // Navigate or perform any action for Normal User
                    },
                  ),
                  const SizedBox(width: 16), // Add horizontal space
                  // Container for Organisation
                  _buildSquareContainer(
                    icon: Icons.business,
                    label: 'Organisation',
                    color: Colors.green.shade100,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrganizationRegistration(),
                        ),
                      );
                      // Navigate or perform any action for Organisation
                    },
                  ),
                ],
              ),
            ),
          ),
          // Sign-in link
          Positioned(
            bottom: 85,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already Have an Account?',
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Footer logo at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: FooterLogo(), // Add your Footer widget here
          ),
        ],
      ),
    );
  }

  Widget _buildSquareContainer({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed, // Function for the onPressed action
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed, // Attach the onPressed function here
        child: AspectRatio(
          aspectRatio: 1, // Makes the container a square
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

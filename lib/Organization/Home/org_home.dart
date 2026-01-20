import 'Dashboard/org_dashboard.dart';
import 'Profile/org_profile.dart';
import 'Volunteers/org_volunteers.dart';
import '../../Community/Impact/impact_dashboard.dart';
import 'package:flutter/material.dart';

class OrganizationHome extends StatefulWidget {
  const OrganizationHome({super.key});

  @override
  State<OrganizationHome> createState() => _OrganizationHomeState();
}

class _OrganizationHomeState extends State<OrganizationHome> {
  int currentPage = 0;

  // GlobalKey for OrgDashboard (the first page)
  final GlobalKey<OrgDashboardState> dashboardKey =
      GlobalKey<OrgDashboardState>();

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      OrgDashboard(key: dashboardKey),
      const ImpactDashboardScreen(),
      const OrgVolunteers(),
      const OrgProfile(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: currentPage,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withAlpha((0.05 * 255).toInt()),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          elevation: 0,
          color: Colors.white,
          height: 85.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildNavItem(Icons.apps, "Dashboard", 0),
              _buildNavItem(Icons.bolt_outlined, "Impact", 1),
              _buildNavItem(Icons.construction, "Volunteers", 2),
              _buildNavItem(Icons.person_2_outlined, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: currentPage == index
                ? const Color.fromRGBO(124, 77, 255, 1.0)
                : const Color.fromRGBO(40, 40, 40, 1),
          ),
          iconSize: 25.0,
          onPressed: () {
            if (index == 0 && currentPage == 0) {
              dashboardKey.currentState?.popToRoot();
            } else {
              setState(() {
                currentPage = index;
              });
            }
          },
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.0,
            color: currentPage == index
                ? const Color.fromRGBO(124, 77, 255, 1.0)
                : const Color.fromRGBO(40, 40, 40, 1),
          ),
        )
      ],
    );
  }
}

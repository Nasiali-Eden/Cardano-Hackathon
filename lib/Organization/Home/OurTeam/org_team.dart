import 'add_team.dart';
import 'package:flutter/material.dart';

class OrgTeam extends StatefulWidget {
  const OrgTeam({super.key});

  @override
  State<OrgTeam> createState() => _OrgTeamState();
}

class _OrgTeamState extends State<OrgTeam> {
  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0), // Set the height of the AppBar
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurpleAccent.withAlpha(
                    (0.05 * 255).toInt()), // Shadow color with opacity
                blurRadius: 4.0, // Adjust the blur radius
                offset: Offset(0, 3), // Position of the shadow
              ),
            ],
          ),
          child: AppBar(
            backgroundColor:
                Colors.transparent, // Make the AppBar background transparent
            elevation: 0, // Remove default shadow
            title: Text(
              'My Team',
              style: TextStyle(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 12,
            ),
            Container(
              margin: EdgeInsets.all(10),
              width: 0.90 * deviceWidth,
              height: 50,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    Text(
                      'Add new team',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddTeam()),
                  );
                },
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Divider(
              color: Colors.deepPurple, // Line color
              thickness: 3.0, // Line thickness
              height: 15.0, // Space above and below the line
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                'Teams',
                style: TextStyle(color: Colors.deepPurple[700], fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

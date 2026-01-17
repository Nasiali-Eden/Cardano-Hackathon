import 'package:city_watch/Shared/Inputs/post_incident.dart';
import 'package:city_watch/User/Home/HomeScreen/read_article.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Authentication/volunteer_reg.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => UserHomeScreenState();
}

class UserHomeScreenState extends State<UserHomeScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Call this method to pop the nested navigator back to the home (root) page.
  void popToRoot() {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  // Show the popup menu for the + button.
  void _showMenu(BuildContext context, Offset offset) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      color: Colors.white,
      items: [
        PopupMenuItem(
          value: 'report',
          child: ListTile(
            leading: const Icon(Icons.report, color: Colors.deepPurpleAccent),
            title: const Text('Report Incident'),
          ),
        ),
        PopupMenuItem(
          value: 'volunteer',
          child: ListTile(
            leading: const Icon(Icons.volunteer_activism, color: Colors.teal),
            title: const Text('Become a Volunteer'),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'report') {
        _navigatorKey.currentState?.pushNamed('/postIncident');
      } else if (value == 'volunteer') {
        _navigatorKey.currentState?.pushNamed('/volunteer');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Note: deviceWidth is not used here, but available if needed.
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurpleAccent.withAlpha((0.05 * 255).toInt()),
                blurRadius: 4.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Home',
              style: TextStyle(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.deepPurpleAccent),
                onPressed: () {
                  RenderBox? overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox?;
                  Offset offset =
                      overlay?.localToGlobal(overlay.size.topRight(Offset.zero)) ??
                          Offset.zero;
                  _showMenu(context, offset);
                },
              ),
            ],
          ),
        ),
      ),
      // Nested navigator for child routes.
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
              builder = (BuildContext _) => const HomeContent();
              break;
            case '/postIncident':
              builder = (BuildContext _) => const PostIncident();
              break;
            case '/volunteer':
              builder = (BuildContext _) => const VolunteerReg();
              break;
            case '/readArticle':
            // Pass the article data via settings.arguments.
              builder = (BuildContext _) => ReadArticle(
                  article: settings.arguments as Map<String, dynamic>);
              break;
            default:
              builder = (BuildContext _) => const HomeContent();
          }
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        },
      ),
    );
  }
}

/// Updated HomeContent widget that loads and displays articles from Firestore.
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  // Returns a headline truncated to [maxWords] words with an ellipsis if necessary.
  String _truncateHeadline(String headline, int maxWords) {
    final words = headline.split(' ');
    if (words.length <= maxWords) return headline;
    return words.take(maxWords).join(' ') + '...';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            'Top Updates',
            style: TextStyle(
              color: Colors.teal[800],
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Divider(
          color: Colors.teal[800],
          thickness: 3.0,
          height: 15.0,
        ),
        // Expanded widget to fill available space with the grid of articles.
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Articles")
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No articles available"));
              }
              final articles = snapshot.data!.docs;
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Three articles per row.
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7, // Adjusted aspect ratio for three columns.
                ),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final articleData =
                  articles[index].data() as Map<String, dynamic>;
                  final String coverPhotoUrl = articleData['coverPhotoUrl'] ?? '';
                  final String headline = articleData['headline'] ?? 'No Title';
                  final Timestamp? timestamp = articleData['timestamp'] as Timestamp?;
                  final String formattedDate = timestamp != null
                      ? "${timestamp.toDate().year}-${timestamp.toDate().month}-${timestamp.toDate().day}"
                      : "Unknown Date";

                  return GestureDetector(
                    onTap: () {
                      // Navigate to the ReadArticle page with the full article data.
                      Navigator.of(context).pushNamed(
                        '/readArticle',
                        arguments: articleData,
                      );

                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)),
                      elevation: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cover photo container.
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(0)),
                              child: coverPhotoUrl.isNotEmpty
                                  ? Image.network(
                                coverPhotoUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: Colors.white,
                                width: double.infinity,
                                child: const Icon(Icons.image,
                                    size: 50, color: Colors.white),
                              ),
                            ),
                          ),
                          // Truncated headline.
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              _truncateHeadline(headline, 10),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Date of publishing.
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

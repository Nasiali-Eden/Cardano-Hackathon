import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:city_watch/Shared/Inputs/post_incident.dart';
import '../../Articles/post_article.dart';

class OrgDashboard extends StatefulWidget {
  const OrgDashboard({super.key});

  @override
  OrgDashboardState createState() => OrgDashboardState();
}

class OrgDashboardState extends State<OrgDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> incidentTypes = [
    'Fire',
    'Accident',
    'Health',
    'Floods',
    'Other'
  ];
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void popToRoot() {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  void _showMenu(BuildContext context, Offset offset) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: [
        PopupMenuItem(
          value: 'uploadArticle',
          child: ListTile(
            leading: const Icon(Icons.article, color: Colors.teal),
            title: const Text('Upload Article'),
          ),
        ),
        PopupMenuItem(
          value: 'uploadIncident',
          child: ListTile(
            leading: const Icon(Icons.report, color: Colors.teal),
            title: const Text('Upload Incident'),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'uploadArticle') {
        _navigatorKey.currentState?.pushNamed('/uploadArticle');
      } else if (value == 'uploadIncident') {
        _navigatorKey.currentState?.pushNamed('/uploadIncident');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              'Dashboard',
              style: TextStyle(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle,
                    color: Colors.deepPurpleAccent),
                onPressed: () {
                  RenderBox? overlay = Overlay.of(context)
                      .context
                      .findRenderObject() as RenderBox?;
                  Offset offset = overlay
                          ?.localToGlobal(overlay.size.topRight(Offset.zero)) ??
                      Offset.zero;
                  _showMenu(context, offset);
                },
              ),
            ],
          ),
        ),
      ),
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
              builder = (BuildContext _) => _DashboardContent(
                    firestore: _firestore,
                    incidentTypes: incidentTypes,
                  );
              break;
            case '/uploadArticle':
              builder = (BuildContext _) => PostArticle();
              break;
            case '/uploadIncident':
              builder = (BuildContext _) => PostIncident();
              break;
            default:
              builder = (BuildContext _) => _DashboardContent(
                    firestore: _firestore,
                    incidentTypes: incidentTypes,
                  );
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

class _DashboardContent extends StatelessWidget {
  final FirebaseFirestore firestore;
  final List<String> incidentTypes;
  const _DashboardContent(
      {super.key, required this.firestore, required this.incidentTypes});

  Future<Map<String, int>> _getIncidentCounts() async {
    QuerySnapshot snapshot = await firestore.collection('Incidents').get();
    Map<String, int> counts = {for (var type in incidentTypes) type: 0};
    for (var doc in snapshot.docs) {
      String type = doc['type'];
      if (counts.containsKey(type)) {
        counts[type] = (counts[type] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 70),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            height: 31,
            width: MediaQuery.of(context).size.width,
            color: Colors.deepPurpleAccent[200],
            child: const Text(
              'Reports Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.70,
            child: FutureBuilder(
              future: _getIncidentCounts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final counts = snapshot.data as Map<String, int>;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: incidentTypes.length,
                  itemBuilder: (context, index) {
                    String type = incidentTypes[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IncidentListScreen(type: type),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(6),
                            border:
                                Border.all(color: Colors.black54, width: 0.1)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                          child: Center(
                            child: Text(
                              "$type Reports: ${counts[type] ?? 0}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class IncidentListScreen extends StatelessWidget {
  final String type;
  const IncidentListScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('$type Reports'),
        backgroundColor: Colors.grey[100],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Incidents')
            .where('type', isEqualTo: type)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final incidents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              var incident = incidents[index];
              return Card(
                color: Colors.grey[50],
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(incident['headline'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Uploaded: ${incident['timestamp'].toDate()}"),
                      const SizedBox(height: 8),
                      Text(incident['description']),
                      if (incident['images'] != null &&
                          (incident['images'] as List).isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: (incident['images'] as List)
                                .map((imgUrl) => GestureDetector(
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (_) => Dialog(
                                          child: Image.network(imgUrl),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.network(imgUrl,
                                            width: 80, height: 80),
                                      ),
                                    ))
                                .toList(),
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
    );
  }
}

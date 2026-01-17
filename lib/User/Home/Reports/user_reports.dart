import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserReports extends StatefulWidget {
  const UserReports({Key? key}) : super(key: key);

  @override
  State<UserReports> createState() => _UserReportsState();
}

class _UserReportsState extends State<UserReports> {
  GoogleMapController? _mapController;
  bool _showDrawer = false;

  // Kirinyaga County bounding box (retain this because all reports are within)
  final LatLngBounds kirinyagaBounds =  LatLngBounds(
    southwest: LatLng(-0.814, 37.073), // SW Corner
    northeast: LatLng(-0.373, 37.525), // NE Corner
  );

  // Stream of Incidents from Firestore, sorted by timestamp descending.
  final Stream<QuerySnapshot> _incidentsStream = FirebaseFirestore.instance
      .collection('Incidents')
      .orderBy('timestamp', descending: true)
      .snapshots();

  // Google Map markers.
  Set<Marker> _markers = {};

  /// Toggles the drawer open/closed.
  void _toggleDrawer() {
    setState(() {
      _showDrawer = !_showDrawer;
    });
  }

  /// Returns a marker icon based on incident type.
  BitmapDescriptor _getMarkerColor(String type) {

    switch (type.toLowerCase()) {
      case 'fire':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'accident':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); // Pink-ish.
      case 'health':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'floods':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'other':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow); // Gray-ish.
      default:
        return BitmapDescriptor.defaultMarker;
    }

  }

  /// Truncates the headline to [maxWords] words.
  String _truncateHeadline(String headline, int maxWords) {
    final words = headline.split(' ');
    if (words.length <= maxWords) return headline;
    return words.take(maxWords).join(' ') + '...';
  }

  /// Converts a "latitude, longitude" string to a LatLng.
  LatLng? _parseLocation(String? location) {
    if (location == null || !location.contains(',')) return null;
    final parts = location.split(',');
    if (parts.length != 2) return null;
    try {
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());
      return LatLng(lat, lng);
    } catch (_) {
      return null;
    }
  }

  /// Shows a popup dialog with the incident details.
  void _showIncidentPopup(BuildContext context, Map<String, dynamic> incidentData) {
    final headline = incidentData['headline'] ?? 'No Title';
    final timestamp = incidentData['timestamp'] as Timestamp?;
    final dateString = timestamp != null
        ? "${timestamp.toDate().year}-${timestamp.toDate().month}-${timestamp.toDate().day}"
        : "Unknown Date";
    final description = incidentData['description'] ?? 'No Description';
    final images = (incidentData['images'] as List?)?.cast<String>() ?? [];

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54, // Dimmed background.
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateString,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                if (images.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: images.map((imgUrl) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 80,
                          height: 80,
                          child: Image.network(imgUrl, fit: BoxFit.cover),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a marker for a given incident.
  Marker _buildMarker(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final locationString = data['location'] as String?;
    final latLng = _parseLocation(locationString);
    final incidentId = data['incidentId'] ?? doc.id;
    final incidentType = data['type'] ?? 'other';

    return Marker(
      markerId: MarkerId(incidentId),
      position: latLng ?? const LatLng(0, 0),
      icon: _getMarkerColor(incidentType),
      onTap: () => _showIncidentPopup(context, data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom app bar.
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
              'Incidents',
              style: TextStyle(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            actions: [
              if (!_showDrawer)
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.deepPurpleAccent),
                  onPressed: _toggleDrawer,
                ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_showDrawer) {
            setState(() {
              _showDrawer = false;
            });
          }
        },
        child: Stack(
          children: [
            // Google Map.
            StreamBuilder<QuerySnapshot>(
              stream: _incidentsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                _markers = docs.map(_buildMarker).toSet();

                return GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-0.6, 37.3), // Center of Kirinyaga.
                    zoom: 12,
                  ),
                  cameraTargetBounds: CameraTargetBounds(kirinyagaBounds),
                  minMaxZoomPreference: const MinMaxZoomPreference(10, 16),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  onMapCreated: (controller) => _mapController = controller,
                );
              },
            ),

            // Animated Drawer.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _showDrawer ? 0 : -MediaQuery.of(context).size.width * 0.78,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.78,
                height: MediaQuery.of(context).size.height,
                child: Material(
                  color: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  elevation: 5,
                  child: Column(
                    children: [
                      // Drawer header.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 18),
                            child: Text(
                              'Recent Updates',
                              style: TextStyle(
                                color: Colors.teal[700],
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          IconButton(
                            icon:  Icon(Icons.close,
                                color: Colors.deepPurpleAccent[500]),
                            onPressed: _toggleDrawer,
                          ),
                        ],
                      ),
                      // Incidents list in drawer.
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _incidentsStream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final docs = snapshot.data!.docs;
                            if (docs.isEmpty) {
                              return const Center(
                                child: Text('No incidents found.'),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data =
                                docs[index].data() as Map<String, dynamic>;
                                final headline =
                                    data['headline'] ?? 'No Headline';
                                final truncatedHeadline =
                                _truncateHeadline(headline, 10);
                                return GestureDetector(
                                  onTap: () {
                                    _showIncidentPopup(context, data);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 4),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      truncatedHeadline,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

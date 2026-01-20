import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../Services/Incidents/incident_upload.dart';
import '../../Services/Incidents/map_selection.dart';

class PostIncident extends StatefulWidget {
  const PostIncident({super.key});

  @override
  State<PostIncident> createState() => _PostIncidentState();
}

class _PostIncidentState extends State<PostIncident> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _headlineController = TextEditingController();
  final UploadIncident _uploadIncident = UploadIncident();

  String _selectedType = '';
  LatLng? _selectedLatLng;
  List<File> _selectedImages = [];

  Future<void> _pickImages() async {
    List<File> images = await _uploadIncident.pickAndCropImages();
    setState(() {
      _selectedImages = images;
    });
  }

  Future<void> _getCurrentLocation() async {
    String? location = await _uploadIncident.getCurrentLocation();
    if (location != null) {
      List<String> latLng = location.split(",");
      setState(() {
        _selectedLatLng =
            LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
      });
    }
  }

  Future<void> _selectCustomLocation() async {
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapSelectionScreen()),
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLatLng = selectedLocation;
      });
    }
  }

  void _postIncident() {
    if (_formKey.currentState!.validate() &&
        _selectedType.isNotEmpty &&
        (_selectedLatLng != null)) {
      _uploadIncident.uploadIncident(
        headline: _headlineController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        images: _selectedImages,
        customLocation: _selectedLatLng, // Pass selected location
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true)
          .pushReplacementNamed('/contributions/log');
    });

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[700],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    'Report Incident',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Headline Input
              _buildSectionTitle('1. Input Headline'),
              _buildTextField(_headlineController, 'Enter headline...'),

              const SizedBox(height: 20),

              // Incident Type
              _buildSectionTitle('2. Select Incident Type'),
              DropdownButtonFormField<String>(
                value: _selectedType.isEmpty ? null : _selectedType,
                decoration: _inputDecoration(),
                items: ['Fire', 'Accident', 'Health', 'Floods', 'Other']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select an incident type' : null,
              ),

              const SizedBox(height: 20),

              // Description Input
              _buildSectionTitle('3. Describe the Incident'),
              _buildTextField(_descriptionController, 'Enter description...',
                  maxLines: 3),

              const SizedBox(height: 20),

              // Location Selection
              _buildSectionTitle('4. Choose Location'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLocationButton(
                      "Use Current Location", _getCurrentLocation),
                  _buildLocationButton(
                      "Select Custom Location", _selectCustomLocation),
                ],
              ),
              if (_selectedLatLng != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Selected Location: ${_selectedLatLng!.latitude}, ${_selectedLatLng!.longitude}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),

              const SizedBox(height: 20),

              // Image Upload
              _buildSectionTitle('5. Upload Images'),
              ElevatedButton(
                style: _elevatedButtonStyle(),
                onPressed: _pickImages,
                child: const Text(
                  "Pick Images",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (_selectedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedImages
                        .map((image) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ))
                        .toList(),
                  ),
                ),

              const SizedBox(height: 30),

              // Post Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _postIncident,
                  child: const Text(
                    "Post Incident",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: _inputDecoration().copyWith(hintText: hintText),
      validator: (value) =>
          value!.isEmpty ? 'This field cannot be empty' : null,
    );
  }

  Widget _buildLocationButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: _elevatedButtonStyle(),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black54),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  ButtonStyle _elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.teal[700],
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

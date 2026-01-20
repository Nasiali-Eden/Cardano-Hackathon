import 'dart:io';
import 'volunteer_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VolunteerReg extends StatefulWidget {
  const VolunteerReg({super.key});

  @override
  State<VolunteerReg> createState() => _VolunteerRegState();
}

class _VolunteerRegState extends State<VolunteerReg> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  // State variables to hold the selected values.
  String _skill = '';
  String _availability = '';
  String _name = '';
  String _contact = '';

  // Dropdown options.
  final List<String> _skillOptions = [
    'Medical',
    'Physical',
    'Financial',
    'Legal',
    'Emotional',
    'Shelter',
    'Office-Work',
  ];

  final List<String> _availabilityOptions = [
    'Full-Time',
    'When Needed',
  ];

  // Update name as the user types.
  void _onNameChanged(String value) {
    setState(() {
      _name = value;
    });
  }

  // Update contact as the user types.
  void _onContactChanged(String value) {
    setState(() {
      _contact = value;
    });
  }

  // Called when the user presses "Register".
  void _onRegisterPressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPhoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload a passport-size photo")),
        );
        return;
      }

      try {
        await VolunteerService().registerVolunteer(
          fullName: _name,
          skill: _skill,
          availability: _availability,
          photo: _selectedPhoto!,
          contact: _contact,
          context: context,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Volunteer Registered Successfully")),
        );

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  File? _selectedPhoto;

  Future<void> _pickPhoto() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Reduce size while maintaining quality.
      maxHeight: 500, // Ensure 1:1 aspect ratio.
      maxWidth: 500,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedPhoto = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(0.0),
          children: [
            // Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  height: 35,
                  color: Colors.teal[700],
                  child: const Text(
                    'Register as volunteer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            // Name Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '1. Full Names',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 0.1),
                  ),
                ),
                onChanged: _onNameChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your full names';
                  }
                  return null;
                },
              ),
            ),
            // Contact Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: '2. Contact Details',
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 0.1),
                  ),
                ),
                onChanged: _onContactChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your contact details';
                  }
                  return null;
                },
              ),
            ),
            // Skill Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _skill.isNotEmpty ? _skill : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: '3. Choose your Skills',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 0.1),
                  ),
                ),
                items: _skillOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _skill = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a skill';
                  }
                  return null;
                },
              ),
            ),
            // Availability Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _availability.isNotEmpty ? _availability : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: '4. Confirm availability',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black54),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87, width: 0.1),
                  ),
                ),
                items: _availabilityOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _availability = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your availability';
                  }
                  return null;
                },
              ),
            ),
            // Photo Upload
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    '5. Add a Passport Size photo',
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      size: 21,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _selectedPhoto != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.file(
                            _selectedPhoto!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            // Register Button
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _onRegisterPressed,
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

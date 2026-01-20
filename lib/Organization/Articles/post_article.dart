import 'dart:io';

import '../Home/Dashboard/org_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'article_service.dart';
// Ensure you have the Dashboard screen

class PostArticle extends StatefulWidget {
  const PostArticle({super.key});

  @override
  State<PostArticle> createState() => _PostArticleState();
}

class _PostArticleState extends State<PostArticle> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  String? _selectedType;
  File? _coverPhoto;
  bool _isPosting = false;

  final List<String> _articleTypes = ["Health", "Fire", "Wildlife", "Security"];

  // Function to select a cover photo
  Future<void> _pickCoverPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _coverPhoto = File(image.path);
      });
    }
  }

  // Function to post the article
  Future<void> _postArticle() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == null) {
        _showSnackBar("Please select an article type.");
        return;
      }

      if (_coverPhoto == null) {
        _showSnackBar("Please select a cover photo.");
        return;
      }

      setState(() {
        _isPosting = true; // Show loading indicator
      });

      try {
        await ArticleService().uploadArticle(
          headline: _headlineController.text.trim(),
          textContent: _textController.text.trim(),
          type: _selectedType!,
          coverPhoto: _coverPhoto!,
          context: context,
        );

        _showSnackBar("Article posted successfully!", success: true);

        // Navigate to Dashboard after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OrgDashboard()),
          );
        });
      } catch (e) {
        _showSnackBar("Failed to post article: ${e.toString()}");
      } finally {
        setState(() {
          _isPosting = false; // Hide loading indicator
        });
      }
    }
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              _buildHeadlineField(),
              _buildTextField(),
              _buildTypeSelection(),
              _buildCoverPhotoPicker(),
              _buildPostButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      height: 35,
      color: Colors.teal[700],
      child: const Text(
        'Create Article',
        style: TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildHeadlineField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextFormField(
        controller: _headlineController,
        decoration: const InputDecoration(
          labelText: '1. Headline',
          labelStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black54)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black87)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please add the headline';
          return null;
        },
      ),
    );
  }

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("2. Write your article",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _textController,
            maxLines: 6,
            maxLength: 1500, // Approximate character limit for 300 words
            decoration: const InputDecoration(
              labelText: "Enter your article text",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return "Text cannot be empty.";
              int wordCount = value.trim().split(RegExp(r'\s+')).length;
              if (wordCount > 300) return "Text exceeds 300-word limit.";
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("3. Select type",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Column(
            children: _articleTypes.map((type) {
              return RadioListTile<String>(
                title: Text(type),
                value: type,
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPhotoPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("4. Cover Photo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _coverPhoto != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_coverPhoto!,
                      height: 150, width: 150, fit: BoxFit.cover),
                )
              : Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey)),
                ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _pickCoverPhoto,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text("Choose Cover Photo",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPostButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.all(15)),
        onPressed: _isPosting ? null : _postArticle,
        child: _isPosting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Post', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

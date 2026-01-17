import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String labelText;
  final bool obscureText;
  final Function(String) onChanged;


  const MyTextField({
    super.key,
    required this.controller,
    required this.validator,
    required this.labelText,
    required this.obscureText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
      child: TextFormField(
        cursorColor: Colors.black,
        cursorWidth: 0.5,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding:  EdgeInsets.symmetric(horizontal:10,vertical: 0.0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54, width: 0.1),
          ),
          fillColor: Colors.grey.shade100,
          filled: true,
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.deepPurpleAccent,fontSize: 14),
        ),
        validator: validator, // Pass the validator function here
        onChanged: onChanged,
      ),
    );
  }
}
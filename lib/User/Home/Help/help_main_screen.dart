import 'package:flutter/material.dart';

class HelpMainScreen extends StatelessWidget {
  const HelpMainScreen({super.key});

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
              'Help and Resources',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "HelpLines",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 18),
            _buildButton(context, "Police Services"),
            _buildButton(context, "Ambulance Services"),
            _buildButton(context, "Firefighters"),
            _buildButton(context, "Hospitals"),
            _buildButton(context, "Kenya Red Cross"),
            const SizedBox(height: 16),
            const Text(
              "Nearby Resources",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 18),
            _buildButton(context, "Refugee Camps"),
            _buildButton(context, "Government Shelters"),
            _buildButton(context, "Free Medical Services"),
            _buildButton(context, "Relief Aid"),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text) {
    return GestureDetector(
      onTap: () {
        // Navigate within the nested Navigator to show a child screen.
        Navigator.of(context).pushNamed('/child', arguments: {'title': text});
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockchainDevSettingsScreen extends StatefulWidget {
  const BlockchainDevSettingsScreen({super.key});

  @override
  State<BlockchainDevSettingsScreen> createState() =>
      _BlockchainDevSettingsScreenState();
}

class _BlockchainDevSettingsScreenState
    extends State<BlockchainDevSettingsScreen> {
  static const _key = 'dev_blockchain_preview_enabled';

  bool _loading = true;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getBool(_key) ?? false;
      _loading = false;
    });
  }

  Future<void> _set(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    setState(() => _enabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Developer: Blockchain')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: SwitchListTile(
                      value: _enabled,
                      onChanged: _set,
                      title: const Text('Enable blockchain preview screens'),
                      subtitle: const Text(
                          'This does not enable real Cardano integration.'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.verified_outlined),
                      title: const Text('Open Transparency Preview'),
                      onTap: () => Navigator.pushNamed(
                          context, '/blockchain/transparency'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

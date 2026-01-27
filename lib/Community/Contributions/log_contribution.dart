import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../Models/user.dart';
import '../../Services/Contributions/contribution_service.dart';

class LogContributionScreen extends StatefulWidget {
  const LogContributionScreen({super.key});

  @override
  State<LogContributionScreen> createState() => _LogContributionScreenState();
}

class _LogContributionScreenState extends State<LogContributionScreen> {
  final _formKey = GlobalKey<FormState>();

  String _type = 'Time';

  final _hoursController = TextEditingController();
  final _effortController = TextEditingController();
  final _materialsController = TextEditingController();
  final _notesController = TextEditingController();

  final _picker = ImagePicker();
  final List<XFile> _photos = [];

  bool _saving = false;

  @override
  void dispose() {
    _hoursController.dispose();
    _effortController.dispose();
    _materialsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<String> _parseMaterials() {
    final text = _materialsController.text;
    if (text.trim().isEmpty) return const [];
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  double? _parseHours() {
    final v = _hoursController.text.trim();
    if (v.isEmpty) return null;
    return double.tryParse(v);
  }

  int _estimate() {
    return ContributionService().estimateImpactPoints(
      type: _type,
      hours: _parseHours(),
      effort: _effortController.text,
      materials: _parseMaterials(),
    );
  }

  Future<void> _pickPhotos() async {
    final list = await _picker.pickMultiImage(imageQuality: 85);
    if (!mounted) return;

    setState(() {
      for (final f in list) {
        if (_photos.length >= 3) break;
        _photos.add(f);
      }
    });
  }

  Future<void> _submit() async {
    final user = Provider.of<F_User?>(context, listen: false);
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/welcome');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    try {
      final points = await ContributionService().createContribution(
        userId: user.uid,
        type: _type,
        hours: _type == 'Time' ? _parseHours() : null,
        effort: _type == 'Effort' ? _effortController.text.trim() : null,
        materials: _type == 'Materials' ? _parseMaterials() : const [],
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        photos: _photos,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/contributions/confirm',
        arguments: {'points': points},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final points = _estimate();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Log Contribution'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            onChanged: () => setState(() {}),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _type,
                          decoration: const InputDecoration(
                              labelText: 'Contribution Type'),
                          items: const [
                            DropdownMenuItem(
                                value: 'Time', child: Text('Time (hours)')),
                            DropdownMenuItem(
                                value: 'Effort',
                                child: Text('Effort (description)')),
                            DropdownMenuItem(
                                value: 'Materials',
                                child: Text('Materials (items)')),
                          ],
                          onChanged: (v) => setState(() => _type = v ?? 'Time'),
                        ),
                        const SizedBox(height: 12),
                        if (_type == 'Time')
                          TextFormField(
                            controller: _hoursController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Hours contributed',
                              helperText: 'Example: 1.5',
                            ),
                            validator: (v) {
                              final value = double.tryParse((v ?? '').trim());
                              if (value == null || value <= 0)
                                return 'Enter a valid number of hours';
                              return null;
                            },
                          ),
                        if (_type == 'Effort')
                          TextFormField(
                            controller: _effortController,
                            minLines: 4,
                            maxLines: 8,
                            decoration: const InputDecoration(
                              labelText: 'What did you do?',
                              helperText:
                                  'Describe your contribution briefly and clearly',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Effort description is required';
                              if (v.trim().length < 10)
                                return 'Add a little more detail';
                              return null;
                            },
                          ),
                        if (_type == 'Materials')
                          TextFormField(
                            controller: _materialsController,
                            decoration: const InputDecoration(
                              labelText: 'Materials',
                              helperText:
                                  'Comma-separated, e.g. gloves, bags, water',
                            ),
                            validator: (v) {
                              final items = (v ?? '')
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();
                              if (items.isEmpty)
                                return 'Add at least one material item';
                              return null;
                            },
                          ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Notes (optional)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _photos.length >= 3 ? null : _pickPhotos,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(_photos.isEmpty
                              ? 'Add photos (up to 3)'
                              : 'Photos: ${_photos.length}/3'),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.bolt_outlined,
                                    color: colorScheme.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Estimated Impact',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$points points',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit Contribution'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

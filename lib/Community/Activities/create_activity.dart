import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../Models/user.dart';
import '../../Services/Activities/activity_service.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  String _type = 'Events';
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _requiredParticipantsController = TextEditingController(text: '10');

  DateTime? _date;
  TimeOfDay? _time;

  final _picker = ImagePicker();
  XFile? _cover;

  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _requiredParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (!mounted) return;
    setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (!mounted) return;
    setState(() => _time = picked);
  }

  Future<void> _pickCover() async {
    final file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (!mounted) return;
    setState(() => _cover = file);
  }

  Future<void> _create() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final dtDate = _date;
    final dtTime = _time;
    if (dtDate == null || dtTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date and time')));
      return;
    }

    final dateTime = DateTime(
        dtDate.year, dtDate.month, dtDate.day, dtTime.hour, dtTime.minute);

    final requiredParticipants =
        int.tryParse(_requiredParticipantsController.text.trim()) ?? 0;

    setState(() => _saving = true);

    try {
      final user = Provider.of<F_User?>(context, listen: false);
      final id = await ActivityService().createActivity(
        type: _type,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        dateTime: dateTime,
        requiredParticipants: requiredParticipants,
        createdBy: user?.uid,
        coverImage: _cover,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/activities/$id');
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Create Activity')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _type,
                          decoration:
                              const InputDecoration(labelText: 'Activity Type'),
                          items: const [
                            DropdownMenuItem(
                                value: 'Cleanups', child: Text('Cleanups')),
                            DropdownMenuItem(
                                value: 'Events', child: Text('Events')),
                            DropdownMenuItem(
                                value: 'Tasks', child: Text('Tasks')),
                          ],
                          onChanged: (v) =>
                              setState(() => _type = v ?? 'Events'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Title is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                          minLines: 4,
                          maxLines: 8,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Description is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _locationController,
                          decoration:
                              const InputDecoration(labelText: 'Location'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Location is required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickDate,
                                icon: const Icon(Icons.calendar_today_outlined),
                                label: Text(_date == null
                                    ? 'Pick Date'
                                    : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickTime,
                                icon: const Icon(Icons.access_time),
                                label: Text(_time == null
                                    ? 'Pick Time'
                                    : _time!.format(context)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _requiredParticipantsController,
                          decoration: const InputDecoration(
                              labelText: 'Required participants'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final value = int.tryParse((v ?? '').trim());
                            if (value == null || value <= 0)
                              return 'Enter a valid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _pickCover,
                          icon: const Icon(Icons.image_outlined),
                          label: Text(_cover == null
                              ? 'Upload cover image (optional)'
                              : 'Cover image selected'),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _create,
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Create Activity'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

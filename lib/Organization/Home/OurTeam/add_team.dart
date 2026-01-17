import 'package:flutter/material.dart';

class AddTeam extends StatefulWidget {
  const AddTeam({super.key});

  @override
  State<AddTeam> createState() => _AddTeamState();
}

class _AddTeamState extends State<AddTeam> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _teamNameController = TextEditingController();
  final List<TextEditingController> _rolesControllers = [
    TextEditingController(text: 'Team Lead')
  ];
  final List<Map<String, dynamic>> _teamMembers = [];

  bool showForm = false;

  void _addRole() {
    if (_rolesControllers.last.text.isNotEmpty) {
      setState(() {
        _rolesControllers.add(TextEditingController());
      });
    }
  }

  void _removeRole(int index) {
    setState(() {
      _rolesControllers.removeAt(index);
      for (var member in _teamMembers) {
        if (member['role'] == _rolesControllers[index].text) {
          member['role'] = null;
        }
      }
    });
  }

  void _addTeamMember() {
    if (_teamMembers.isEmpty || _teamMembers.last['name'].text.isNotEmpty) {
      setState(() {
        _teamMembers.add({
          'name': TextEditingController(),
          'role': null,
        });
      });
    }
  }

  void _removeTeamMember(int index) {
    setState(() {
      _teamMembers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(56.0), // Set the height of the AppBar
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurpleAccent.withAlpha(
                    (0.05 * 255).toInt()), // Shadow color with opacity
                blurRadius: 4.0, // Adjust the blur radius
                offset: Offset(0, 3), // Position of the shadow
              ),
            ],
          ),
          child: AppBar(
            backgroundColor:
                Colors.transparent, // Make the AppBar background transparent
            elevation: 0, // Remove default shadow
            title: Text(
              'Edit Teams',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton('Add New Team', () {
                    setState(() {
                      showForm = true;
                    });
                  }),

                ],
              ),
              const SizedBox(height: 10),
              if (showForm) _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Team Name', _teamNameController),
          const SizedBox(height: 15),
          _buildRolesSection(),
          _buildTeamMembersSection(),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add Team',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {VoidCallback? onRemove}) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            validator: (value) =>
                value!.isEmpty ? 'This field is required' : null,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w400),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black54)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87, width: 0.1)),
            ),
          ),
        ),
        if (onRemove != null)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onRemove,
          ),
      ],
    );
  }

  Widget _buildRolesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Roles:',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Colors.black)),
        for (int i = 0; i < _rolesControllers.length; i++)
          _buildTextField('Role', _rolesControllers[i],
              onRemove: i == 0 ? null : () => _removeRole(i)),
        TextButton(
          onPressed: _addRole,
          child: const Text('+ Add Role',
              style: TextStyle(color: Colors.teal, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildTeamMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Add Team Members',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: Colors.black)),
        for (int i = 0; i < _teamMembers.length; i++)
          Row(
            children: [
              Expanded(
                  child:
                      _buildTextField('Member Name', _teamMembers[i]['name'])),
              DropdownButton<String>(
                hint: const Text('Select Role'),
                value: _teamMembers[i]['role'],
                onChanged: (value) {
                  setState(() {
                    _teamMembers[i]['role'] = value;
                  });
                },
                items: _rolesControllers.map((controller) {
                  return DropdownMenuItem<String>(
                    value: controller.text,
                    child: Text(controller.text),
                  );
                }).toList(),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _removeTeamMember(i),
              ),
            ],
          ),
        TextButton(
          onPressed: _addTeamMember,
          child: const Text('+ Add Member',
              style: TextStyle(color: Colors.teal, fontSize: 16)),
        ),
      ],
    );
  }
}

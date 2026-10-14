import 'package:flutter/material.dart';
import '../../models/campus_event.dart';
import '../../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.events,
    required this.onProfileChanged,
    required this.onThemeChanged,
  });

  final Profile profile;
  final List<CampusEvent> events;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.profile.name,
    );
    _groupController = TextEditingController(
      text: widget.profile.group,
    );
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.profile.name != widget.profile.name &&
        _nameController.text != widget.profile.name) {
      _nameController.text = widget.profile.name;
    }

    if (oldWidget.profile.group != widget.profile.group &&
        _groupController.text != widget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onProfileChanged(
      Profile(
        name: _nameController.text.trim(),
        group: _groupController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name.trim();

    final joined = widget.events.where((event) => event.contains(name)).length;

    final currentMode = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 38,
              child: Text(
                name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Your name',
            ),
            onFieldSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _groupController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Group (e.g. IS-2301)',
            ),
            validator: (value) {
              return value != null &&
                      RegExp(r'^[A-Za-z]{1,5}-\d{2,4}$').hasMatch(value)
                  ? null
                  : 'Use a format like IS-2301';
            },
            onFieldSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _save,
            child: const Text('Save profile'),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_available),
              title: Text('You are on $joined lists'),
              subtitle: const Text(
                'Calculated from current event attendees',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('System'),
                selected: false,
                onSelected: (_) {
                  widget.onThemeChanged(ThemeMode.system);
                },
              ),
              ChoiceChip(
                label: const Text('Light'),
                selected: currentMode == Brightness.light,
                onSelected: (_) {
                  widget.onThemeChanged(ThemeMode.light);
                },
              ),
              ChoiceChip(
                label: const Text('Dark'),
                selected: currentMode == Brightness.dark,
                onSelected: (_) {
                  widget.onThemeChanged(ThemeMode.dark);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

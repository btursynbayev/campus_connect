import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/campus_event.dart';
import '../../models/event_category.dart';
import '../../utils/format.dart';

class CampusEventResult {
  const CampusEventResult(this.event);

  final CampusEvent event;
}

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({
    super.key,
    required this.args,
  });

  final FormArgs args;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _capacityController;

  late final FocusNode _titleFocus;
  late final FocusNode _locationFocus;
  late final FocusNode _capacityFocus;
  late final FocusNode _descriptionFocus;

  late EventCategory _category;
  late bool _isOnline;

  DateTime? _date;
  TimeOfDay? _time;

  bool _saving = false;
  late final String _initialSnapshot;

  CampusEvent? get _original => widget.args.event;

  @override
  void initState() {
    super.initState();

    final event = _original ?? CampusEvent.empty();

    _titleController = TextEditingController(text: event.title);
    _locationController = TextEditingController(text: event.location);
    _descriptionController =
        TextEditingController(text: event.description ?? '');
    _capacityController =
        TextEditingController(text: event.capacity.toString());

    _titleFocus = FocusNode();
    _locationFocus = FocusNode();
    _capacityFocus = FocusNode();
    _descriptionFocus = FocusNode();

    _category = event.category;
    _isOnline = event.isOnline;

    _date = _original?.startsAt;
    _time = _original == null ? null : TimeOfDay.fromDateTime(event.startsAt);

    _initialSnapshot = _snapshot;
  }

  String get _snapshot => [
        _titleController.text,
        _category.name,
        _locationController.text,
        _descriptionController.text,
        _capacityController.text,
        _isOnline.toString(),
        _date?.toIso8601String() ?? '',
        _time == null ? '' : '${_time!.hour}:${_time!.minute}',
      ].join('|');

  bool get _dirty => _snapshot != _initialSnapshot;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();

    _titleFocus.dispose();
    _locationFocus.dispose();
    _capacityFocus.dispose();
    _descriptionFocus.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _date ??
          today.add(
            const Duration(days: 1),
          ),
      firstDate: DateTime(today.year - 1),
      lastDate: DateTime(today.year + 5),
    );

    if (!mounted || picked == null) return;

    setState(() {
      _date = picked;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 12, minute: 0),
    );

    if (!mounted || picked == null) return;

    setState(() {
      _time = picked;
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty || _saving) {
      return !_saving;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'Your changes have not been saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _save() async {
    final form = _formKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose both a date and a time.'),
        ),
      );
      return;
    }

    final startsAt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );

    if (_original == null && !startsAt.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Choose a future date and time.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    await Future<void>.delayed(
      const Duration(seconds: 1),
    );

    if (!mounted) return;

    final event = CampusEvent(
      id: _original?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _category,
      startsAt: startsAt,
      capacity: int.parse(_capacityController.text),
      attendees: _original?.attendees ?? const [],
      isOnline: _isOnline,
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      isFavourite: _original?.isFavourite ?? false,
    );

    Navigator.pop(context, CampusEventResult(event));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _saving) return;

        final discard = await _confirmDiscard();

        if (discard && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _original == null ? 'Create event' : 'Edit event',
          ),
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _titleController,
                focusNode: _titleFocus,
                maxLength: 60,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Event title',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';

                  if (text.length < 3 || text.length > 60) {
                    return 'Enter 3–60 characters.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                items: EventCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _category = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Choose a category.' : null,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online event'),
                subtitle: const Text(
                  'When enabled, location must be a URL.',
                ),
                value: _isOnline,
                onChanged: (value) {
                  setState(() {
                    _isOnline = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                focusNode: _locationFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  labelText: _isOnline ? 'Meeting URL' : 'Place',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';

                  if (text.isEmpty) {
                    return 'This field is required.';
                  }

                  if (_isOnline && !text.contains('://')) {
                    return 'Enter a URL containing ://.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                focusNode: _capacityFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                ),
                validator: (value) {
                  final number = int.tryParse(value ?? '');

                  if (number == null || number < 1 || number > 500) {
                    return 'Enter a number from 1 to 500.';
                  }

                  if (_original != null && number < widget.args.currentCount) {
                    return 'Cannot be below current attendees.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  _date == null ? 'Choose date' : formatDateTime(_date!),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule),
                label: Text(
                  _time == null ? 'Choose time' : _time!.format(context),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

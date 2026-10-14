import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/campus_event.dart';
import '../../models/countdown.dart';
import '../../utils/format.dart';
import '../form/event_form_screen.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.args,
  });

  final DetailArgs args;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late CampusEvent _event;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _event = widget.args.event;

    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _currentProfileName => widget.args.profileName;

  Future<void> _toggleAttendance() async {
    final name = _currentProfileName.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Add your name in Profile first.',
          ),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              widget.args.onSwitchTab(2);
              Navigator.pop(context);
            },
          ),
        ),
      );
      return;
    }

    final alreadyJoined = _event.contains(name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          alreadyJoined ? 'Leave event?' : 'Register for event?',
        ),
        content: Text(
          alreadyJoined
              ? 'Your name will be removed from the attendee list.'
              : 'Register for "${_event.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              alreadyJoined ? 'Leave' : 'Register',
            ),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final names = [..._event.attendees];

    if (alreadyJoined) {
      names.removeWhere(
        (person) => person.toLowerCase() == name.toLowerCase(),
      );
    } else if (!_event.isFull) {
      names.add(name);
    }

    setState(() {
      _event = _event.copyWith(attendees: names);
    });

    widget.args.onChanged(_event);
  }

  Future<void> _edit() async {
    final result = await Navigator.pushNamed<CampusEventResult>(
      context,
      Routes.form,
      arguments: FormArgs(
        event: _event,
        currentCount: _event.count,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _event = result.event;
    });

    widget.args.onChanged(_event);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text(
          'This event will be removed from the list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    widget.args.onDelete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final countdown = countdownFor(_event.startsAt);

    final countdownText = switch (countdown) {
      Upcoming(:final remaining) => formatRemaining(remaining),
      Started(:final elapsed) => 'Started ${elapsed.inMinutes} min ago',
      Ended() => 'Event ended',
    };

    final isJoined = _event.contains(_currentProfileName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _edit();
              }

              if (value == 'delete') {
                _delete();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary,
                        scheme.tertiary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _event.category.icon,
                      size: 72,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Chip(
                    label: Text(_event.category.label),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: Chip(
                    label: Text(countdownText),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                16,
                18,
                12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _event.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_event.location),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_event.count}/${_event.capacity} participants',
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _event.isFull && !isJoined
                            ? null
                            : _toggleAttendance,
                        icon: Icon(
                          isJoined ? Icons.logout : Icons.how_to_reg,
                        ),
                        label: Text(
                          isJoined ? 'Leave' : 'Register',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Attendees (${_event.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_month),
                        title: Text(
                          formatDateTime(_event.startsAt),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(_event.location),
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.event_seat),
                        title: Text(
                          '${_event.places.taken} taken · '
                          '${_event.places.free} free',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_event.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_event.description!),
                        ),
                    ],
                  ),
                  ListView.builder(
                    itemCount: _event.attendees.length,
                    itemBuilder: (context, index) {
                      final person = _event.attendees[index];
                      final isYou = person.toLowerCase() ==
                          _currentProfileName.toLowerCase();

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            person.isEmpty ? '?' : person[0].toUpperCase(),
                          ),
                        ),
                        title: Text(
                          person,
                          style: TextStyle(
                            fontWeight:
                                isYou ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isYou ? const Chip(label: Text('You')) : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

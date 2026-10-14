import 'package:flutter/material.dart';
import '../data/seed_events.dart';
import '../models/campus_event.dart';
import '../models/profile.dart';
import '../screens/events/events_tab.dart';
import '../screens/favourites/favourites_tab.dart';
import '../screens/profile/profile_tab.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.onThemeChanged,
  });

  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late List<CampusEvent> _events;
  Profile _profile = const Profile.empty();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _events = buildSeedEvents();
  }

  void _replaceEvent(CampusEvent updated) {
    setState(() {
      final index = _events.indexWhere(
        (event) => event.id == updated.id,
      );

      if (index >= 0) {
        _events[index] = updated;
      }
    });
  }

  void _addEvent(CampusEvent event) {
    setState(() {
      _events = [..._events, event];
    });
  }

  void _deleteEvent(String id) {
    setState(() {
      _events = _events.where((event) => event.id != id).toList();
    });
  }

  void _resetData() {
    setState(() {
      _events = buildSeedEvents();
      _profile = const Profile.empty();
      _selectedIndex = 0;
    });
  }

  void _openDrawerAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About Campus Connect'),
        content: const Text(
          'A student events app built for Mobile Development Lab 1. '
          'All data is stored in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'All changes and profile details will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (!context.mounted || confirmed != true) {
      return;
    }

    _resetData();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      EventsTab(
        events: _events,
        profile: _profile,
        onChanged: _replaceEvent,
        onCreate: _addEvent,
        onSwitchTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        onDelete: _deleteEvent,
      ),
      FavouritesTab(
        events: _events.where((event) => event.isFavourite).toList(),
        profile: _profile,
        onChanged: _replaceEvent,
        onSwitchTab: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        onDelete: _deleteEvent,
      ),
      ProfileTab(
        profile: _profile,
        events: _events,
        onProfileChanged: (profile) {
          setState(() {
            _profile = profile;
          });
        },
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.school),
                title: Text('Campus Connect'),
                subtitle: Text('Student community'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _openDrawerAbout(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmReset(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

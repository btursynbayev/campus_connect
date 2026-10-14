import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/campus_event.dart';
import '../../models/event_category.dart';
import '../../models/profile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/event_card.dart';
import '../form/event_form_screen.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({
    super.key,
    required this.events,
    required this.profile,
    required this.onChanged,
    required this.onCreate,
    required this.onSwitchTab,
    required this.onDelete,
  });

  final List<CampusEvent> events;
  final Profile profile;
  final ValueChanged<CampusEvent> onChanged;
  final ValueChanged<CampusEvent> onCreate;
  final ValueChanged<int> onSwitchTab;
  final ValueChanged<String> onDelete;

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final TextEditingController _searchController = TextEditingController();

  EventCategory? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm() async {
    final result = await Navigator.pushNamed<CampusEventResult>(
      context,
      Routes.form,
      arguments: const FormArgs(
        event: null,
        currentCount: 0,
      ),
    );

    if (!mounted || result == null) return;

    widget.onCreate(result.event);
  }

  Future<void> _openDetail(CampusEvent event) async {
    await Navigator.pushNamed<void>(
      context,
      Routes.detail,
      arguments: DetailArgs(
        event: event,
        onChanged: widget.onChanged,
        onDelete: () => widget.onDelete(event.id),
        onSwitchTab: widget.onSwitchTab,
        profileName: widget.profile.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final visible = widget.events.where((event) {
      final matchesText = event.title.toLowerCase().contains(query);

      final matchesCategory = _category == null || event.category == _category;

      final matchesPast = _showPast || !event.isPast;

      return matchesText && matchesCategory && matchesPast;
    }).toList()
      ..sort((a, b) {
        if (a.isPast != b.isPast) {
          return a.isPast ? 1 : -1;
        }
        return a.startsAt.compareTo(b.startsAt);
      });

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Campus Connect'),
        actions: [
          IconButton(
            tooltip: 'Favourites',
            onPressed: () => widget.onSwitchTab(1),
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Create event'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search events',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _category == null,
                    onSelected: (_) {
                      setState(() => _category = null);
                    },
                  ),
                ),
                ...EventCategory.values.map(
                  (category) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      avatar: Icon(category.icon, size: 17),
                      label: Text(category.label),
                      selected: _category == category,
                      onSelected: (_) {
                        setState(() => _category = category);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: const Text('Past events'),
                selected: _showPast,
                onSelected: (value) {
                  setState(() => _showPast = value);
                },
              ),
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    message: 'No events match your filters.',
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 600) {
                        final count =
                            (constraints.maxWidth / 360).floor().clamp(1, 4);

                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            4,
                            16,
                            100,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: count,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 4,
                            mainAxisExtent: 150,
                          ),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final event = visible[index];
                            return EventCard(
                              event: event,
                              onTap: () => _openDetail(event),
                              onFavourite: () {
                                widget.onChanged(
                                  event.copyWith(
                                    isFavourite: !event.isFavourite,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
                          100,
                        ),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final event = visible[index];
                          return EventCard(
                            event: event,
                            onTap: () => _openDetail(event),
                            onFavourite: () {
                              widget.onChanged(
                                event.copyWith(
                                  isFavourite: !event.isFavourite,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

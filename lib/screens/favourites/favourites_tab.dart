import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/campus_event.dart';
import '../../models/profile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/event_card.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.events,
    required this.profile,
    required this.onChanged,
    required this.onSwitchTab,
    required this.onDelete,
  });

  final List<CampusEvent> events;
  final Profile profile;
  final ValueChanged<CampusEvent> onChanged;
  final ValueChanged<int> onSwitchTab;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
      ),
      body: events.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              message: 'No favourites yet. Add events using the heart button.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final event = events[index];

                return EventCard(
                  event: event,
                  onTap: () {
                    Navigator.pushNamed<void>(
                      context,
                      Routes.detail,
                      arguments: DetailArgs(
                        event: event,
                        onChanged: onChanged,
                        onDelete: () => onDelete(event.id),
                        onSwitchTab: onSwitchTab,
                        profileName: profile.name,
                      ),
                    );
                  },
                  onFavourite: () {
                    onChanged(
                      event.copyWith(isFavourite: false),
                    );
                  },
                );
              },
            ),
    );
  }
}

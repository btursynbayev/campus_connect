import 'package:flutter/foundation.dart';
import 'event_category.dart';

@immutable
class CampusEvent {
  CampusEvent({
    required this.title,
    required this.category,
    required this.startsAt,
    required this.capacity,
    required List<String> attendees,
    required this.isOnline,
    required this.location,
    this.description,
    this.isFavourite = false,
    this.id = '',
  }) : attendees = List<String>.unmodifiable(attendees);

  CampusEvent.empty()
      : title = '',
        category = EventCategory.tech,
        startsAt = DateTime.now().add(
          const Duration(days: 1),
        ),
        capacity = 20,
        attendees = List<String>.unmodifiable(
          const <String>[],
        ),
        isOnline = false,
        location = '',
        description = null,
        isFavourite = false,
        id = '';

  final String id;
  final String title;
  final EventCategory category;
  final DateTime startsAt;
  final int capacity;
  final List<String> attendees;
  final bool isOnline;
  final String location;
  final String? description;
  final bool isFavourite;

  int get count => attendees.length;

  int get freePlaces => (capacity - count).clamp(0, capacity);

  bool get isFull => count >= capacity;

  bool get isPast => startsAt.isBefore(DateTime.now());

  bool contains(String name) =>
      name.trim().isNotEmpty &&
      attendees.any(
        (person) => person.toLowerCase() == name.trim().toLowerCase(),
      );

  ({int taken, int free}) get places => (
        taken: count,
        free: freePlaces,
      );

  CampusEvent copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? startsAt,
    int? capacity,
    List<String>? attendees,
    bool? isOnline,
    String? location,
    String? description,
    bool clearDescription = false,
    bool? isFavourite,
  }) =>
      CampusEvent(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        startsAt: startsAt ?? this.startsAt,
        capacity: capacity ?? this.capacity,
        attendees: attendees ?? this.attendees,
        isOnline: isOnline ?? this.isOnline,
        location: location ?? this.location,
        description:
            clearDescription ? null : (description ?? this.description),
        isFavourite: isFavourite ?? this.isFavourite,
      );
}


import 'package:flutter/material.dart';

enum EventCategory {
  tech('Technology', Icons.computer),
  sport('Sport', Icons.sports_basketball),
  business('Business', Icons.business_center),
  culture('Culture', Icons.palette),
  education('Education', Icons.school);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
        EventCategory.tech => scheme.primary,
        EventCategory.sport => scheme.tertiary,
        EventCategory.business => scheme.secondary,
        EventCategory.culture => scheme.error,
        EventCategory.education => scheme.onSurfaceVariant,
      };
}

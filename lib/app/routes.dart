import 'package:flutter/material.dart';
import '../models/campus_event.dart';

class Routes {
  static const home = '/';
  static const detail = '/event-detail';
  static const form = '/event-form';
}

class DetailArgs {
  const DetailArgs({
    required this.event,
    required this.onChanged,
    required this.onDelete,
    required this.onSwitchTab,
    required this.profileName,
  });

  final CampusEvent event;
  final ValueChanged<CampusEvent> onChanged;
  final VoidCallback onDelete;
  final ValueChanged<int> onSwitchTab;
  final String profileName;
}

class FormArgs {
  const FormArgs({
    this.event,
    required this.currentCount,
  });

  final CampusEvent? event;
  final int currentCount;
}

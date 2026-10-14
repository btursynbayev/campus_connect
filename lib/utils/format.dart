String formatDateTime(DateTime dateTime) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');

  return '$day ${months[dateTime.month - 1]}, $hour:$minute';
}

String formatRemaining(Duration duration) {
  if (duration.inDays >= 1) {
    return '${duration.inDays}d ${duration.inHours % 24}h left';
  }

  if (duration.inHours >= 1) {
    return '${duration.inHours}h ${duration.inMinutes % 60}m left';
  }

  return '${duration.inMinutes.abs()}m left';
}


sealed class Countdown {
  const Countdown();
}

final class Upcoming extends Countdown {
  const Upcoming(this.remaining);

  final Duration remaining;
}

final class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}

Countdown countdownFor(
  DateTime startsAt, {
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  final difference = startsAt.difference(current);

  if (difference.inSeconds > 0) {
    return Upcoming(difference);
  }

  if (difference.inMinutes > -60) {
    return Started(current.difference(startsAt));
  }

  return const Ended();
}

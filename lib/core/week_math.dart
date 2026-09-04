int weekFromLmp(DateTime lmp, [DateTime? now]) {
  final days = (now ?? DateTime.now()).difference(lmp).inDays;
  final week = (days / 7).floor() + 1;
  return week.clamp(1, 40);
}

DateTime dueFromLmp(DateTime lmp) => lmp.add(const Duration(days: 280));

DateTime lmpFromDue(DateTime due) => due.subtract(const Duration(days: 280));

int daysUntilDue(DateTime due, [DateTime? now]) {
  return due.difference(now ?? DateTime.now()).inDays;
}

int weekFromDue(DateTime due, [DateTime? now]) {
  return weekFromLmp(lmpFromDue(due), now);
}

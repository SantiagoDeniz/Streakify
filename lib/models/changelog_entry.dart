/// Changelog entry model
class ChangelogEntry {
  final String version;
  final DateTime date;
  final List<String> features;
  final List<String> improvements;
  final List<String> bugFixes;

  const ChangelogEntry({
    required this.version,
    required this.date,
    this.features = const [],
    this.improvements = const [],
    this.bugFixes = const [],
  });

  bool get hasChanges => features.isNotEmpty || improvements.isNotEmpty || bugFixes.isNotEmpty;
}

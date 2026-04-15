class SearchResult {
  const SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.sortDate,
  });

  final String type;
  final String title;
  final String subtitle;
  final String route;
  final DateTime sortDate;
}

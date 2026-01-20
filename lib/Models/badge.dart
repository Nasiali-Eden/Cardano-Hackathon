class Badge {
  final String id;
  final String title;
  final String description;
  final bool earned;
  final int? requiredPoints;
  final int? requiredContributions;

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.earned,
    this.requiredPoints,
    this.requiredContributions,
  });
}

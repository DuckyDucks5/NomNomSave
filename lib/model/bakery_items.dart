class BakeryItem {
  final String name;
  final String addedBy;
  final DateTime expirationDate;

  BakeryItem({
    required this.name,
    required this.addedBy,
    required this.expirationDate,
  });

  int get daysLeft => expirationDate.difference(DateTime.now()).inDays;
}

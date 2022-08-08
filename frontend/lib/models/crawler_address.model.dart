class CrawlerAddress {
  final String address;
  final int archivesSum;

  const CrawlerAddress({
    required this.address,
    required this.archivesSum,
  });

  @override
  String toString() {
    return "CrawlerAddress - address: $address archivesSum: $archivesSum";
  }
}

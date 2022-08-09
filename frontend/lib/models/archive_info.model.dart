import 'package:intl/intl.dart';

class ArchiveInfo {
  final int id;
  final int crawlerId;
  final String address;
  final String fileLocation;
  final DateTime creationTimestamp;

  const ArchiveInfo({
    required this.id,
    required this.crawlerId,
    required this.address,
    required this.fileLocation,
    required this.creationTimestamp,
  });

  factory ArchiveInfo.fromJson(Map<String, dynamic> json) {
    return ArchiveInfo(
      id: json['archive'][0],
      crawlerId: json['archive'][1],
      address: json['archive'][2],
      fileLocation: json['archive'][3],
      creationTimestamp: DateFormat('E, d MMM yyyy HH:mm:ss Z', 'en_US')
          .parse(json['archive'][4]),
    );
  }

  @override
  String toString() {
    return "ArchiveInfo - address: $address creationTimestamp: $creationTimestamp";
  }
}

import 'package:frontend/models/crawler_address.model.dart';

class AllAddressesResponse {
  final bool success;
  final List<CrawlerAddress> addresses;

  const AllAddressesResponse({
    required this.success,
    required this.addresses,
  });

  factory AllAddressesResponse.fromJson(Map<String, dynamic> json) {
    List addressesList = json['addresses'];
    List<CrawlerAddress> temp = [];

    if (addressesList.isEmpty) {
      return AllAddressesResponse(
        success: json['success'],
        addresses: [],
      );
    } else {
      for (var address in addressesList) {
        temp.add(CrawlerAddress(address: address[0], archivesSum: address[1]));
      }
      return AllAddressesResponse(
        success: json['success'],
        addresses: temp,
      );
    }
  }

  @override
  String toString() {
    return "AllAddressesResponse - success: $success, addresses length: ${addresses.length.toString()}";
  }
}

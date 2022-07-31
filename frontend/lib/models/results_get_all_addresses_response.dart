class AllAddressesResponse {
  final bool success;
  final List<String> addresses;

  const AllAddressesResponse({
    required this.success,
    required this.addresses,
  });

  factory AllAddressesResponse.fromJson(Map<String, dynamic> json) {
    List addressesList = json['addresses'];
    List<String> temp = [];

    if (addressesList.isEmpty) {
      return AllAddressesResponse(
        success: json['success'],
        addresses: [],
      );
    } else {
      for (var address in addressesList) {
        temp.add(address[0]);
      }
      return AllAddressesResponse(
        success: json['success'],
        addresses: temp,
      );
    }
  }

  @override
  String toString() {
    return "AllAddressesResponse - success: $success, addresses: ${addresses.toString()}";
  }
}

class EarliestDateResponse {
  final bool success;
  final DateTime date;

  const EarliestDateResponse({
    required this.success,
    required this.date,
  });

  factory EarliestDateResponse.fromJson(Map<String, dynamic> json) {
    return EarliestDateResponse(
      success: json['success'],
      date: json['date'],
    );
  }

  @override
  String toString() {
    return "EarliestDateResponse - success: $success, date: $date";
  }
}

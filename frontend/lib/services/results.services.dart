import 'dart:convert';

import 'package:frontend/constants/services.constants.dart';
import 'package:frontend/models/results_earliest_date_response.model.dart';
import 'package:frontend/models/results_get_all_addresses_response.dart';
import 'package:http/http.dart' as http;

class ResultsApiService {
  static Future<AllAddressesResponse> getAllAddresses() async {
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final response = await http.get(
      Uri.parse(backendAddress + backendResultsGetAllAddresses),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return AllAddressesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get all archive addresses');
    }
  }

  static Future<EarliestDateResponse> getEarliestDate(
    String rootAddress,
  ) async {
    final queryParameters = {
      'root_address': rootAddress,
    };
    final jsonString = json.encode(queryParameters);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final response = await http.post(
      Uri.parse(backendAddress + backendResultsGetEarliestDateEndpoint),
      headers: headers,
      body: jsonString,
    );

    if (response.statusCode == 200) {
      return EarliestDateResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get earliest archive date');
    }
  }

  static Future<EarliestDateResponse> getGeneratedFile(
    String rootAddress,
  ) async {
    final queryParameters = {
      'root_address': rootAddress,
    };
    final jsonString = json.encode(queryParameters);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final response = await http.post(
      Uri.parse(backendAddress + backendResultsGetEarliestDateEndpoint),
      headers: headers,
      body: jsonString,
    );

    if (response.statusCode == 200) {
      return EarliestDateResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get earliest archive date');
    }
  }
}

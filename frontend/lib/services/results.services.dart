import 'dart:convert';

import 'package:frontend/constants/services.constants.dart';
import 'package:frontend/models/archive_info.model.dart';
import 'package:frontend/models/results_get_all_addresses_response.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

  static Future<ArchiveInfo> getEarliestDate(
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
      Uri.parse(backendAddress + backendResultsGetEarliestArchiveEndpoint),
      headers: headers,
      body: jsonString,
    );

    if (response.statusCode == 200) {
      return ArchiveInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get earliest archive date');
    }
  }

  static Future<ArchiveInfo> getLatestDate(
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
      Uri.parse(backendAddress + backendResultsGetLatestArchiveEndpoint),
      headers: headers,
      body: jsonString,
    );
    if (response.statusCode == 200) {
      return ArchiveInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get latest archive date');
    }
  }

  static Future<List<ArchiveInfo>> getAllDates(
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
      Uri.parse(backendAddress + backendResultsGetAllArchivesEndpoint),
      headers: headers,
      body: jsonString,
    );
    if (response.statusCode == 200) {
      List<ArchiveInfo> tempArray = [];
      for (var archive in jsonDecode(response.body)['archives']) {
        tempArray.add(
          ArchiveInfo(
            id: archive[0],
            crawlerId: archive[1],
            address: archive[2],
            fileLocation: archive[3],
            creationTimestamp: DateFormat('E, d MMM yyyy HH:mm:ss Z', 'en_US')
                .parse(archive[4]),
          ),
        );
      }
      return tempArray;
    } else {
      throw Exception('Failed to get all archive dates');
    }
  }

  static Future<ArchiveInfo> getGeneratedFile(
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
      Uri.parse(backendAddress + backendResultsGetEarliestArchiveEndpoint),
      headers: headers,
      body: jsonString,
    );

    if (response.statusCode == 200) {
      return ArchiveInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get earliest archive date');
    }
  }
}

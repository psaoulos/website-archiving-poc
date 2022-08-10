import 'package:flutter/material.dart';
import 'package:frontend/models/archive_info.model.dart';
import 'package:frontend/models/crawler_address.model.dart';
import 'package:frontend/services/results.services.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:frontend/extenstions/datetime.extenstion.dart';

class ResultsProvider with ChangeNotifier {
  CrawlerAddress selectedAddress =
      const CrawlerAddress(address: "", archivesSum: 0);
  DateTime selectedStartDate = DateTime(2020, 1, 1);
  DateTime selectedEndDate = DateTime(2020, 1, 1);
  DateTime earliestArchiveDate = DateTime(2020, 1, 1);
  DateTime latestArchiveDate = DateTime(2020, 2, 1);
  List<DateTime> distinctArchiveDates = [];
  List<ArchiveInfo> allTheArchives = [];
  List<ArchiveInfo> sortedArchives = [];
  ArchiveInfo? firstArchiveSelected;
  ArchiveInfo? secondArchiveSelected;

  ResultsProvider();

  void selectAddress(CrawlerAddress address) async {
    selectedAddress = address;
    notifyListeners();
    getDataForAddress();
  }

  void getDataForAddress() {
    ResultsApiService.getEarliestDate(selectedAddress.address)
        .then((getEarliestDate) {
      earliestArchiveDate = getEarliestDate.creationTimestamp;
      notifyListeners();
    });
    ResultsApiService.getLatestDate(selectedAddress.address)
        .then((getLatestDate) {
      latestArchiveDate = getLatestDate.creationTimestamp;
      notifyListeners();
    });
    ResultsApiService.getAllDates(selectedAddress.address).then((value) {
      List<DateTime> tempDateList = [];
      for (var archive in value) {
        DateTime tempDate = DateTime(archive.creationTimestamp.year,
            archive.creationTimestamp.month, archive.creationTimestamp.day);
        if (!tempDateList.contains(tempDate)) {
          tempDateList.add(tempDate);
        }
      }
      allTheArchives = value;
      distinctArchiveDates = tempDateList;
      notifyListeners();
    });
  }

  void sortDataForDateRange() {
    List<ArchiveInfo> tempList = [];
    for (var archive in allTheArchives) {
      if (archive.creationTimestamp.isSameDate(selectedStartDate)) {
        tempList.add(archive);
      } else if (archive.creationTimestamp.isSameDate(selectedEndDate)) {
        tempList.add(archive);
      }
    }
    tempList.sort((a, b) {
      if (a.creationTimestamp.isBefore(b.creationTimestamp)) {
        return -1;
      }
      return 1;
    });
    sortedArchives = tempList;
    notifyListeners();
  }

  void selectDateRange(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange &&
        args.value.startDate != null &&
        args.value.endDate == null) {
      selectedStartDate = args.value.startDate;
    } else if (args.value is PickerDateRange &&
        args.value.startDate != null &&
        args.value.endDate != null) {
      selectedStartDate = args.value.startDate;
      selectedEndDate = args.value.endDate;
    }
    notifyListeners();
    sortDataForDateRange();
  }

  void selectArchives(ArchiveInfo? first, ArchiveInfo? second) {
    firstArchiveSelected = first;
    secondArchiveSelected = second;
    notifyListeners();
  }

  void selectSignleDate(DateTime date) {
    selectedStartDate = date;
    selectedEndDate = date;
    notifyListeners();
    sortDataForDateRange();
  }
}

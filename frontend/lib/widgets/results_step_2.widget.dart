import 'package:flutter/material.dart';
import 'package:frontend/models/archive_info.model.dart';
import 'package:frontend/models/crawler_address.model.dart';
import 'package:frontend/providers/results.provider.dart';
import 'package:frontend/services/results.services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:frontend/extenstions/datetime.extenstion.dart';

class ResultsStep2 extends StatefulWidget {
  int pageIndex;
  final Function nextPage;
  final Function previousPage;
  ResultsStep2({
    Key? key,
    required this.pageIndex,
    required this.nextPage,
    required this.previousPage,
  }) : super(key: key);

  @override
  State<ResultsStep2> createState() => _ResultsStep2State();
}

class _ResultsStep2State extends State<ResultsStep2> {
  DateRangePickerSelectionChangedArgs? selectedArgs;

  bool get _moreThanOneDay {
    final resultsProvider =
        Provider.of<ResultsProvider>(context, listen: false);
    if (resultsProvider.latestArchiveDate
            .difference(resultsProvider.earliestArchiveDate)
            .inDays >
        1) {
      return true;
    } else {
      return false;
    }
  }

  bool get _selectionValid {
    final resultsProvider =
        Provider.of<ResultsProvider>(context, listen: false);
    if (!_moreThanOneDay) {
      return true;
    }
    DateTime? selectedStart = selectedArgs?.value.startDate;
    DateTime? selectedEnd = selectedArgs?.value.endDate;
    if (selectedArgs == null) {
      return false;
    } else if (selectedStart == null) {
      return false;
    }
    if (selectedEnd != null) {
      if (!selectedStart.isSameDate(selectedEnd)) {
        return true;
      }
    }
    int counter = 0;
    for (var archive in resultsProvider.allTheArchives) {
      if (selectedStart.isSameDate(archive.creationTimestamp)) {
        counter += 1;
      }
    }
    if (counter > 1) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final resultsProvider = Provider.of<ResultsProvider>(context, listen: true);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final ThemeData mode = Theme.of(context);
    bool isDarkMode = mode.brightness == Brightness.dark;

    Widget _renderDatePicker() {
      return SizedBox(
        width: width * 0.85,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.pageIndex == 1)
              SfTheme(
                data: SfThemeData(
                  dateRangePickerThemeData: isDarkMode
                      ? SfDateRangePickerThemeData(
                          selectionColor: Colors.blue,
                          rangeSelectionColor: Colors.blue[300],
                          endRangeSelectionColor: Colors.blue,
                          startRangeSelectionColor: Colors.blue,
                          todayHighlightColor: Colors.blue,
                          weekNumberBackgroundColor: Colors.blue,
                          disabledDatesTextStyle: TextStyle(
                            color: Colors.grey[800],
                          ),
                          todayTextStyle: const TextStyle(
                            color: Colors.blue,
                          ),
                        )
                      : SfDateRangePickerThemeData(
                          disabledDatesTextStyle: TextStyle(
                            color: Colors.grey[300],
                          ),
                        ),
                ),
                child: SfDateRangePicker(
                  selectableDayPredicate: (DateTime val) {
                    DateTime tempDate = DateTime(val.year, val.month, val.day);
                    if (resultsProvider.distinctArchiveDates
                        .contains(tempDate)) {
                      return true;
                    }
                    return false;
                  },
                  view: DateRangePickerView.month,
                  showTodayButton: true,
                  minDate: resultsProvider.earliestArchiveDate,
                  maxDate: resultsProvider.latestArchiveDate,
                  headerHeight: 20,
                  selectionMode: DateRangePickerSelectionMode.range,
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    setState(() {
                      selectedArgs = args;
                    });
                    resultsProvider.selectDateRange(args);
                  },
                  monthViewSettings: const DateRangePickerMonthViewSettings(
                    firstDayOfWeek: 1,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    Widget _renderOnlyOneDayInfo() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            children: <TextSpan>[
              const TextSpan(text: 'All archives for '),
              TextSpan(
                text: resultsProvider.selectedAddress.address,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: ' are taken on '),
              TextSpan(
                text: DateFormat('dd-MM-yyyy')
                    .format(resultsProvider.latestArchiveDate),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: ', automatically selecting it.'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: SizedBox(
        height: height * 0.72,
        width: width * 0.95,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (resultsProvider.distinctArchiveDates.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _moreThanOneDay
                          ? _renderDatePicker()
                          : _renderOnlyOneDayInfo()
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => {widget.previousPage()},
                      child: const Text('Back'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: ElevatedButton(
                        onPressed: _selectionValid
                            ? () {
                                if (!_moreThanOneDay) {
                                  resultsProvider.selectSignleDate(
                                      resultsProvider.latestArchiveDate);
                                }
                                widget.nextPage();
                              }
                            : null,
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

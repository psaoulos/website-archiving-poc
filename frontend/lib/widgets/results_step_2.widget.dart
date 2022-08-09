import 'package:flutter/material.dart';
import 'package:frontend/models/archive_info.model.dart';
import 'package:frontend/models/crawler_address.model.dart';
import 'package:frontend/services/results.services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class ResultsStep2 extends StatefulWidget {
  double width;
  double height;
  CrawlerAddress selectedAddress;
  final Function onDateSelectionChanged;
  final Function selectSignleDate;
  Function nextPage;
  Function previousPage;
  ResultsStep2({
    Key? key,
    required this.width,
    required this.height,
    required this.selectedAddress,
    required this.onDateSelectionChanged,
    required this.selectSignleDate,
    required this.nextPage,
    required this.previousPage,
  }) : super(key: key);

  @override
  State<ResultsStep2> createState() => _ResultsStep2State();
}

class _ResultsStep2State extends State<ResultsStep2> {
  DateTime earliestDate = DateTime(2020, 1, 1);
  DateTime latestDate = DateTime(2020, 2, 1);
  List<ArchiveInfo> allTheArchives = [];
  DateRangePickerSelectionChangedArgs? selectedArgs;

  @override
  void didUpdateWidget(covariant ResultsStep2 oldWidget) {
    if (oldWidget.selectedAddress.address != widget.selectedAddress.address) {
      ResultsApiService.getEarliestDate(widget.selectedAddress.address)
          .then((getEarliestDate) {
        setState(() {
          earliestDate = getEarliestDate.creationTimestamp;
        });
      });
      ResultsApiService.getLatestDate(widget.selectedAddress.address)
          .then((getLatestDate) {
        setState(() {
          latestDate = getLatestDate.creationTimestamp;
        });
      });
      ResultsApiService.getAllDates(widget.selectedAddress.address)
          .then((value) {
        setState(() {
          allTheArchives = value;
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData mode = Theme.of(context);
    bool isDarkMode = mode.brightness == Brightness.dark;
    bool moreThanOneDay = false;
    if (latestDate.difference(earliestDate).inDays > 1) {
      moreThanOneDay = true;
    }

    Widget _renderDatePicker() {
      return SizedBox(
        width: widget.width * 0.9,
        child: SfTheme(
          data: SfThemeData(
            dateRangePickerThemeData: isDarkMode
                ? SfDateRangePickerThemeData(
                    selectionColor: Colors.blue,
                    rangeSelectionColor: Colors.blue[300],
                    endRangeSelectionColor: Colors.blue,
                    startRangeSelectionColor: Colors.blue,
                    todayHighlightColor: Colors.blue,
                    weekNumberBackgroundColor: Colors.blue,
                    todayTextStyle: const TextStyle(
                      color: Colors.blue,
                    ),
                  )
                : null,
          ),
          child: SfDateRangePicker(
            selectableDayPredicate: (DateTime val) =>
                val.weekday == 5 || val.weekday == 6 ? false : true,
            view: DateRangePickerView.month,
            showTodayButton: true,
            minDate: earliestDate,
            maxDate: latestDate,
            headerHeight: 20,
            selectionMode: DateRangePickerSelectionMode.range,
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              setState(() {
                selectedArgs = args;
              });
              widget.onDateSelectionChanged(args);
            },
            monthViewSettings: const DateRangePickerMonthViewSettings(
              firstDayOfWeek: 1,
            ),
          ),
        ),
      );
    }

    Widget _renderOnlyOneDayInfo() {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              const TextSpan(text: 'All archives for '),
              TextSpan(
                text: widget.selectedAddress.address,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: ' are taken on '),
              TextSpan(
                text: DateFormat('dd-MM-yyyy').format(latestDate),
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
        width: widget.width,
        height: widget.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    moreThanOneDay
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
                      padding: const EdgeInsets.only(left: 10),
                      child: ElevatedButton(
                        onPressed: selectedArgs != null &&
                                selectedArgs?.value.startDate != null
                            ? () => {widget.nextPage()}
                            : moreThanOneDay
                                ? null
                                : () {
                                    widget.selectSignleDate(latestDate);
                                    widget.nextPage();
                                  },
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

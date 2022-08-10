import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/results.provider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/archive_info.model.dart';
import 'package:provider/provider.dart';

class ResultsStep3 extends StatefulWidget {
  int pageIndex;
  Function nextPage;
  Function previousPage;
  ResultsStep3({
    Key? key,
    required this.pageIndex,
    required this.nextPage,
    required this.previousPage,
  }) : super(key: key);

  @override
  State<ResultsStep3> createState() => _ResultsStep3State();
}

class _ResultsStep3State extends State<ResultsStep3> {
  ArchiveInfo? firstArchiveSelected;
  ArchiveInfo? secondArchiveSelected;

  void _onTapHandle(ArchiveInfo clickedArchive) {
    if (firstArchiveSelected == null) {
      setState(() {
        firstArchiveSelected = clickedArchive;
      });
    } else if (secondArchiveSelected == null) {
      if (firstArchiveSelected != clickedArchive) {
        setState(() {
          secondArchiveSelected = clickedArchive;
        });
      }
    } else {
      setState(() {
        firstArchiveSelected = clickedArchive;
        secondArchiveSelected = null;
      });
    }
  }

  Color? _getTileColor(bool isDarkMode, ArchiveInfo archive) {
    if (isDarkMode) {
      if (archive.id == firstArchiveSelected?.id ||
          archive.id == secondArchiveSelected?.id) {
        return Colors.grey[800];
      } else {
        return null;
      }
    } else {
      if (archive.id == firstArchiveSelected?.id ||
          archive.id == secondArchiveSelected?.id) {
        return Colors.grey[200];
      } else {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultsProvider = Provider.of<ResultsProvider>(context, listen: true);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final ThemeData mode = Theme.of(context);
    bool isDarkMode = mode.brightness == Brightness.dark;

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (resultsProvider.sortedArchives.isNotEmpty)
            SizedBox(
              height: height * 0.72,
              width: width * 0.95,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: widget.pageIndex == 2
                    ? Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: resultsProvider.sortedArchives.length
                                      .toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ' archives found for '),
                                TextSpan(
                                  text: resultsProvider.selectedAddress.address,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ' for range given.'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: resultsProvider.sortedArchives.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      tileColor: _getTileColor(
                                          isDarkMode,
                                          resultsProvider
                                              .sortedArchives[index]),
                                      leading: OutlinedButton(
                                        onPressed: () {
                                          _onTapHandle(resultsProvider
                                              .sortedArchives[index]);
                                        },
                                        child: const Text('Select'),
                                      ),
                                      title: Text(
                                        DateFormat('yyyy-MM-dd – kk:mm:ss')
                                            .format(
                                          resultsProvider.sortedArchives[index]
                                              .creationTimestamp,
                                        ),
                                      ),
                                      onTap: () {
                                        _onTapHandle(resultsProvider
                                            .sortedArchives[index]);
                                      },
                                      trailing: Text(
                                        resultsProvider
                                            .sortedArchives[index].fileLocation,
                                        style: const TextStyle(
                                          fontSize: 10.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    if (index !=
                                        resultsProvider.sortedArchives.length -
                                            1)
                                      const Divider(),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Column(),
              ),
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
                  onPressed: firstArchiveSelected != null &&
                          secondArchiveSelected != null
                      ? () {
                          resultsProvider.selectArchives(
                              firstArchiveSelected, secondArchiveSelected);
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
    );
  }
}

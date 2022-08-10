import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/results.provider.dart';
import 'package:frontend/widgets/htmlWebView/html_web_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ResultsStep4 extends StatefulWidget {
  int pageIndex;
  Function previousPage;
  ResultsStep4({
    Key? key,
    required this.pageIndex,
    required this.previousPage,
  }) : super(key: key);

  @override
  State<ResultsStep4> createState() => _ResultsStep4State();
}

class _ResultsStep4State extends State<ResultsStep4> {
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
              child: widget.pageIndex == 3
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              children: <TextSpan>[
                                const TextSpan(text: 'Differences between ('),
                                TextSpan(
                                  text: DateFormat('yyyy-MM-dd – kk:mm:ss')
                                      .format(
                                    resultsProvider.firstArchiveSelected
                                        ?.creationTimestamp as DateTime,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ') and ('),
                                TextSpan(
                                  text: DateFormat('yyyy-MM-dd – kk:mm:ss')
                                      .format(
                                    resultsProvider.secondArchiveSelected
                                        ?.creationTimestamp as DateTime,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: ') for '),
                                TextSpan(
                                  text: resultsProvider.selectedAddress.address,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        HtmlWebView(
                          data: 'https://www.google.gr',
                          width: width * 0.92,
                          height: height * 0.68,
                        )
                      ],
                    )
                  : Container(),
            ),
          ),
          ElevatedButton(
            onPressed: () => {widget.previousPage()},
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

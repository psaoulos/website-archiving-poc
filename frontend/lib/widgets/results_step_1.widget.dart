import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/crawler_address.model.dart';

class ResultsStep1 extends StatefulWidget {
  double width;
  double height;
  Function nextPage;
  List<CrawlerAddress> allAddresses;
  Function selectAddress;
  ResultsStep1(
      {Key? key,
      required this.width,
      required this.height,
      required this.nextPage,
      required this.allAddresses,
      required this.selectAddress})
      : super(key: key);

  @override
  State<ResultsStep1> createState() => _ResultsStep1State();
}

class _ResultsStep1State extends State<ResultsStep1> {
  int selectedPage = -1;

  void updateSelectedPage(int index, BuildContext context) {
    if (widget.allAddresses[index].archivesSum > 1) {
      setState(() {
        selectedPage = index;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot generate differences for page that only has one previous archive!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData mode = Theme.of(context);
    bool isDarkMode = mode.brightness == Brightness.dark;
    List<CrawlerAddress> allAddresses = widget.allAddresses;

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (allAddresses.isNotEmpty)
                SizedBox(
                  height: widget.height,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: Column(
                      children: [
                        Text('${allAddresses.length} addresses found'),
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: allAddresses.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  tileColor: isDarkMode
                                      ? index == selectedPage
                                          ? Colors.grey[800]
                                          : null
                                      : index == selectedPage
                                          ? Colors.grey[200]
                                          : null,
                                  leading: OutlinedButton(
                                    onPressed: () {
                                      updateSelectedPage(index, context);
                                    },
                                    child: const Text('Select'),
                                  ),
                                  title: Text(allAddresses[index].address),
                                  onTap: () {
                                    updateSelectedPage(index, context);
                                  },
                                  trailing: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: allAddresses[index]
                                              .archivesSum
                                              .toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(text: ' archives'),
                                      ],
                                    ),
                                  ),
                                ),
                                if (index != allAddresses.length - 1)
                                  const Divider(),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: selectedPage == -1
                    ? null
                    : () {
                        widget.selectAddress(allAddresses[selectedPage]);
                        widget.nextPage();
                      },
                child: const Text('Next'),
              )
            ],
          ),
        ],
      ),
    );
  }
}

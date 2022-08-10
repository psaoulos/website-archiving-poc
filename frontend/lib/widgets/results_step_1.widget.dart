import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/crawler_address.model.dart';
import 'package:frontend/providers/results.provider.dart';
import 'package:frontend/services/results.services.dart';
import 'package:provider/provider.dart';

class ResultsStep1 extends StatefulWidget {
  int pageIndex;
  Function nextPage;
  ResultsStep1({
    Key? key,
    required this.pageIndex,
    required this.nextPage,
  }) : super(key: key);

  @override
  State<ResultsStep1> createState() => _ResultsStep1State();
}

class _ResultsStep1State extends State<ResultsStep1> {
  List<CrawlerAddress> allAddresses = [];
  int selectedPage = -1;

  @override
  void initState() {
    ResultsApiService.getAllAddresses().then((value) {
      if (value.success) {
        setState(() {
          allAddresses = value.addresses;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not fetch all addresses from Backend, please check Backend logs.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
    super.initState();
  }

  void updateSelectedPage(int index, BuildContext context) {
    if (allAddresses[index].archivesSum > 1) {
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
              child: widget.pageIndex == 0 && allAddresses.isNotEmpty
                  ? Column(
                      children: [
                        Text('${allAddresses.length} addresses found'),
                        Expanded(
                          child: ListView.builder(
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
                        ),
                      ],
                    )
                  : Container(),
            ),
          ),
          ElevatedButton(
            onPressed: selectedPage == -1
                ? null
                : () {
                    resultsProvider.selectAddress(allAddresses[selectedPage]);
                    widget.nextPage();
                  },
            child: const Text('Next'),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/crawler.services.dart';
import 'package:frontend/widgets/main_scaffold.widget.dart';

enum CrawlerActions {
  start,
  stop,
}

class ActionsScreen extends StatefulWidget {
  static const routeName = '/actions';
  final CrawlerActions action;
  const ActionsScreen({Key? key, required this.action}) : super(key: key);

  @override
  State<ActionsScreen> createState() => _ActionsScreenState();
}

class _ActionsScreenState extends State<ActionsScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController urlController = TextEditingController(
    text: 'https://www.in.gr',
  );
  TextEditingController iterationsController = TextEditingController(
    text: '10',
  );
  TextEditingController intervalController = TextEditingController(
    text: '600',
  );
  TextEditingController ratioController = TextEditingController(
    text: '5',
  );

  void startCrawler() {
    CrawlerApiService()
        .startCrawler(
      iterationsController.text,
      intervalController.text,
      ratioController.text,
      urlController.text,
    )
        .then(
      (response) {
        if (response.success) {
          if (response.started) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Crawler started!'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Crawler allready running!'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong, please check Backend logs!'),
            ),
          );
        }
      },
    );
  }

  Widget _buildStartScreen() {
    return Form(
      key: _formKey,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 600,
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Select the website to crawl over.',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'example: https://www.in.gr',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Text('Crawl url: '),
                        ),
                        SizedBox(
                          width: 250,
                          child: TextFormField(
                            controller: urlController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter root URL to crawl over';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Select how many time and how often \n the crawler should take an archive.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Text('Iterations: '),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: iterationsController,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  int.parse(value) <= 0) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Text('Interval (seconds): '),
                        ),
                        SizedBox(
                          width: 40,
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: intervalController,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  int.parse(value) <= 0) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Select the minimum difference percentage \n between archives in order for them to be kept.',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Input 0 for keeping everything.\nInput 90 for keeping only files that are 90% or more different.',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Text('Difference ratio: '),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            controller: ratioController,
                            validator: (value) {
                              int input = int.parse(value!);
                              if (value.isEmpty || input > 100 || input < 0) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  startCrawler();
                }
              },
              child: const Text('Start'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopScreen() {
    return Text('Stop');
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: widget.action == CrawlerActions.start ? 'Start' : 'Stop',
      childWidget: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.action == CrawlerActions.start
                  ? _buildStartScreen()
                  : _buildStopScreen(),
            ],
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}

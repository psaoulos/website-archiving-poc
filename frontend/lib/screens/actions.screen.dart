import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    text: '1.000',
  );

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
                        const Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Text('Difference ratio: '),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            controller: ratioController,
                            validator: (value) {
                              double entry = double.parse(value!);
                              if (value.isEmpty || entry > 1 || entry < 0) {
                                if (entry == 1) {
                                  return null;
                                }
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
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Starting crawler')),
                );
              }
            },
            child: const Text('Start'),
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

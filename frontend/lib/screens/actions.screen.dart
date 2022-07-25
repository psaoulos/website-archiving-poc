import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/crawler.services.dart';
import 'package:frontend/widgets/main_scaffold.widget.dart';
import 'package:frontend/widgets/time_scale_dropdown.widget.dart';

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
  String _approximateTime = "";
  IntervalOptions _dropdownValue = IntervalOptions.seconds;

  final TextEditingController _urlController = TextEditingController(
    text: 'https://www.in.gr',
  );
  final TextEditingController _iterationsController = TextEditingController(
    text: '10',
  );
  final TextEditingController _intervalController = TextEditingController(
    text: '600',
  );
  final TextEditingController _ratioController = TextEditingController(
    text: '5',
  );

  @override
  void dispose() {
    _urlController.dispose();
    _iterationsController.dispose();
    _intervalController.dispose();
    _ratioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _iterationsController.addListener(() {
      setState(() {
        _approximateTime = calculateTimeFromSeconds(getSecondsFromUserInputs());
      });
    });
    _intervalController.addListener(() {
      setState(() {
        _approximateTime = calculateTimeFromSeconds(getSecondsFromUserInputs());
      });
    });

    _approximateTime = calculateTimeFromSeconds(getSecondsFromUserInputs());
    super.initState();
  }

  int getSecondsFromUserInputs() {
    switch (_dropdownValue) {
      case IntervalOptions.seconds:
        return int.parse(_intervalController.text);
      case IntervalOptions.minutes:
        return int.parse(_intervalController.text) * 60;
      case IntervalOptions.hours:
        return int.parse(_intervalController.text) * 3600;
      case IntervalOptions.days:
        return int.parse(_intervalController.text) * 86400;
      default:
        return int.parse(_intervalController.text);
    }
  }

  String calculateTimeFromSeconds(int totalSeconds) {
    final iterations = int.parse(_iterationsController.text);
    final Duration duration = Duration(seconds: totalSeconds * iterations);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    String approx = "";
    if (days > 0) {
      approx = "$days Days";
    }
    if (hours > 0) {
      approx = "$approx $hours Hours";
    }
    if (minutes > 0) {
      approx = "$approx $minutes Minutes";
    }
    if (seconds > 0) {
      approx = "$approx $seconds Seconds";
    }
    return approx;
  }

  void onTimeDropDownChange(IntervalOptions? newValue) {
    setState(() {
      _dropdownValue = newValue!;
      _approximateTime = calculateTimeFromSeconds(getSecondsFromUserInputs());
    });
  }

  void startCrawler() {
    CrawlerApiService()
        .startCrawler(
      _iterationsController.text,
      _intervalController.text,
      _ratioController.text,
      _urlController.text,
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
                            controller: _urlController,
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
                          children: [
                            const Text(
                              'Select how many time and how often \n the crawler should take an archive.',
                              style: TextStyle(fontSize: 14),
                            ),
                            const Text(
                              'Approximate completion time in:',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              _approximateTime,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
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
                            controller: _iterationsController,
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
                          child: Text('Interval: '),
                        ),
                        TimeScaleDropdown(
                          dropdownValue: _dropdownValue,
                          onChanged: onTimeDropDownChange,
                        ),
                        SizedBox(
                          width: 40,
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: _intervalController,
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
                          width: 30,
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            controller: _ratioController,
                            validator: (value) {
                              int input = int.parse(value!);
                              if (value.isEmpty || input > 100 || input < 0) {
                                return '';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Text(
                          '%',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
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

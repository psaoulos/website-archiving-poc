import 'package:flutter/material.dart';

enum IntervalOptions { seconds, minutes, hours, days }

class TimeScaleDropdown extends StatelessWidget {
  IntervalOptions dropdownValue = IntervalOptions.seconds;
  Function onChanged;

  TimeScaleDropdown(
      {Key? key, required this.dropdownValue, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<IntervalOptions>(
        underline: const SizedBox(),
        value: dropdownValue,
        onChanged: (IntervalOptions? newValue) {
          onChanged(newValue);
        },
        items: IntervalOptions.values.map((IntervalOptions type) {
          switch (type) {
            case IntervalOptions.seconds:
              return DropdownMenuItem<IntervalOptions>(
                  value: type, child: const Text("Seconds"));
            case IntervalOptions.minutes:
              return DropdownMenuItem<IntervalOptions>(
                  value: type, child: const Text("Minutes"));
            case IntervalOptions.hours:
              return DropdownMenuItem<IntervalOptions>(
                  value: type, child: const Text("Hours"));
            case IntervalOptions.days:
              return DropdownMenuItem<IntervalOptions>(
                  value: type, child: const Text("Days"));
            default:
              return const DropdownMenuItem<IntervalOptions>(
                  value: IntervalOptions.seconds, child: Text("Seconds"));
          }
        }).toList());
  }
}

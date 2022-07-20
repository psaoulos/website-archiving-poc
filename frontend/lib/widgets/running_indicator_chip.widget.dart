import 'package:flutter/material.dart';

class RunningIndicatorChip extends StatelessWidget {
  bool isRunning;
  Function refreshFunction;
  RunningIndicatorChip(
      {Key? key, required this.isRunning, required this.refreshFunction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: isRunning ? Colors.green : Colors.grey,
      ),
      label: Text(isRunning ? 'Running' : 'Stopped'),
      deleteIcon: const Icon(Icons.refresh, color: Colors.black45),
      deleteButtonTooltipMessage: 'Refresh status',
      onDeleted: () {
        refreshFunction();
      },
      backgroundColor: isRunning ? Colors.green[100] : Colors.grey[350],
    );
  }
}

import 'package:flutter/material.dart';

class CenteredOutlinedButton extends StatelessWidget {
  final String buttonLabel;
  final double buttonWidth;
  final Function buttonOnClick;
  final EdgeInsetsGeometry padding;
  const CenteredOutlinedButton(
      {Key? key,
      required this.buttonLabel,
      required this.buttonWidth,
      required this.buttonOnClick,
      this.padding = const EdgeInsets.all(0)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: OutlinedButton(
        onPressed: () {
          buttonOnClick();
        },
        child: SizedBox(
          width: buttonWidth,
          child: Align(alignment: Alignment.center, child: Text(buttonLabel)),
        ),
      ),
    );
  }
}

import "package:universal_html/html.dart";
import 'package:flutter/material.dart';
import 'package:frontend/shims/dart_ui.dart' as ui;

class HtmlWebViewWeb extends StatelessWidget {
  final String data;
  final double width;
  final double height;
  const HtmlWebViewWeb(
      {Key? key, required this.data, required this.width, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData mode = Theme.of(context);
    bool isDarkMode = mode.brightness == Brightness.dark;
    // Dynamic name is needed in order for the widget to be rebuild on data change
    String tempName = "";
    if (data.length > 10) {
      tempName = data.substring(0, 10) + isDarkMode.toString();
    } else if (data.isEmpty) {
      tempName = 'emptyWebFrame$isDarkMode';
    } else {
      tempName = data + isDarkMode.toString();
    }
    String _src =
        "data:text/html;charset=utf-8,${data.replaceFirst('%7B%7B_text_color_%7D%7D', isDarkMode ? 'white' : 'black')}";
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        tempName,
        (int viewId) => IFrameElement()
          ..height = height.toString()
          ..width = width.toString()
          ..src = _src
          ..style.backgroundColor = isDarkMode ? '#404040' : ''
          ..style.border = 'none');
    return SizedBox(
        height: height,
        width: width,
        child: HtmlElementView(viewType: tempName));
  }
}

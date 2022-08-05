import "package:universal_html/html.dart";
import 'package:flutter/material.dart';
import 'package:frontend/shims/dart_ui.dart' as ui;
import 'dart:math';

class HtmlWebViewWeb extends StatelessWidget {
  final String data;
  final double width;
  final double height;
  const HtmlWebViewWeb(
      {Key? key, required this.data, required this.width, required this.height})
      : super(key: key);

  String generateRandomString(int len) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData mode = Theme.of(context);
    bool isDarkMode = mode.brightness == Brightness.dark;
    // Dynamic name is needed in order for the widget to be rebuild on data change
    String tempName = generateRandomString(10);
    String src =
        "data:text/html;charset=utf-8,${data.replaceFirst('%7B%7B_text_color_%7D%7D', isDarkMode ? 'white' : 'black')}";
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        tempName,
        (int viewId) => IFrameElement()
          ..height = height.toString()
          ..width = width.toString()
          ..src = src
          ..style.backgroundColor = isDarkMode ? '#404040' : ''
          ..style.border = 'none');
    return SizedBox(
        height: height,
        width: width,
        child: HtmlElementView(viewType: tempName));
  }
}

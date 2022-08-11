import 'package:frontend/widgets/htmlWebView/html_web_view.dart';
import "package:universal_html/html.dart";
import 'package:flutter/material.dart';
import 'package:frontend/shims/dart_ui.dart' as ui;
import 'dart:math';

class HtmlWebViewWeb extends StatelessWidget {
  final HtmlWebViewTypes type;
  final String data;
  final double width;
  final double height;
  const HtmlWebViewWeb({
    Key? key,
    required this.type,
    required this.data,
    required this.width,
    required this.height,
  }) : super(key: key);

  String generateRandomString(int len) {
    var r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  String getFormattedUrl(String data, bool isDarkMode) {
    if (type == HtmlWebViewTypes.data) {
      return "data:text/html;charset=utf-8,${data.replaceFirst('%7B%7B_text_color_%7D%7D', isDarkMode ? 'white' : 'black')}";
    } else if (type == HtmlWebViewTypes.url) {
      return data;
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData mode = Theme.of(context);
    bool isDarkMode = mode.brightness == Brightness.dark;
    // Dynamic name is needed in order for the widget to be rebuild on data change
    String tempName = generateRandomString(10);
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        tempName,
        (int viewId) => IFrameElement()
          ..height = height.toString()
          ..width = width.toString()
          ..src = getFormattedUrl(data, isDarkMode)
          ..style.backgroundColor = isDarkMode ? '#404040' : ''
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%');
    return SizedBox(
        height: height,
        width: width,
        child: HtmlElementView(viewType: tempName));
  }
}

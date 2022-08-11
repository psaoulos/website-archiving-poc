import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/widgets/htmlWebView/html_web_view.mobile.dart';
import 'package:frontend/widgets/htmlWebView/html_web_view.web.dart';

enum HtmlWebViewTypes { url, data }

class HtmlWebView extends StatelessWidget {
  final HtmlWebViewTypes type;
  final String data;
  final double width;
  final double height;
  const HtmlWebView(
      {Key? key, required this.type, required this.data, required this.width, required this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return HtmlWebViewWeb(
        type: type,
        data: data,
        width: width,
        height: height,
      );
    } else {
      return HtmlWebViewMobile(
        type: type,
        data: data,
        width: width,
        height: height,
      );
    }
  }
}

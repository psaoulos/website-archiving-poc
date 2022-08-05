import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend/widgets/htmlWebView/html_web_view.mobile.dart';
import 'package:frontend/widgets/htmlWebView/html_web_view.web.dart';

class HtmlWebView extends StatelessWidget {
  final String data;
  final double width;
  final double height;
  const HtmlWebView({Key? key, required this.data, required this.width, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return HtmlWebViewWeb(
        data: data,
        width: width,
        height: height,
      );
    } else {
      return HtmlWebViewMobile(
        data: data,
        width: width,
        height: height,
      );
    }
  }
}

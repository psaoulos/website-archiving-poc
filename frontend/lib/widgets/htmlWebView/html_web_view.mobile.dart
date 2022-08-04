import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlWebViewMobile extends StatefulWidget {
  final String data;
  final double width;
  final double height;
  const HtmlWebViewMobile(
      {Key? key, required this.data, required this.width, required this.height})
      : super(key: key);

  @override
  State<HtmlWebViewMobile> createState() => _HtmlWebViewMobileState();
}

class _HtmlWebViewMobileState extends State<HtmlWebViewMobile> {
  late WebViewController controller;
  @override
  void didUpdateWidget(covariant HtmlWebViewMobile oldWidget) {
    if (widget.data != oldWidget.data) {
      controller.loadUrl(getFormattedUrl(widget.data));
    }
    super.didUpdateWidget(oldWidget);
  }

  String getFormattedUrl(String encodedUrl) {
    return "data:text/html;charset=utf-8,$encodedUrl";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      width: 600,
      child: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: getFormattedUrl(widget.data),
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );
  }
}

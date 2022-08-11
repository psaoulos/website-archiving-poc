import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/htmlWebView/html_web_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlWebViewMobile extends StatefulWidget {
  final HtmlWebViewTypes type;
  final String data;
  final double width;
  final double height;
  const HtmlWebViewMobile({
    Key? key,
    required this.type,
    required this.data,
    required this.width,
    required this.height,
  }) : super(key: key);

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

  String getFormattedUrl(String data) {
    if (widget.type == HtmlWebViewTypes.data) {
      return "data:text/html;charset=utf-8,$data";
    } else if (widget.type == HtmlWebViewTypes.url) {
      return data;
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
      Factory(() => EagerGestureRecognizer())
    };

    UniqueKey _key = UniqueKey();
    return SizedBox(
      height: 600,
      width: 600,
      child: WebView(
        key: _key,
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: getFormattedUrl(widget.data),
        gestureRecognizers: gestureRecognizers,
        onWebViewCreated: (WebViewController webViewController) {
          controller = webViewController;
        },
      ),
    );
  }
}

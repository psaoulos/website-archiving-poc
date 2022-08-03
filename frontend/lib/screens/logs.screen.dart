import 'dart:async';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:frontend/constants/services.constants.dart';
import 'package:frontend/widgets/main_scaffold.widget.dart';
import 'package:frontend/widgets/running_indicator_chip.widget.dart';
import 'dart:ui' as ui;
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class LogsScreen extends StatefulWidget {
  static const routeName = '/backend-logs';
  const LogsScreen({Key? key}) : super(key: key);

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  socket_io.Socket logsSocket = socket_io.io(
      backendAddress + backendGetLogs,
      socket_io.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect() // disable auto-connection
          .build());
  String logs = "";

  @override
  void initState() {
    logsSocket.onConnect((_) {
      logsSocket.emit('frontend_request', '');
      setState(() {});
    });
    logsSocket.onDisconnect((_) {
      print("disconneted");
      Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {});
        }
      });
    });
    logsSocket.on('logs_update', (json) {
      setState(() {});
    });
    logsSocket.on('backend_response', (json) {
      print('Got response: ' + json['logs']);
      setState(() {
        logs = json['logs'];
      });
    });

    logsSocket.connect();
    super.initState();
  }

  @override
  void dispose() {
    logsSocket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData mode = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    bool _isDarkMode = mode.brightness == Brightness.dark;

    // // ignore: undefined_prefixed_name
    // ui.platformViewRegistry.registerViewFactory(
    //     'hello-world-html',
    //     (int viewId) => IFrameElement()
    //       ..height = "600"
    //       ..width = "600"
    //       ..src = "data:text/html;charset=utf-8,${logsResponse?.logs}"
    //       ..style.border = 'none');

    return MainScaffold(
      title: "Backend Logs",
      childWidget: SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Backend Logs'),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Text('Socket status:'),
                    ),
                    RunningIndicatorChip(
                      isRunning: logsSocket.connected,
                      refreshFunction: () {
                        if (logsSocket.connected) {
                          logsSocket.close();
                        }
                        logsSocket.connect();
                      },
                      activeText: "Live",
                      stoppedText: "Disconnected",
                    )
                  ],
                ),
                // if (logsResponse != null)
                //   SizedBox(
                //       height: 600,
                //       width: 1000,
                //       child: HtmlElementView(viewType: 'hello-world-html')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

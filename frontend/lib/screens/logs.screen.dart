import 'dart:async';
import 'package:frontend/widgets/htmlWebView/html_web_view.dart';

import 'package:flutter/material.dart';
import 'package:frontend/constants/services.constants.dart';
import 'package:frontend/widgets/main_scaffold.widget.dart';
import 'package:frontend/widgets/running_indicator_chip.widget.dart';
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
  String logsResponse = "";

  @override
  void initState() {
    logsSocket.onConnect((_) {
      logsSocket.emit('frontend_request', '');
      setState(() {});
    });
    logsSocket.onDisconnect((_) {
      Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {});
        }
      });
    });
    logsSocket.on('logs_update', (json) {
      final Map jsonMap = Map.from(json);
      setState(() {
        logsResponse = jsonMap['logs'];
      });
    });
    logsSocket.on('backend_response', (json) {
      setState(() {
        logsResponse = json['logs'];
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

    return MainScaffold(
      title: "Backend Logs",
      childWidget: SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: SizedBox(
                    width: deviceWidth * 0.8,
                    child: Row(
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
                          stoppedText: "----",
                        )
                      ],
                    ),
                  ),
                ),
                if (logsResponse != "")
                  HtmlWebView(
                    data: logsResponse,
                    width: deviceWidth * 0.8,
                    height: screenHeight,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

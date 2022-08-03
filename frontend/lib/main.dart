import 'package:flutter/material.dart';
import 'package:frontend/screens/actions.screen.dart';
import 'package:frontend/screens/dashboard.screen.dart';
import 'package:frontend/screens/logs.screen.dart';
import 'package:frontend/screens/results.screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/main.provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // this line is needed to use async/await in main()
  final prefs = await SharedPreferences.getInstance();
  final isDarkTheme = prefs.getBool("is_dark_theme") ?? false;

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => MainProvider(darkMode: isDarkTheme),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String appName = 'WebCrawler Console';

  @override
  Widget build(BuildContext context) {
    final mainProvider = Provider.of<MainProvider>(context, listen: true);
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData.from(
        colorScheme: const ColorScheme.dark(),
      ).copyWith(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            primary: Colors.white,
          ),
        ),
      ),
      themeMode: mainProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: DashboardScreen.routeName,
      onGenerateRoute: (settings) {
        final arguments = settings.arguments;
        if (settings.name == DashboardScreen.routeName) {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => const DashboardScreen(),
            settings: settings,
          );
        } else if (settings.name == ActionsScreen.routeName) {
          if (arguments != null && arguments != '') {
            final action = settings.arguments as CrawlerActions;
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => ActionsScreen(action: action),
              settings: settings,
            );
          }
        } else if (settings.name == ResultsScreen.routeName) {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => ResultsScreen(),
            settings: settings,
          );
        } else if (settings.name == LogsScreen.routeName) {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => LogsScreen(),
            settings: settings,
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (ctx) => const DashboardScreen(),
          settings: settings,
        );
      },
    );
  }
}

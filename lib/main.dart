import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:window_manager/window_manager.dart';
import '/config/app.dart';
import 'pages/apps.dart';


void main() async {
  // HELP Window manager is for windos and linux to set options like (title, size...).
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow(WindowOptions(
    title: App.title,
    size: const Size(1200, 610)
  ), () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Run the app.
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: App.title,
      onGenerateTitle:(context) => App.title,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const AppsPage()
      },
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
    );
  }
}

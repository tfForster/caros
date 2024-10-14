import 'package:flutter/material.dart';
import '/config/app.dart';
import '/controller/server.dart';
import '/ui/alert.dart';
import '/ui/dialog.dart';
import '/ui/notify.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final EderServer ederServer = EderServer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Hello World, ${App.author}')
      )
    );
  }
}

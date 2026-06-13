import 'package:flutter/material.dart';

class App {
  static String name = 'test_app';
  static String title = 'CarOS';
  static String author = 'Benno Klan';
  static String version = '1.0.0';
  static String info = 'App: $title, Version: $version';

  static const Color accent   = Color(0xFF42A5F5);
  static const Color bg       = Color(0xFF0A0A0A);
  static const Color surface  = Color(0xFF141414);
  static const Color border   = Color(0xFF242424);

  // HELP Setup Eder Server infos.
  static const String baseUrl = 'http://localhost:8000/';
  static const String defaultUser = 'dau';
  static const String defaultPass = 'dau';
  static const String hashKey = '&eder-server.hash_key:24=';
}

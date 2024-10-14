class App {
  // HELP Setup App infos.
  static String name = 'test_app';
  static String title = 'Meine Test App';
  static String author = 'Benno Klan';
  static String version = '1.0.0';
  static String info = 'App: $title, Version: $version';

  // HELP Setup Eder Server infos.
  static const String baseUrl = 'http://localhost:8000/';
  static const String defaultUser = 'dau';
  static const String defaultPass = 'dau';
  static const String hashKey = '&eder-server.hash_key:24=';
}

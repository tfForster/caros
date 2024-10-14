import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app.dart';


class EderServer {
  bool _connected = false;
  String _token = '';
  String _usernameHash = '';
  String _passwordHash = '';
  Map<String, String> _headers = {};

  EderServer({String baseUrl = App.baseUrl, String username = App.defaultUser, String password = App.defaultPass}) {
    _usernameHash = _xorEncryptDecrypt(username, App.hashKey);
    _passwordHash = _xorEncryptDecrypt(password, App.hashKey);
  }

  _xorEncryptDecrypt(String input, String key) {
    List<int> keyBytes = key.codeUnits;
    List<int> inputBytes = input.codeUnits;
    List<int> result = [];
    for (int i = 0; i < inputBytes.length; i++) {
      result.add(inputBytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return String.fromCharCodes(result);
  }

  _before() async {
    try {
      if (!_connected) {
        await reconnect();
      }
      if (_connected) {
        return;
      }
      throw Exception("Es konnte keine Verbindung zum Server Hergestellt werden!");
    } catch (e) {
      rethrow;
    }
  }

  _return(http.Response response, String returnType) async {
    try {
      if (response.statusCode == 200) {
        return returnType == 'json' ? await jsonDecode(response.body) : true;
      }
      return returnType == 'json' ? [] : false;
    } catch (e) {
      rethrow;
    }
  }

  connect() async {
    try {
      final response = await http.post(
        Uri.parse('${App.baseUrl}main/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': _xorEncryptDecrypt(_usernameHash, App.hashKey),
          'password': _xorEncryptDecrypt(_passwordHash, App.hashKey),
        },
      );
      if (response.statusCode == 200) {
        _token = jsonDecode(response.body)['access_token'];
        _headers = {
          'Authorization': 'Bearer $_token',
        };
        _connected = true;
      } else {
        _connected = false;
        throw Exception(response.body);
      }
    } catch (e) {
      rethrow;
    }
  }

  reconnect() async {
    try {
      await connect();
    } catch (e) {
      rethrow;
    }
  }

  get(String url, String returnType, {Map<String, String>? headers}) async {
    try {
      _before();
      return await _return(
        await http.get(
          Uri.parse('${App.baseUrl}${App.name}$url'),
          headers: headers ?? _headers
        ),
        returnType
      );
    } catch (e) {
      rethrow;
    }
  }

  post(String url, String returnType, {Map<String, String>? headers, Object? body}) async {
    try {
      _before();
      return await _return(
        await http.post(
          Uri.parse('${App.baseUrl}${App.name}$url'),
          headers: headers ?? _headers,
          body: body,
        ),
        returnType
      );
    } catch (e) {
      rethrow;
    }
  }

  put(String url, String returnType, {Map<String, String>? headers, Object? body}) async {
    try {
      _before();
      return await _return(
        await http.put(
          Uri.parse('${App.baseUrl}${App.name}$url'),
          headers: headers ?? _headers,
          body: body,
        ),
        returnType
      );
    } catch (e) {
      rethrow;
    }
  }

  delete(String url, String returnType, {Map<String, String>? headers, Object? body}) async {
    try {
      _before();
      return await _return(
        await http.delete(
          Uri.parse('${App.baseUrl}${App.name}$url'),
          headers: headers ?? _headers,
          body: body,
        ),
        returnType
      );
    } catch (e) {
      rethrow;
    }
  }
}

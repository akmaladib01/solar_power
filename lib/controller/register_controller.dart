import 'dart:convert';
import 'package:http/http.dart' as http;

class RequestController_SignUp {
  String path;
  String server;
  http.Response? _res;
  final Map<dynamic, dynamic> _body = {};
  final Map<String, String> _headers = {};
  dynamic _resultData;

  RequestController_SignUp({required this.path, this.server =
  "http://10.131.73.249"});
  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }

  Future<void> post() async {
    _res = await http.post(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }

  Future<void> get() async {
    _res = await http.get(
      Uri.parse(server + path),
      headers: _headers,
    );
    _parseResult();
  }

  Future<void> put() async {
    _res = await http.put(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }

  void _parseResult() {
    try {
      print("raw response:${_res?.body}");
      _resultData = jsonDecode(_res?.body?? "");
    }catch(ex){
      _resultData = _res?.body;
      print("exception in http result parsing ${ex}");
    }
  }
  dynamic result() {
    return _resultData;
  }
  int status() {
    return _res?.statusCode ?? 0;
  }
}
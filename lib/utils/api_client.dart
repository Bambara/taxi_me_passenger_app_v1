import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiClient {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  final String _barUrl = 'http://173.82.154.185';

  // final String _barUrl = 'http://13.229.230.179';
  final String mapUrl = 'http://165.232.168.102';

  // http://165.232.168.102:5001/
  // http://165.232.168.102:5000

  final String _baseSocket = ':8095';
  final String _driverSocket = ':8099';
  final String _passengerSocket = ':8101';
  final String mapSocket = ':5000';

  var token;

  // _getToken() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   token = jsonDecode(localStorage.getString('token'))['token'];
  // }

  getData(apiUrl) async {
    var fullUrl = _barUrl + _baseSocket + apiUrl;
    return await http.get(Uri.parse(fullUrl), headers: _setHeaders());
  }

  Future postData(data, apiUrl) async {
    var fullUrl = _barUrl + _baseSocket + apiUrl;
    _logger.i(jsonEncode(data));
    return await http.post(Uri.parse(fullUrl), body: jsonEncode(data), headers: _setHeaders());
  }

  Future patchData(data, query, apiUrl) async {
    var fullUrl = '${_barUrl + _baseSocket + apiUrl}?$query';
    _logger.i(jsonEncode(data));
    return await http.patch(Uri.parse(fullUrl), body: jsonEncode(data), headers: _setHeaders());
  }

  getDataAPI(apiUrl) async {
    var fullUrl = _barUrl + _baseSocket + apiUrl;
    return await http.post(Uri.parse(fullUrl), headers: _setHeaders());
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Connection': 'keep-alive',
      };

  String get passengerSocket => _passengerSocket;

  String get driverSocket => _driverSocket;

  String get baseSocket => _baseSocket;

  String get barUrl => _barUrl;
}

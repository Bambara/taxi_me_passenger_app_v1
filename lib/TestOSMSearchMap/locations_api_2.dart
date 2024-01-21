import 'dart:convert';

import 'package:http/http.dart' as http;

import 'locations_model_2.dart';

class LocationsAPI2 {
  // --------------------------------- MODEL 2 --------------------------------- \\

  static const apiKey = '189df97f5958253ef6c38a94537fa094';

  static Future<List<String>> searchPlaces({required String query}) async {
    final limit = 3;
    final url = 'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=$limit&appid=$apiKey';

    final response = await http.get(Uri.parse(url));
    final body = json.decode(response.body);

    return body.map<String>((json) {
      final city = json['name'];
      final country = json['country'];

      return '$city, $country';
    }).toList();
  }

  static Future<SLLocationsModel2> getLocations({required String place}) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$place&units=metric&appid=$apiKey';

    final response = await http.get(Uri.parse(url));
    final body = json.decode(response.body);

    return _convert(body);
  }

  static SLLocationsModel2 _convert(json) {
    final main = json['weather'].first['main'];
    final city = json['name'];
    final int degrees = (json['main']['temp']).toInt();

    print('main: $main');

    return SLLocationsModel2(
      city: city,
      degrees: degrees,
      description: main,
    );
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ocations_model.dart';

class LocationsAPI {
  // --------------------------------- MODEL 1 --------------------------------- \\

  static Future<List<String>> searchPlaces({required String query}) async {
    final url = 'http://139.59.239.142/q/$query';

    final response = await http.get(Uri.parse(url));
    final body = json.decode(response.body);

    return body.map<String>((json) {
      final city = json['city'];
      final country = json['country'];

      return '$city, $country';
    }).toList();
  }

  static Future<SLLocationsModel> getLocations({required String place}) async {
    print('body');
    final url = 'http://139.59.239.142/q/$place';

    final response = await http.get(Uri.parse(url));
    final body = json.decode(response.body);
    print(body);
    return _convert(body);
  }

  static SLLocationsModel _convert(json) {
    final wikipedia = json['wikipedia'];
    final rank = json['rank'];
    final county = json['county'];
    final street = json['street'];
    final wikidata = json['wikidata'];
    final countryCode = json['country_code'];
    final osmId = json['osm_id'];
    final housenumbers = json['housenumbers'];
    final id = json['id'];
    final city = json['city'];
    final displayName = json['display_name'];
    final lon = json['lon'];
    final state = json['state'];
    final boundingbox = json['boundingbox'].cast<double>();
    final type = json['type'];
    final importance = json['importance'];
    final lat = json['lat'];
    final resultClass = json['class'];
    final name = json['name'];
    final country = json['country'];
    final nameSuffix = json['name_suffix'];
    final osmType = json['osm_type'];
    final placeRank = json['place_rank'];
    final alternativeNames = json['alternative_names'];

    print('displayName: $displayName');

    return SLLocationsModel(
        wikipedia: wikipedia,
        rank: rank,
        county: county,
        street: street,
        wikidata: wikidata,
        countryCode: countryCode,
        osmId: osmId,
        housenumbers: housenumbers,
        id: id,
        city: city,
        displayName: displayName,
        lon: lon,
        state: state,
        boundingbox: boundingbox,
        type: type,
        importance: importance,
        lat: lat,
        resultClass: resultClass,
        name: name,
        country: country,
        nameSuffix: nameSuffix,
        osmType: osmType,
        placeRank: placeRank,
        alternativeNames: alternativeNames);
  }
}

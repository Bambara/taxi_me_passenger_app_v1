import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'place.dart';

class SearchModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Place> _suggestions = history;

  List<Place> get suggestions => _suggestions;

  String _query = '';

  String get query => _query;

  void onQueryChanged(String query) async {
    print('awaaa');
    if (query == _query) return;

    _query = query;
    _isLoading = true;
    notifyListeners();

    if (query.isEmpty) {
      _suggestions = history;
    } else {
      final response = await http.get(Uri.parse('http://139.59.239.142/q/$query'));
      final body = json.decode(utf8.decode(response.bodyBytes));
      final features = body['results'] as List;

      _suggestions = features.map((e) => Place.fromJson(e)).toSet().toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _suggestions = history;
    notifyListeners();
  }
}

const List<Place> history = [
  Place(
    name: 'San Fracisco',
    state: 'California',
    country: 'United States of America',
    long: 0,
    lat: 0,
    display_name: '',
  ),
  Place(
    name: 'Singapore',
    state: '',
    country: 'Singapore',
    long: 0,
    lat: 0,
    display_name: '',
  ),
  Place(
    name: 'Munich',
    state: 'Bavaria',
    country: 'Germany',
    long: 0,
    lat: 0,
    display_name: '',
  ),
  Place(
    name: 'London',
    state: '',
    country: 'United Kingdom',
    long: 0,
    lat: 0,
    display_name: '',
  ),
];

import 'package:flutter/material.dart';

import './locations_model_2.dart';
import 'locations_api_2.dart';

class SearchResultPlaces extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            if (query.isEmpty) {
              close(context, '');
            } else {
              query = '';
              showSuggestions(context);
            }
          },
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => FutureBuilder<SLLocationsModel2>(
        future: LocationsAPI2.getLocations(place: query),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Something went wrong!',
                    style: TextStyle(fontSize: 28, color: Colors.black),
                  ),
                );
              } else {
                return buildResultSuccess(snapshot.data!);
              }
          }
        },
      );

  @override
  Widget buildSuggestions(BuildContext context) => Container(
        child: FutureBuilder<List<String>>(
          future: LocationsAPI2.searchPlaces(query: query),
          builder: (context, snapshot) {
            if (query.isEmpty) return buildNoSuggestions();

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError || snapshot.data!.isEmpty) {
                  return buildNoSuggestions();
                } else {
                  return buildSuggestionsSuccess(snapshot.data!);
                }
            }
          },
        ),
      );

  Widget buildNoSuggestions() => Center(
        child: Text(
          'No suggestionss!',
          style: TextStyle(fontSize: 28, color: Colors.black),
        ),
      );

  Widget buildSuggestionsSuccess(List<String> suggestions) => ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];

          return ListTile(
            onTap: () {
              query = suggestion;
              showResults(context);
            },
            leading: Icon(
              Icons.location_on,
              color: Colors.black,
            ),
            title: Text(suggestion),
          );
        },
      );

  Widget buildResultSuccess(SLLocationsModel2 slLocationsModel) => Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slLocationsModel.city,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            Text(
              slLocationsModel.city,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            Text('${slLocationsModel.description}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
          ],
        ),
      );
}

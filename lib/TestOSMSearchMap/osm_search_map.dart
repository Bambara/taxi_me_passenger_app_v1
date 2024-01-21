import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../utils/custom_text_style.dart';
import '../views/menu/menu_view.dart';
import 'search_result_places.dart';

class OSMSearchMap extends StatefulWidget {
  @override
  _OSMSearchMapState createState() => _OSMSearchMapState();
}

class _OSMSearchMapState extends State<OSMSearchMap> {
  late Position _currentPosition;
  late Widget _mapAreaWidget;

  @override
  void initState() {
    super.initState();
    _mapAreaWidget = _mapAfterLoading();
    //_getCurrentLocation();
  }

  _getCurrentLocation() {
    try {
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, forceAndroidLocationManager: true).then((Position position) {
        setState(() {
          _currentPosition = position;
          _mapAreaWidget = _mapAfterLoading();
          print(_currentPosition.latitude);
          print(_currentPosition.longitude);
        });
      }).catchError((e) {
        print(e);
      });
    } catch (error) {
      print(error);
    }
  }

  _mapWhileLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Please wait. Your map is build for you.",
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20.0,
        ),
        SizedBox(height: 35.0, width: 35.0, child: CircularProgressIndicator()),
      ],
    );
  }

  _mapAfterLoading() {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(7.8731, 80.7718),
        zoom: 8.5,
      ),
      layers: [
        TileLayerOptions(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(7.8731, 80.7718),
              builder: (ctx) => Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      color: Colors.white,
      child: TextButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: Colors.black,
              size: 30.0,
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              'Press to search for location',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: 10.0,
            ),
            Icon(
              Icons.location_on,
              color: Colors.black,
              size: 30.0,
            ),
            IconButton(
                icon: Icon(Icons.menu, color: Colors.black, size: 30.0),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Menu();
                      });
                }),
          ],
        ),
        onPressed: () async {
          showSearch(context: context, delegate: SearchResultPlaces());

          final results = await showSearch(context: context, delegate: SearchResultPlaces());

          print('Result: $results');
        },
      ),
    );
  }

  Widget _floatVehicles() {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 20, offset: Offset(-6, -10)), BoxShadow(color: Colors.grey.shade400, blurRadius: 20, offset: Offset(-6, 10))]),
            child: Card(
              elevation: 1,
              margin: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
              child: Container(
                margin: EdgeInsets.all(24),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Tuk",
                      style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Image(
                      image: AssetImage("assets/icons/tuk.png"),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Nano",
                      style: CustomTextStyle.mediumTextStyle,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Image(
                      image: AssetImage("assets/icons/car.png"),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Mini",
                      style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Image(
                      image: AssetImage("assets/icons/hatchback.png"),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Sedan",
                      style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Image(
                      image: AssetImage("assets/icons/city.png"),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Van",
                      style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Image(
                      image: AssetImage("assets/icons/van.png"),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [_mapAreaWidget, _searchBar(), _floatVehicles()],
            ),
          ),
        ],
      ),
    ));
  }
}

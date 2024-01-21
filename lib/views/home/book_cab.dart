import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:syncfusion_flutter_maps/maps.dart';

import '../../utils/api_client.dart';
import '../../utils/custom_text_style.dart';
import '../../widgets/loading_dialog.dart';
import '../pickup_both_locations.dart';
import 'DriverSearch.dart';
import 'dialog/promo_code_dialog.dart';

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
// LatLng SOURCE_LOCATION = LatLng(42.7477863, -71.1699932);
// LatLng DEST_LOCATION = LatLng(42.6871386, -71.2143403);

class BookCab extends StatefulWidget {
  final String passengerCode;
  final bool isTextWritten;
  final String pickupPlaceAddress;
  final LatLng pickupPlace;
  final String dropOffPlaceAddress;
  final LatLng dropOffPlace;

  const BookCab(this.passengerCode, this.isTextWritten, this.pickupPlaceAddress, this.pickupPlace, this.dropOffPlaceAddress, this.dropOffPlace, {super.key});

  @override
  _BookCabState createState() => _BookCabState(isTextWritten);
}

class _BookCabState extends State<BookCab> {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  var distance;
  var distanceKM;
  bool cardValue = false;
  bool cashValue = true;

  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw";

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late bool isTextWritten;

  //Tuk
  var tukList;

  //Nano
  var nanoList;

  //Smart
  var smartList;

  //prime
  var primeList;

  //van
  var miniVan;

  var selectedVehicleSubCategory;
  var lowerBidLimit = 0;
  var selectedCategoryDetail;
  var tripTotalCost = '0';
  late List polylinePointss;

  late io.Socket socket;

  // List<MapLatLng> polyline;
  // List<List<MapLatLng>> polylines;

  late List<MapLatLng> polyline;
  List<PolylineModel> polylines = [];
  MapZoomPanBehavior zoomPanBehavior = MapZoomPanBehavior(
    minZoomLevel: 13,
    maxZoomLevel: 16,
    enablePinching: true,
    enablePanning: true,
  );

  _BookCabState(this.isTextWritten);

  String passengerCode = 'passengerCode';
  late Fluttertoast flutterToast;

  var selectedVehicleCategory;

  List<dynamic> rideDetailsList = [];
  List<dynamic> markerData = [];
  bool imagesLoaded = false;

  bool loaded = false;

  @override
  void dispose() {
    super.dispose();
    // socket.disconnect();
    // _logger.i("Socket Disconnected : " + socket.disconnected.toString());
  }

  @override
  void initState() {
    super.initState();

    setMapPins();

    initSocket();
    getAllLocation();

    setSourceAndDestinationIcons();

    if (isTextWritten) {}
    flutterToast = Fluttertoast();
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) => getAllDriverLocation());
  }

  void initSocket() {}

  getAllDriverLocation() async {
    // String url = "http://192.168.8.100:8099";
    socket = io.io(ApiClient().barUrl + ApiClient().passengerSocket, <String, dynamic>{
      'transports': ["websocket"],
      'autoConnect': true,
    });
    // socket.connect();
    String socketID = socket.id!;

    socket.on('connect', (_) {});

    if (socket.connected) {
      var data = {'passengerId': await getPassengerDetails(), 'longitude': widget.pickupPlace.longitude, 'latitude': widget.pickupPlace.latitude, 'socketId': socket.id, 'radius': 10};

      socket.emit('getOnlineDriversBylocation', data);
    }
    //
    socket.on('allOnlineDriversResult', (data) {
      if (mounted) {
        setState(() {
          markerData = data;
          // _logger.i('Marker Data : ' + markerData.length.toString());
          // _logger.i('Marker Data : ' + markerData.toString());
        });
      }
    });
  }

  getAllLocation() async {
    try {
      var data = {'latitude': widget.pickupPlace.latitude, 'longitude': widget.pickupPlace.longitude};
      var res = await ApiClient().postData(data, '/vehiclecategory/getCategoryAllDataTimeAndLocationBased');
      var result = json.decode(res.body);

      // print(result);
      // _logger.w(data);
      // _logger.w(result);
      if (result['message'] == "success") {
        if (mounted) {
          setState(() {
            tukList = result['content'][0];
            nanoList = result['content'][0];
            smartList = result['content'][2];
            // primeList = result['content'][3];
            // miniVan = result['content'][4];

            imagesLoaded = true;
          });
        }
      } else {
        return "No Data";
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  void setSourceAndDestinationIcons() async {}

  // Server deployed
  // http://165.232.168.102:5000/
  // http://165.232.168.102:5001/

  Future<dynamic> setMapPins() {
    var steps;
    const JsonDecoder decoder = JsonDecoder();
    List<MapLatLng> polyLineFrom = <MapLatLng>[];
    final baseUrl =
        "${ApiClient().mapUrl + ApiClient().mapSocket}/route/v1/driving/${widget.pickupPlace.longitude},${widget.pickupPlace.latitude};${widget.dropOffPlace.longitude},${widget.dropOffPlace.latitude}?steps=true";

    // _logger.i(BASE_URL);
    return http.get(Uri.parse(baseUrl)).then((http.Response response) {
      String res = response.body;

      try {
        steps = decoder.convert(res)["routes"][0]["legs"][0]["steps"];

        if (steps != null) {
          for (var i = 0; i < steps.length; i++) {
            var insertion = steps[i]['intersections'];

            for (var j = 0; j < insertion.length; j++) {
              polyLineFrom.add(MapLatLng(insertion[j]['location'][1], insertion[j]['location'][0]));
            }
          }

          setState(() {
            var distanceInMeter = decoder.convert(res)["routes"][0]["distance"];
            var distanceInKM = distanceInMeter / 1000;
            double num2 = double.parse((distanceInKM).toStringAsFixed(2));
            distanceKM = num2;
            _logger.i(distanceKM);
            polylines = <PolylineModel>[
              PolylineModel(polyLineFrom, 5, Colors.blue),
            ];
            _logger.i(polylines);
            zoomPanBehavior = MapZoomPanBehavior(
              minZoomLevel: 13,
              maxZoomLevel: 16,
              enablePinching: true,
              enablePanning: true,
              focalLatLng: MapLatLng(widget.pickupPlace.latitude, widget.pickupPlace.longitude),
            );
            loaded = true;
          });
        }
      } catch (e) {
        throw Exception(e);
      }
    });
  }

  late String contactNum;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    /*return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, dialogTheme: const DialogTheme(backgroundColor: Colors.white), canvasColor: Colors.transparent, accentColor: Colors.amber),
      home: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: imagesLoaded != false
            ? Builder(
                builder: (context) {
                  return Stack(
                    children: [
                      polylines != null
                          ? SfMaps(
                              layers: [
                                MapTileLayer(
                                  initialFocalLatLng: MapLatLng(widget.pickupPlace.latitude, widget.pickupPlace.longitude),
                                  initialZoomLevel: 13,
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  zoomPanBehavior: zoomPanBehavior,
                                  sublayers: [
                                    MapPolylineLayer(
                                      polylines: List<MapPolyline>.generate(
                                        polylines.length,
                                        (int index) {
                                          // _logger.i('Poly Line Length : ' + polylines.length.toString());
                                          return MapPolyline(
                                            points: polylines[index].points,
                                            color: polylines[index].color,
                                            width: polylines[index].width,
                                          );
                                        },
                                      ).toSet(),
                                    ),
                                  ],
                                  initialMarkersCount: markerData == null ? 0 : markerData.length,
                                  markerBuilder: (context, index) {
                                    try {
                                      return MapMarker(
                                          iconColor: Colors.white,
                                          iconStrokeColor: Colors.blue,
                                          iconStrokeWidth: 2,
                                          latitude: markerData[index]['currentLocation']['latitude'],
                                          longitude: markerData[index]['currentLocation']['longitude'],
                                          child: Image.asset(
                                            "assets/icons/car_marker.png",
                                            scale: 1,
                                          ));
                                    } catch (e) {
                                      _logger.e(e.toString());
                                      return const MapMarker(latitude: 0, longitude: 0);
                                    }
                                  },
                                ),
                              ],
                            )
                          : Container(),
                      Column(
                        key: const Key("Cars"),
                        children: [
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.only(right: 12, top: 24),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const PickupBothLocations()), (Route<dynamic> route) => false);

                                  // Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (context) => UserDashboardPage()), (Route<dynamic> route) => false);
                                  // Navigator.of(context).pop();
                                },
                                child: const Image(image: AssetImage("assets/icons/ic_close.png")),
                              ),
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: 10,
                                  margin: const EdgeInsets.only(left: 16),
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                                  height: 10,
                                ),
                                Expanded(
                                  flex: 100,
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      widget.pickupPlaceAddress.toString(),
                                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey.shade800),
                                    ),
                                  ),
                                ),
                                IconButton(icon: const Icon(Icons.my_location, color: Colors.greenAccent, size: 18), onPressed: () {})
                              ],
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: 10,
                                  margin: const EdgeInsets.only(left: 16),
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.pink),
                                  height: 10,
                                ),
                                Expanded(
                                  flex: 100,
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      widget.dropOffPlaceAddress.toString(),
                                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey.shade800),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    icon: const Icon(
                                      Icons.local_taxi_sharp,
                                      color: Colors.pink,
                                      size: 18,
                                    ),
                                    onPressed: () {})
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 80,
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const <Widget>[],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.002,
                          ),
                          SizedBox(
                            height: size.height * 0.38,
                            child: Card(
                                elevation: 1,
                                color: const Color(0xFFFF922C),
                                margin: const EdgeInsets.all(0),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "Pick your Category",
                                                  style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.black, fontSize: 22),
                                                )),
                                            Container(
                                              alignment: Alignment.topCenter,
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: GestureDetector(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "-   ",
                                                    style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                                                  ),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    if (selectedVehicleSubCategory == 'Tuk' && lowerBidLimit != tukList['lowerBidLimit']) {
                                                      lowerBidLimit = lowerBidLimit - 1;
                                                    } else if (selectedVehicleSubCategory == 'Nano' && lowerBidLimit != nanoList['lowerBidLimit']) {
                                                      lowerBidLimit = lowerBidLimit - 1;
                                                    } else if (selectedVehicleSubCategory == 'Smart' && lowerBidLimit != smartList['lowerBidLimit']) {
                                                      lowerBidLimit = lowerBidLimit - 1;
                                                    } else if (selectedVehicleSubCategory == 'Prime' && lowerBidLimit != primeList['lowerBidLimit']) {
                                                      lowerBidLimit = lowerBidLimit - 1;
                                                    } else if (selectedVehicleSubCategory == 'Mini Van' && lowerBidLimit != miniVan['lowerBidLimit']) {
                                                      lowerBidLimit = lowerBidLimit - 1;
                                                    }
                                                  });
                                                  priceCalculation();
                                                },
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.topCenter,
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: Text(
                                                "Rs.$lowerBidLimit",
                                                style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 30),
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.centerRight,
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: GestureDetector(
                                                child: Container(
                                                  alignment: Alignment.centerRight,
                                                  child: Text(
                                                    "  +",
                                                    style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                                                  ),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    if (selectedVehicleSubCategory == 'Tuk' && lowerBidLimit != tukList['upperBidLimit']) {
                                                      lowerBidLimit = lowerBidLimit + 1;
                                                    } else if (selectedVehicleSubCategory == 'Nano' && lowerBidLimit != nanoList['upperBidLimit']) {
                                                      lowerBidLimit = lowerBidLimit + 1;
                                                    } else if (selectedVehicleSubCategory == 'Smart' && lowerBidLimit != smartList['upperBidLimit']) {
                                                      lowerBidLimit = lowerBidLimit + 1;
                                                    } else if (selectedVehicleSubCategory == 'Prime' && lowerBidLimit != primeList['upperBidLimit']) {
                                                      lowerBidLimit = lowerBidLimit + 1;
                                                    } else if (selectedVehicleSubCategory == 'Mini Van' && lowerBidLimit != miniVan['upperBidLimit']) {
                                                      lowerBidLimit = lowerBidLimit + 1;
                                                    }
                                                    priceCalculation();
                                                  });
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                              flex: 6,
                                              child: SizedBox(
                                                height: size.height * 0.1,
                                                child: ListView(
                                                  // This next line does the trick.
                                                  scrollDirection: Axis.horizontal,
                                                  children: [
                                                    Row(
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width: size.width * 0.17,
                                                          height: size.height * 0.1,
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              //getAllDriverLocation();
                                                              setState(() {
                                                                selectedVehicleCategory = "Budget";
                                                                selectedVehicleSubCategory = "Tuk";
                                                                lowerBidLimit = tukList['lowerBidLimit'];
                                                                selectedCategoryDetail = tukList;
                                                              });
                                                              await priceCalculation();
                                                            },
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: <Widget>[
                                                                  Image(
                                                                      image: AssetImage(
                                                                    selectedVehicleSubCategory == 'Tuk'
                                                                        ? 'assets/icons/book_page/three_wheel_white.png'
                                                                        : 'assets/icons/book_page/three_wheel_black.png',
                                                                  )),
                                                                  // Image(
                                                                  //   image: NetworkImage(selectedVehicleSubCategory == 'Tuk'
                                                                  //       ? tukList['subCategoryIcon']
                                                                  //       : tukList['subCategoryIconSelected']),
                                                                  // ),
                                                                  Text(
                                                                    'Tuk',
                                                                    style: TextStyle(
                                                                        color: selectedVehicleSubCategory == 'Tuk' ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                                                  ),
                                                                  SizedBox(height: size.height * 0.01)
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: size.width * 0.03,
                                                        ),
                                                        SizedBox(
                                                          width: size.width * 0.17,
                                                          height: size.height * 0.1,
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                selectedVehicleCategory = "Budget";
                                                                selectedVehicleSubCategory = "Nano";
                                                                lowerBidLimit = nanoList['lowerBidLimit'];
                                                                selectedCategoryDetail = nanoList;
                                                              });
                                                              await priceCalculation();
                                                            },
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: <Widget>[
                                                                  Image(
                                                                      image: AssetImage(
                                                                    selectedVehicleSubCategory == 'Nano' ? 'assets/icons/book_page/nano_white.png' : 'assets/icons/book_page/nano_back.png',
                                                                  )),
                                                                  // Image(
                                                                  //   image: NetworkImage(selectedVehicleSubCategory == 'Nano'
                                                                  //       ? nanoList['subCategoryIcon']
                                                                  //       : nanoList['subCategoryIconSelected']),
                                                                  // ),
                                                                  Text(
                                                                    'Nano',
                                                                    style: TextStyle(
                                                                        color: selectedVehicleSubCategory == 'Nano' ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                                                  ),
                                                                  SizedBox(height: size.height * 0.01),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(context).size.width * 0.03,
                                                        ),
                                                        SizedBox(
                                                          width: size.width * 0.22,
                                                          height: size.height * 0.1,
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                selectedVehicleCategory = "Economy";
                                                                selectedVehicleSubCategory = "Smart";
                                                                lowerBidLimit = smartList['lowerBidLimit'];
                                                                selectedCategoryDetail = smartList;
                                                              });
                                                              await priceCalculation();
                                                            },
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: <Widget>[
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                                                                    child: Image(
                                                                      image: AssetImage(
                                                                        selectedVehicleSubCategory == 'Smart' ? 'assets/icons/book_page/car_white.png' : 'assets/icons/book_page/car_black.png',
                                                                      ),
                                                                      width: size.width * 0.64,
                                                                    ),
                                                                  ),
                                                                  // Image(
                                                                  //   image: NetworkImage(selectedVehicleSubCategory == 'Smart'
                                                                  //       ? smartList['subCategoryIcon']
                                                                  //       : smartList['subCategoryIconSelected']),
                                                                  // ),
                                                                  Text(
                                                                    'Smart',
                                                                    style: TextStyle(
                                                                        color: selectedVehicleSubCategory == 'Smart' ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                                                  ),
                                                                  SizedBox(height: size.height * 0.01),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: size.width * 0.03,
                                                        ),
                                                        SizedBox(
                                                          width: size.width * 0.22,
                                                          height: size.height * 0.1,
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                selectedVehicleCategory = "Economy";
                                                                selectedVehicleSubCategory = "Prime";
                                                                lowerBidLimit = primeList['lowerBidLimit'];
                                                                selectedCategoryDetail = primeList;
                                                              });
                                                              await priceCalculation();
                                                            },
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: <Widget>[
                                                                  Image(
                                                                    image: AssetImage(
                                                                      selectedVehicleSubCategory == 'Prime' ? 'assets/icons/book_page/van_white.png' : 'assets/icons/book_page/van_black.png',
                                                                    ),
                                                                    width: size.width * 0.64,
                                                                  ),
                                                                  // Image(
                                                                  //   image: NetworkImage(selectedVehicleSubCategory == 'Prime'
                                                                  //       ? primeList['subCategoryIcon']
                                                                  //       : primeList['subCategoryIconSelected']),
                                                                  // ),
                                                                  Text(
                                                                    'Prime',
                                                                    style: TextStyle(
                                                                        color: selectedVehicleSubCategory == 'Prime' ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                                                  ),
                                                                  SizedBox(height: size.height * 0.01),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        // SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                                                        // Container(
                                                        //   width: 60,
                                                        //   height: 80,
                                                        //   child:
                                                        //       GestureDetector(
                                                        //     onTap:
                                                        //         () async {
                                                        //       setState(() {
                                                        //         selectedVehicleCategory =
                                                        //             "Family";
                                                        //         selectedVehicleSubCategory =
                                                        //             "Mini Van";
                                                        //         lowerBidLimit =
                                                        //             miniVan[
                                                        //                 'lowerBidLimit'];
                                                        //         selectedCategoryDetail =
                                                        //             miniVan;
                                                        //       });
                                                        //       await priceCalculation();
                                                        //     },
                                                        //     child:  Center(
                                                        //         child:
                                                        //             Column(
                                                        //           mainAxisSize:
                                                        //               MainAxisSize
                                                        //                   .min,
                                                        //           children: <
                                                        //               Widget>[
                                                        //             Image(
                                                        //               image: NetworkImage(selectedVehicleSubCategory == 'Mini Van'
                                                        //                   ? miniVan['subCategoryIcon']
                                                        //                   : miniVan['subCategoryIconSelected']),
                                                        //             ),
                                                        //             Text(
                                                        //               'Mini Van',
                                                        //               style: TextStyle(
                                                        //                   color:  selectedVehicleSubCategory ==
                                                        //                       'Mini Van'
                                                        //                       ? Colors
                                                        //                       .white
                                                        //                       : Colors
                                                        //                       .black,
                                                        //                   fontWeight: FontWeight.bold,
                                                        //                   fontSize: 15),
                                                        //             ),
                                                        //             SizedBox(
                                                        //                 height:
                                                        //                     size.height * 0.01),
                                                        //           ],
                                                        //         ),
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ))
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 20,
                                            child: GestureDetector(
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(top: 14, bottom: 14),
                                                child: Text(
                                                  "Distance:",
                                                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 18),
                                                ),
                                              ),
                                              onTap: () {
                                                // showDialog(
                                                //     context: context,
                                                //     builder: (context) {
                                                //       return PaymentDialog();
                                                //     });
                                              },
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.001),
                                          Text(
                                            '${distanceKM}Km',
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                          ),
                                          SizedBox(width: size.width * 0.03),
                                          Expanded(
                                            flex: 50,
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return PromoCodeDialog(
                                                        addCode: (p0) {},
                                                      );
                                                    });
                                              },
                                              child: Container(
                                                alignment: Alignment.topLeft,
                                                padding: const EdgeInsets.only(top: 14, bottom: 14),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "Estimate Cost: ",
                                                        style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.black, fontSize: 15),
                                                      ),
                                                      TextSpan(
                                                        text: " Rs.$tripTotalCost",
                                                        style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // SizedBox(width: size.width * 0.07),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' Pay By: ',
                                                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' Cash: ',
                                                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                                                    ),
                                                    Checkbox(
                                                      checkColor: Colors.black, // color of tick Mark
                                                      activeColor: Colors.white,
                                                      value: cashValue,
                                                      onChanged: (bool? value) {
                                                        setState(() {
                                                          cashValue = value!;
                                                          cardValue = false;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      ' Card: ',
                                                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                                                    ),
                                                    Checkbox(
                                                      value: cardValue,
                                                      checkColor: Colors.black, // color of tick Mark
                                                      activeColor: Colors.white,
                                                      onChanged: (bool? value) {
                                                        setState(() {
                                                          cardValue = value!;
                                                          cashValue = false;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width * 0.1,
                                          )

                                          //SizedBox
                                          */ /** Checkbox Widget **/ /*
                                          //Checkbox
                                        ], //<Widget>[]
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 50,
                                              child:
                                                  // Container(
                                                  //   height:45,
                                                  //   child:Card(
                                                  //     elevation: 1,
                                                  //     color: Colors.black,
                                                  //     margin: EdgeInsets.all(0),
                                                  //     shape: RoundedRectangleBorder(
                                                  //         borderRadius: BorderRadius.only(
                                                  //           topLeft: Radius.circular(25),
                                                  //           topRight: Radius.circular(25),
                                                  //           bottomLeft: Radius.circular(25),
                                                  //           bottomRight:Radius.circular(25),)),
                                                  //     child: Container(
                                                  //       alignment: Alignment.bottomCenter,
                                                  //       child: Text(
                                                  //         "Book Now",
                                                  //         style: CustomTextStyle.regularTextStyle
                                                  //             .copyWith(
                                                  //             color: Colors.white, fontSize: 16),
                                                  //       ),
                                                  //       padding: EdgeInsets.only( bottom: 10),
                                                  //     ),
                                                  //   ),
                                                  //
                                                  // ),
                                                  GestureDetector(
                                                child: SizedBox(
                                                  height: size.height * 0.06,
                                                  child: Card(
                                                    elevation: 1,
                                                    color: Colors.green,
                                                    margin: const EdgeInsets.all(0),
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(25),
                                                      topRight: Radius.circular(25),
                                                      bottomLeft: Radius.circular(25),
                                                      bottomRight: Radius.circular(25),
                                                    )),
                                                    child: Container(
                                                      alignment: Alignment.bottomCenter,
                                                      padding: const EdgeInsets.only(bottom: 10),
                                                      child: Text(
                                                        "Book Now",
                                                        style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 25),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  //socket.clearListeners();
                                                  validateRide();
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                          // getDestinationView(),

                          // Container(
                          //   width: double.infinity,
                          //   color: Color(0xFFFF922C),
                          //   child: Row(
                          //     children: <Widget>[
                          //       Expanded(
                          //         child: GestureDetector(
                          //           child: Container(
                          //             alignment: Alignment.center,
                          //             child: Text(
                          //               "Pay By",
                          //               style: CustomTextStyle
                          //                   .regularTextStyle
                          //                   .copyWith(
                          //                       color: Colors.white,
                          //                       fontSize: 16),
                          //             ),
                          //             padding: EdgeInsets.only(
                          //                 top: 14, bottom: 14),
                          //           ),
                          //           onTap: () {
                          //             showDialog(
                          //                 context: context,
                          //                 builder: (context) {
                          //                   return PaymentDialog();
                          //                 });
                          //           },
                          //         ),
                          //         flex: 5,
                          //       ),
                          //       Expanded(
                          //         child: GestureDetector(
                          //           child: Container(
                          //             alignment: Alignment.center,
                          //             child: Text(
                          //               "Cash",
                          //               style: CustomTextStyle
                          //                   .regularTextStyle
                          //                   .copyWith(
                          //                       color: Colors.white,
                          //                       fontSize: 16),
                          //             ),
                          //             padding: EdgeInsets.only(
                          //                 top: 14, bottom: 14),
                          //           ),
                          //           onTap: () {
                          //             showDialog(
                          //                 context: context,
                          //                 builder: (context) {
                          //                   return PaymentDialog();
                          //                 });
                          //           },
                          //         ),
                          //         flex: 6,
                          //       ),
                          //       Expanded(
                          //         child: Padding(
                          //           padding: EdgeInsets.only(
                          //               right: 30.0, left: 30),
                          //           child: Container(
                          //             height: 90,
                          //             width: 40,
                          //             child: Card(
                          //               elevation: 1,
                          //               color: Colors.green,
                          //               margin: EdgeInsets.all(0),
                          //               shape: RoundedRectangleBorder(
                          //                   borderRadius: BorderRadius.only(
                          //                 topLeft: Radius.circular(25),
                          //                 topRight: Radius.circular(25),
                          //                 bottomLeft: Radius.circular(25),
                          //                 bottomRight: Radius.circular(25),
                          //               )),
                          //               child: Column(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.end,
                          //                 children: [
                          //
                          //                   Row(
                          //                     children: [
                          //                       Expanded(
                          //                         child:
                          //                             // Container(
                          //                             //   height:45,
                          //                             //   child:Card(
                          //                             //     elevation: 1,
                          //                             //     color: Colors.black,
                          //                             //     margin: EdgeInsets.all(0),
                          //                             //     shape: RoundedRectangleBorder(
                          //                             //         borderRadius: BorderRadius.only(
                          //                             //           topLeft: Radius.circular(25),
                          //                             //           topRight: Radius.circular(25),
                          //                             //           bottomLeft: Radius.circular(25),
                          //                             //           bottomRight:Radius.circular(25),)),
                          //                             //     child: Container(
                          //                             //       alignment: Alignment.bottomCenter,
                          //                             //       child: Text(
                          //                             //         "Book Now",
                          //                             //         style: CustomTextStyle.regularTextStyle
                          //                             //             .copyWith(
                          //                             //             color: Colors.white, fontSize: 16),
                          //                             //       ),
                          //                             //       padding: EdgeInsets.only( bottom: 10),
                          //                             //     ),
                          //                             //   ),
                          //                             //
                          //                             // ),
                          //                             GestureDetector(
                          //                           child: Container(
                          //                             height: 45,
                          //                             child: Card(
                          //                               elevation: 1,
                          //                               color: Colors.black,
                          //                               margin:
                          //                                   EdgeInsets.all(0),
                          //                               shape:
                          //                                   RoundedRectangleBorder(
                          //                                       borderRadius:
                          //                                           BorderRadius
                          //                                               .only(
                          //                                 topLeft:
                          //                                     Radius.circular(
                          //                                         25),
                          //                                 topRight:
                          //                                     Radius.circular(
                          //                                         25),
                          //                                 bottomLeft:
                          //                                     Radius.circular(
                          //                                         25),
                          //                                 bottomRight:
                          //                                     Radius.circular(
                          //                                         25),
                          //                               )),
                          //                               child: Container(
                          //                                 alignment: Alignment
                          //                                     .bottomCenter,
                          //                                 child: Text(
                          //                                   "Book Now",
                          //                                   style: CustomTextStyle
                          //                                       .regularTextStyle
                          //                                       .copyWith(
                          //                                           color: Colors
                          //                                               .white,
                          //                                           fontSize:
                          //                                               16),
                          //                                 ),
                          //                                 padding:
                          //                                     EdgeInsets.only(
                          //                                         bottom: 10),
                          //                               ),
                          //                             ),
                          //                           ),
                          //                           onTap: () {
                          //                             //socket.clearListeners();
                          //                             validateRide();
                          //                           },
                          //                         ),
                          //                         flex: 50,
                          //                       )
                          //                     ],
                          //                   )
                          //                 ],
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //         flex: 20,
                          //       )
                          //     ],
                          //   ),
                          // ),
                          Container(width: double.infinity, height: 1, color: const Color(0xFFFF922C), child: const Text('')),
                        ],
                      )
                    ],
                  );
                },
              )
            : Container(
            alignment: Alignment.topCenter,
                color: Colors.white,
                margin: const EdgeInsets.only(top: 20),
                child: const Center(
                  child: CircularProgressIndicator(
                    value: 0.8,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  ),
                )),
      ),
    );*/
    return Scaffold(
      // key: scaffoldKey,
      // resizeToAvoidBottomInset: true,
      body: loaded
          ? Builder(
              builder: (context) {
                return Stack(
                  children: [
                    polylines != null
                        ? SfMaps(
                            layers: [
                              MapTileLayer(
                                initialFocalLatLng: MapLatLng(widget.pickupPlace.latitude, widget.pickupPlace.longitude),
                                initialZoomLevel: 13,
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                zoomPanBehavior: zoomPanBehavior,
                                sublayers: [
                                  MapPolylineLayer(
                                    polylines: List<MapPolyline>.generate(
                                      polylines.length,
                                      (int index) {
                                        // _logger.i('Poly Line Length : ' + polylines.length.toString());
                                        return MapPolyline(
                                          points: polylines[index].points,
                                          color: polylines[index].color,
                                          width: polylines[index].width,
                                        );
                                      },
                                    ).toSet(),
                                  ),
                                ],
                                initialMarkersCount: markerData == null ? 0 : markerData.length,
                                markerBuilder: (context, index) {
                                  try {
                                    return MapMarker(
                                        iconColor: Colors.white,
                                        iconStrokeColor: Colors.blue,
                                        iconStrokeWidth: 2,
                                        latitude: markerData[index]['currentLocation']['latitude'],
                                        longitude: markerData[index]['currentLocation']['longitude'],
                                        child: Image.asset(
                                          "assets/icons/car_marker.png",
                                          scale: 1,
                                        ));
                                  } catch (e) {
                                    _logger.e(e.toString());
                                    return const MapMarker(latitude: 0, longitude: 0);
                                  }
                                },
                              ),
                            ],
                          )
                        : Container(),
                    Column(
                      key: const Key("Cars"),
                      children: [
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.only(right: 12, top: 24),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const PickupBothLocations()), (Route<dynamic> route) => false);

                                // Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (context) => UserDashboardPage()), (Route<dynamic> route) => false);
                                // Navigator.of(context).pop();
                              },
                              child: const Image(image: AssetImage("assets/icons/ic_close.png")),
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 10,
                                margin: const EdgeInsets.only(left: 16),
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                                height: 10,
                              ),
                              Expanded(
                                flex: 100,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    widget.pickupPlaceAddress.toString(),
                                    style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey.shade800),
                                  ),
                                ),
                              ),
                              IconButton(icon: const Icon(Icons.my_location, color: Colors.greenAccent, size: 18), onPressed: () {})
                            ],
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 10,
                                margin: const EdgeInsets.only(left: 16),
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.pink),
                                height: 10,
                              ),
                              Expanded(
                                flex: 100,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    widget.dropOffPlaceAddress.toString(),
                                    style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey.shade800),
                                  ),
                                ),
                              ),
                              IconButton(
                                  icon: const Icon(
                                    Icons.local_taxi_sharp,
                                    color: Colors.pink,
                                    size: 18,
                                  ),
                                  onPressed: () {})
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 80,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const <Widget>[],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.002,
                        ),
                        SizedBox(
                          height: size.height * 0.38,
                          child: Card(
                              elevation: 1,
                              color: const Color(0xFFFF922C),
                              margin: const EdgeInsets.all(0),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Pick your Category",
                                                style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.black, fontSize: 22),
                                              )),
                                          Container(
                                            alignment: Alignment.topCenter,
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: GestureDetector(
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "-   ",
                                                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (selectedVehicleSubCategory == 'Tuk' && lowerBidLimit != tukList['lowerBidLimit']) {
                                                    lowerBidLimit = lowerBidLimit - 1;
                                                  } else if (selectedVehicleSubCategory == 'Nano' && lowerBidLimit != nanoList['lowerBidLimit']) {
                                                    lowerBidLimit = lowerBidLimit - 1;
                                                  } else if (selectedVehicleSubCategory == 'Smart' && lowerBidLimit != smartList['lowerBidLimit']) {
                                                    lowerBidLimit = lowerBidLimit - 1;
                                                  } else if (selectedVehicleSubCategory == 'Prime' && lowerBidLimit != primeList['lowerBidLimit']) {
                                                    lowerBidLimit = lowerBidLimit - 1;
                                                  } else if (selectedVehicleSubCategory == 'Mini Van' && lowerBidLimit != miniVan['lowerBidLimit']) {
                                                    lowerBidLimit = lowerBidLimit - 1;
                                                  }
                                                });
                                                priceCalculation();
                                              },
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.topCenter,
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: Text(
                                              "Rs.$lowerBidLimit",
                                              style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 30),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerRight,
                                            padding: const EdgeInsets.only(bottom: 10),
                                            child: GestureDetector(
                                              child: Container(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  "  +",
                                                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (selectedVehicleSubCategory == 'Tuk' && lowerBidLimit != tukList['upperBidLimit']) {
                                                    lowerBidLimit = lowerBidLimit + 1;
                                                  } else if (selectedVehicleSubCategory == 'Nano' && lowerBidLimit != nanoList['upperBidLimit']) {
                                                    lowerBidLimit = lowerBidLimit + 1;
                                                  } else if (selectedVehicleSubCategory == 'Smart' && lowerBidLimit != smartList['upperBidLimit']) {
                                                    lowerBidLimit = lowerBidLimit + 1;
                                                  } else if (selectedVehicleSubCategory == 'Prime' && lowerBidLimit != primeList['upperBidLimit']) {
                                                    lowerBidLimit = lowerBidLimit + 1;
                                                  } else if (selectedVehicleSubCategory == 'Mini Van' && lowerBidLimit != miniVan['upperBidLimit']) {
                                                    lowerBidLimit = lowerBidLimit + 1;
                                                  }
                                                  priceCalculation();
                                                });
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Flexible(
                                            flex: 6,
                                            child: SizedBox(
                                              height: size.height * 0.1,
                                              child: ListView(
                                                // This next line does the trick.
                                                scrollDirection: Axis.horizontal,
                                                children: [
                                                  Row(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: size.width * 0.17,
                                                        height: size.height * 0.1,
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            //getAllDriverLocation();
                                                            setState(() {
                                                              selectedVehicleCategory = "Budget";
                                                              selectedVehicleSubCategory = "Tuk";
                                                              lowerBidLimit = tukList['lowerBidLimit'];
                                                              selectedCategoryDetail = tukList;
                                                            });
                                                            await priceCalculation();
                                                          },
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: <Widget>[
                                                                Image(
                                                                    image: AssetImage(
                                                                  selectedVehicleSubCategory == 'Tuk'
                                                                      ? 'assets/icons/book_page/three_wheel_white.png'
                                                                      : 'assets/icons/book_page/three_wheel_black.png',
                                                                )),
                                                                // Image(
                                                                //   image: NetworkImage(selectedVehicleSubCategory == 'Tuk'
                                                                //       ? tukList['subCategoryIcon']
                                                                //       : tukList['subCategoryIconSelected']),
                                                                // ),
                                                                Text(
                                                                  'Tuk',
                                                                  style: TextStyle(
                                                                      color: selectedVehicleSubCategory == 'Tuk' ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                                                ),
                                                                SizedBox(height: size.height * 0.01)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: size.width * 0.03,
                                                      ),
                                                      SizedBox(
                                                        width: size.width * 0.17,
                                                        height: size.height * 0.1,
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            setState(() {
                                                              selectedVehicleCategory = "Budget";
                                                              selectedVehicleSubCategory = "Nano";
                                                              lowerBidLimit = nanoList['lowerBidLimit'];
                                                              selectedCategoryDetail = nanoList;
                                                            });
                                                            await priceCalculation();
                                                          },
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: <Widget>[
                                                                Image(
                                                                    image: AssetImage(
                                                                  selectedVehicleSubCategory == 'Nano' ? 'assets/icons/book_page/nano_white.png' : 'assets/icons/book_page/nano_back.png',
                                                                )),
                                                                // Image(
                                                                //   image: NetworkImage(selectedVehicleSubCategory == 'Nano'
                                                                //       ? nanoList['subCategoryIcon']
                                                                //       : nanoList['subCategoryIconSelected']),
                                                                // ),
                                                                Text(
                                                                  'Nano',
                                                                  style: TextStyle(
                                                                      color: selectedVehicleSubCategory == 'Nano' ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                                                ),
                                                                SizedBox(height: size.height * 0.01),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.03,
                                                      ),
                                                      SizedBox(
                                                        width: size.width * 0.22,
                                                        height: size.height * 0.1,
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            setState(() {
                                                              selectedVehicleCategory = "Economy";
                                                              selectedVehicleSubCategory = "Smart";
                                                              lowerBidLimit = smartList['lowerBidLimit'];
                                                              selectedCategoryDetail = smartList;
                                                            });
                                                            await priceCalculation();
                                                          },
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: <Widget>[
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                                                                  child: Image(
                                                                    image: AssetImage(
                                                                      selectedVehicleSubCategory == 'Smart' ? 'assets/icons/book_page/car_white.png' : 'assets/icons/book_page/car_black.png',
                                                                    ),
                                                                    width: size.width * 0.64,
                                                                  ),
                                                                ),
                                                                // Image(
                                                                //   image: NetworkImage(selectedVehicleSubCategory == 'Smart'
                                                                //       ? smartList['subCategoryIcon']
                                                                //       : smartList['subCategoryIconSelected']),
                                                                // ),
                                                                Text(
                                                                  'Smart',
                                                                  style: TextStyle(
                                                                      color: selectedVehicleSubCategory == 'Smart' ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                                                ),
                                                                SizedBox(height: size.height * 0.01),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: size.width * 0.03,
                                                      ),
                                                      SizedBox(
                                                        width: size.width * 0.22,
                                                        height: size.height * 0.1,
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            setState(() {
                                                              selectedVehicleCategory = "Economy";
                                                              selectedVehicleSubCategory = "Prime";
                                                              lowerBidLimit = primeList['lowerBidLimit'];
                                                              selectedCategoryDetail = primeList;
                                                            });
                                                            await priceCalculation();
                                                          },
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: <Widget>[
                                                                Image(
                                                                  image: AssetImage(
                                                                    selectedVehicleSubCategory == 'Prime' ? 'assets/icons/book_page/van_white.png' : 'assets/icons/book_page/van_black.png',
                                                                  ),
                                                                  width: size.width * 0.64,
                                                                ),
                                                                // Image(
                                                                //   image: NetworkImage(selectedVehicleSubCategory == 'Prime'
                                                                //       ? primeList['subCategoryIcon']
                                                                //       : primeList['subCategoryIconSelected']),
                                                                // ),
                                                                Text(
                                                                  'Prime',
                                                                  style: TextStyle(
                                                                      color: selectedVehicleSubCategory == 'Prime' ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                                                                ),
                                                                SizedBox(height: size.height * 0.01),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                                                      // Container(
                                                      //   width: 60,
                                                      //   height: 80,
                                                      //   child:
                                                      //       GestureDetector(
                                                      //     onTap:
                                                      //         () async {
                                                      //       setState(() {
                                                      //         selectedVehicleCategory =
                                                      //             "Family";
                                                      //         selectedVehicleSubCategory =
                                                      //             "Mini Van";
                                                      //         lowerBidLimit =
                                                      //             miniVan[
                                                      //                 'lowerBidLimit'];
                                                      //         selectedCategoryDetail =
                                                      //             miniVan;
                                                      //       });
                                                      //       await priceCalculation();
                                                      //     },
                                                      //     child:  Center(
                                                      //         child:
                                                      //             Column(
                                                      //           mainAxisSize:
                                                      //               MainAxisSize
                                                      //                   .min,
                                                      //           children: <
                                                      //               Widget>[
                                                      //             Image(
                                                      //               image: NetworkImage(selectedVehicleSubCategory == 'Mini Van'
                                                      //                   ? miniVan['subCategoryIcon']
                                                      //                   : miniVan['subCategoryIconSelected']),
                                                      //             ),
                                                      //             Text(
                                                      //               'Mini Van',
                                                      //               style: TextStyle(
                                                      //                   color:  selectedVehicleSubCategory ==
                                                      //                       'Mini Van'
                                                      //                       ? Colors
                                                      //                       .white
                                                      //                       : Colors
                                                      //                       .black,
                                                      //                   fontWeight: FontWeight.bold,
                                                      //                   fontSize: 15),
                                                      //             ),
                                                      //             SizedBox(
                                                      //                 height:
                                                      //                     size.height * 0.01),
                                                      //           ],
                                                      //         ),
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ))
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 20,
                                          child: GestureDetector(
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                                              child: Text(
                                                "Distance:",
                                                style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 18),
                                              ),
                                            ),
                                            onTap: () {
                                              // showDialog(
                                              //     context: context,
                                              //     builder: (context) {
                                              //       return PaymentDialog();
                                              //     });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.001),
                                        Text(
                                          '${distanceKM}Km',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                        ),
                                        SizedBox(width: size.width * 0.03),
                                        Expanded(
                                          flex: 50,
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return PromoCodeDialog(
                                                      addCode: (p0, p1) {},
                                                      promoCodeLength: 0,
                                                      promoCode: [],
                                                    );
                                                  });
                                            },
                                            child: Container(
                                              alignment: Alignment.topLeft,
                                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Estimate Cost: ",
                                                      style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.black, fontSize: 15),
                                                    ),
                                                    TextSpan(
                                                      text: " Rs.$tripTotalCost",
                                                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // SizedBox(width: size.width * 0.07),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    ' Pay By: ',
                                                    style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    ' Cash: ',
                                                    style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                                                  ),
                                                  Checkbox(
                                                    checkColor: Colors.black, // color of tick Mark
                                                    activeColor: Colors.white,
                                                    value: cashValue,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        cashValue = value!;
                                                        cardValue = false;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    ' Card: ',
                                                    style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900),
                                                  ),
                                                  Checkbox(
                                                    value: cardValue,
                                                    checkColor: Colors.black, // color of tick Mark
                                                    activeColor: Colors.white,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        cardValue = value!;
                                                        cashValue = false;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.1,
                                        )

                                        //SizedBox
                                        /** Checkbox Widget **/
                                        //Checkbox
                                      ], //<Widget>[]
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 50,
                                            child:
                                                // Container(
                                                //   height:45,
                                                //   child:Card(
                                                //     elevation: 1,
                                                //     color: Colors.black,
                                                //     margin: EdgeInsets.all(0),
                                                //     shape: RoundedRectangleBorder(
                                                //         borderRadius: BorderRadius.only(
                                                //           topLeft: Radius.circular(25),
                                                //           topRight: Radius.circular(25),
                                                //           bottomLeft: Radius.circular(25),
                                                //           bottomRight:Radius.circular(25),)),
                                                //     child: Container(
                                                //       alignment: Alignment.bottomCenter,
                                                //       child: Text(
                                                //         "Book Now",
                                                //         style: CustomTextStyle.regularTextStyle
                                                //             .copyWith(
                                                //             color: Colors.white, fontSize: 16),
                                                //       ),
                                                //       padding: EdgeInsets.only( bottom: 10),
                                                //     ),
                                                //   ),
                                                //
                                                // ),
                                                GestureDetector(
                                              child: SizedBox(
                                                height: size.height * 0.06,
                                                child: Card(
                                                  elevation: 1,
                                                  color: Colors.green,
                                                  margin: const EdgeInsets.all(0),
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(25),
                                                    topRight: Radius.circular(25),
                                                    bottomLeft: Radius.circular(25),
                                                    bottomRight: Radius.circular(25),
                                                  )),
                                                  child: Container(
                                                    alignment: Alignment.bottomCenter,
                                                    padding: const EdgeInsets.only(bottom: 10),
                                                    child: Text(
                                                      "Book Now",
                                                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 25),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                //socket.clearListeners();
                                                validateRide();
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ),
                        // getDestinationView(),

                        // Container(
                        //   width: double.infinity,
                        //   color: Color(0xFFFF922C),
                        //   child: Row(
                        //     children: <Widget>[
                        //       Expanded(
                        //         child: GestureDetector(
                        //           child: Container(
                        //             alignment: Alignment.center,
                        //             child: Text(
                        //               "Pay By",
                        //               style: CustomTextStyle
                        //                   .regularTextStyle
                        //                   .copyWith(
                        //                       color: Colors.white,
                        //                       fontSize: 16),
                        //             ),
                        //             padding: EdgeInsets.only(
                        //                 top: 14, bottom: 14),
                        //           ),
                        //           onTap: () {
                        //             showDialog(
                        //                 context: context,
                        //                 builder: (context) {
                        //                   return PaymentDialog();
                        //                 });
                        //           },
                        //         ),
                        //         flex: 5,
                        //       ),
                        //       Expanded(
                        //         child: GestureDetector(
                        //           child: Container(
                        //             alignment: Alignment.center,
                        //             child: Text(
                        //               "Cash",
                        //               style: CustomTextStyle
                        //                   .regularTextStyle
                        //                   .copyWith(
                        //                       color: Colors.white,
                        //                       fontSize: 16),
                        //             ),
                        //             padding: EdgeInsets.only(
                        //                 top: 14, bottom: 14),
                        //           ),
                        //           onTap: () {
                        //             showDialog(
                        //                 context: context,
                        //                 builder: (context) {
                        //                   return PaymentDialog();
                        //                 });
                        //           },
                        //         ),
                        //         flex: 6,
                        //       ),
                        //       Expanded(
                        //         child: Padding(
                        //           padding: EdgeInsets.only(
                        //               right: 30.0, left: 30),
                        //           child: Container(
                        //             height: 90,
                        //             width: 40,
                        //             child: Card(
                        //               elevation: 1,
                        //               color: Colors.green,
                        //               margin: EdgeInsets.all(0),
                        //               shape: RoundedRectangleBorder(
                        //                   borderRadius: BorderRadius.only(
                        //                 topLeft: Radius.circular(25),
                        //                 topRight: Radius.circular(25),
                        //                 bottomLeft: Radius.circular(25),
                        //                 bottomRight: Radius.circular(25),
                        //               )),
                        //               child: Column(
                        //                 mainAxisAlignment:
                        //                     MainAxisAlignment.end,
                        //                 children: [
                        //
                        //                   Row(
                        //                     children: [
                        //                       Expanded(
                        //                         child:
                        //                             // Container(
                        //                             //   height:45,
                        //                             //   child:Card(
                        //                             //     elevation: 1,
                        //                             //     color: Colors.black,
                        //                             //     margin: EdgeInsets.all(0),
                        //                             //     shape: RoundedRectangleBorder(
                        //                             //         borderRadius: BorderRadius.only(
                        //                             //           topLeft: Radius.circular(25),
                        //                             //           topRight: Radius.circular(25),
                        //                             //           bottomLeft: Radius.circular(25),
                        //                             //           bottomRight:Radius.circular(25),)),
                        //                             //     child: Container(
                        //                             //       alignment: Alignment.bottomCenter,
                        //                             //       child: Text(
                        //                             //         "Book Now",
                        //                             //         style: CustomTextStyle.regularTextStyle
                        //                             //             .copyWith(
                        //                             //             color: Colors.white, fontSize: 16),
                        //                             //       ),
                        //                             //       padding: EdgeInsets.only( bottom: 10),
                        //                             //     ),
                        //                             //   ),
                        //                             //
                        //                             // ),
                        //                             GestureDetector(
                        //                           child: Container(
                        //                             height: 45,
                        //                             child: Card(
                        //                               elevation: 1,
                        //                               color: Colors.black,
                        //                               margin:
                        //                                   EdgeInsets.all(0),
                        //                               shape:
                        //                                   RoundedRectangleBorder(
                        //                                       borderRadius:
                        //                                           BorderRadius
                        //                                               .only(
                        //                                 topLeft:
                        //                                     Radius.circular(
                        //                                         25),
                        //                                 topRight:
                        //                                     Radius.circular(
                        //                                         25),
                        //                                 bottomLeft:
                        //                                     Radius.circular(
                        //                                         25),
                        //                                 bottomRight:
                        //                                     Radius.circular(
                        //                                         25),
                        //                               )),
                        //                               child: Container(
                        //                                 alignment: Alignment
                        //                                     .bottomCenter,
                        //                                 child: Text(
                        //                                   "Book Now",
                        //                                   style: CustomTextStyle
                        //                                       .regularTextStyle
                        //                                       .copyWith(
                        //                                           color: Colors
                        //                                               .white,
                        //                                           fontSize:
                        //                                               16),
                        //                                 ),
                        //                                 padding:
                        //                                     EdgeInsets.only(
                        //                                         bottom: 10),
                        //                               ),
                        //                             ),
                        //                           ),
                        //                           onTap: () {
                        //                             //socket.clearListeners();
                        //                             validateRide();
                        //                           },
                        //                         ),
                        //                         flex: 50,
                        //                       )
                        //                     ],
                        //                   )
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //         flex: 20,
                        //       )
                        //     ],
                        //   ),
                        // ),
                        Container(width: double.infinity, height: 1, color: const Color(0xFFFF922C), child: const Text('')),
                      ],
                    )
                  ],
                );
              },
            )
          : loadingDialog(context),
      /*Container(
              alignment: Alignment.topCenter,
              color: Colors.white,
              margin: const EdgeInsets.only(top: 20),
              child: const Center(
                child: CircularProgressIndicator(
                  value: 0.8,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                ),
              )),*/
    );
  }

  Future<String> getPassengerDetails() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId')!;
    String temp = localStorage.getString("contactNumber")!;

    String email = localStorage.getString('email')!;
    String passengerCode = localStorage.getString('passengerCode')!;
    String userProfilePic = localStorage.getString('userProfilePic')!;
    String token = localStorage.getString('token')!;
    if (mounted) {
      setState(() {
        contactNum = temp;
      });
    }

    return userId;
  }

  Future<String> getUserContact() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String contactNum = localStorage.getString("userContact")!;

    return contactNum;
  }

  _setupRideDetails() async {
    rideDetailsList = [
      passengerCode = await getPassengerDetails(),
      widget.isTextWritten,
      widget.pickupPlaceAddress,
      widget.pickupPlace.latitude,
      widget.pickupPlace.longitude,
      widget.dropOffPlaceAddress,
      widget.dropOffPlace.latitude,
      widget.dropOffPlace.longitude,
      distanceKM,
      selectedVehicleCategory,
      selectedVehicleSubCategory,
      lowerBidLimit.toString(),
      tripTotalCost,
      contactNum
    ];

    printRideDetails();

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DriverSearch(
              rideDetailsList: rideDetailsList,
            )));
  }

  printRideDetails() async {
    if (kDebugMode) {
      print("---------------------- FINALIZED RIDE DETAILS ----------------------");
      print("Passenger Code: ${rideDetailsList[0]}");
      print("Is Text Written: ${rideDetailsList[1]}");
      print("Pickup Place Address: ${rideDetailsList[2]}");
      print("Pickup Place Latitude: ${rideDetailsList[3]}");
      print("Pickup Place Longitude: ${rideDetailsList[4]}");
      print("Drop Place Address: ${rideDetailsList[5]}");
      print("Drop Place Latitude: ${rideDetailsList[6]}");
      print("Drop Place Longitude: ${rideDetailsList[7]}");
      print("Distance: ${rideDetailsList[8]}");
      print("Vehicle Category: ${rideDetailsList[9]}");
      print("Vehicle Sub Category: ${rideDetailsList[10]}");
      print("Lower Bid Limit: ${rideDetailsList[11]}");
      print("Estimate Cost: ${rideDetailsList[12]}");
      print("Contact Number: ${rideDetailsList[13]}");
      print("---------------------- READY TO SET RIDE ----------------------");
    }
  }

  validateRide() async {
    if (selectedVehicleSubCategory == null) {
      _logger.i("Please Select Vehicle Category");
      _showWarningToast("Please select vehicle category");
    } else if (distanceKM.toString() == null) {
      _logger.i("Invalid distance. Please try again");
      _showWarningToast("Invalid distance. Please try again");
    } else if (selectedVehicleSubCategory == null) {
      _logger.i("Please select a vehicle category");
      _showWarningToast("Please select a vehicle category");
    } else if (lowerBidLimit.toString() == null) {
      _logger.i("Invalid lower bid limit. Please try again");
      _showWarningToast("Invalid lower bid limit. Please try again");
    } else if (tripTotalCost.toString() == null) {
      _logger.i("Invalid estimate cost. Please try again");
      _showWarningToast("Invalid estimate cost. Please try again");
    } else {
      _setupRideDetails();
    }
  }

  _showWarningToast(String warningMsg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_rounded,
            color: Colors.white,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.03,
          ),
          Text(
            warningMsg,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    Fluttertoast.showToast(
        toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, msg: warningMsg, backgroundColor: Colors.orangeAccent, textColor: Colors.white, fontSize: 16.0);
  }

  _getDestinationView() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "USD 550-600",
            style: CustomTextStyle.regularTextStyle,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.005,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Note: ",
                  style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                ),
                Expanded(
                  flex: 100,
                  child: Text(
                    "This is an approximate estimate, Actual cost may be different due to traffic and waiting time.",
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                  ),
                )
              ],
            ),
          ),
          /*RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "Note: ",
                      style: CustomTextStyle.mediumTextStyle
                          .copyWith(color: Colors.grey, fontSize: 12),
                    ),
                    TextSpan(
                      text:
                      "This is an approximate estimate, Actual cost may be different due to traffic and waiting time.",
                      style: CustomTextStyle.regularTextStyle
                          .copyWith(color: Colors.grey, fontSize: 12,),
                    )
                  ],
                  ),
                )*/
        ],
      ),
    );
    // : GestureDetector(
    //     onTap: () {
    //       Navigator.of(context).pop();
    //     },
    //     child: Container(
    //       padding: EdgeInsets.only(top: 12, bottom: 12),
    //       width: double.infinity,
    //       color: Colors.grey.shade100,
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: <Widget>[
    //           Icon(
    //             Icons.info_outline,
    //             color: Colors.black,
    //             size: 20,
    //           ),
    //           SizedBox(
    //             height: 4,
    //           ),
    //           Text(
    //             "To get estimation please enter the drop off location",
    //             style: CustomTextStyle.regularTextStyle
    //                 .copyWith(color: Colors.grey, fontSize: 12),
    //           )
    //         ],
    //       ),
    //     ),
    //   );
  }

  showFareEstimationBottomSheet() {
    Size size = MediaQuery.of(context).size;
    return scaffoldKey.currentState!.showBottomSheet((BuildContext context) {
      return Container(
        height: size.height * 0.3,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 16, left: 8, right: 8),
              child: Text(
                "Fare Breakdown",
                style: CustomTextStyle.mediumTextStyle,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 2),
              child: Text(
                "Below mentioned fare rates may change according to surcharge and adjustments.",
                style: CustomTextStyle.regularTextStyle.copyWith(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                    child: Text(
                      "Min Fare (First 1 Km)",
                      style: CustomTextStyle.regularTextStyle.copyWith(fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: Text(
                      "USD 80.00",
                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.005,
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                    child: Text(
                      "After 1 Km (Per Km)",
                      style: CustomTextStyle.regularTextStyle.copyWith(fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: Text(
                      "USD 5.00",
                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.005,
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                    child: Text(
                      "Waiting Time (Per 1 Hour)",
                      style: CustomTextStyle.regularTextStyle.copyWith(fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    child: Text(
                      "USD 300.00",
                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.008,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll(0),
                    shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0)))),
                    foregroundColor: const MaterialStatePropertyAll(Colors.black),
                    backgroundColor: MaterialStatePropertyAll(Colors.grey.shade200),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text(
                  "Close",
                  style: CustomTextStyle.regularTextStyle,
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  priceCalculation() {
    var totalCost = 0;

    if (selectedCategoryDetail == null || distanceKM == 0.0) return 0;

    if (selectedCategoryDetail['priceSelection'].length != null && selectedCategoryDetail['priceSelection'][0]['timeBase'].length != null) {
      _logger.i(distanceKM);
      if (distanceKM <= selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumKM']) {
        totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['baseFare'] + selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumFare']).toInt();
        _logger.i('cost1 $totalCost');
      } else if (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['belowAboveKMRange'] > 0) {
        if (distanceKM <= selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['belowAboveKMRange']) {
          totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['baseFare'] +
                  selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumFare'] +
                  (distanceKM - selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumKM']) * lowerBidLimit)
              .toInt();
          _logger.i('cost2 $totalCost');
        } else if (distanceKM > selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['belowAboveKMRange']) {
          totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['baseFare'] +
                  selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumFare'] +
                  (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['belowAboveKMRange'] - selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumKM']) * lowerBidLimit +
                  (distanceKM - selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['belowAboveKMRange']) * selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['aboveKMFare'])
              .toInt();
          // _logger.i('cost 3$totalCost');
        }
      } else {
        totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['baseFare'] +
                selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumFare'] +
                (distanceKM - selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumKM']) * lowerBidLimit)
            .toInt();
        _logger.i('cost4 $totalCost');
      }

      var cost = totalCost.toStringAsFixed(2);
      _logger.i('cost is $cost');
      setState(() {
        tripTotalCost = cost;
      });

      // this.totalCost!!.text = resources.getString(R.string.rs) + Helpers.currencyFormat(cost)
      // tripRequestModel!!.hireCost = totalCost.toDouble()
    } else {
      // Helpers.showAlertDialog(this, getString(R.string.service_not_available), Helpers.AlertDialogType.WARNING){
      // onBackPressed()
      // }
    }
    return totalCost;
  }
}

class mapMarkerModel {
  double latitude;
  double longitude;

  mapMarkerModel(this.latitude, this.longitude);
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}

class PolylineModel {
  PolylineModel(this.points, this.width, this.color);

  final List<MapLatLng> points;
  final double width;
  final Color color;
}

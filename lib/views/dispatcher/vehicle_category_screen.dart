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

import '../../user_dashboard/user_dashboard_page.dart';
import '../../utils/api_client.dart';
import '../../utils/custom_text_style.dart';
import '../styles.dart';

const double cameraZOOM = 13;
const double cameraTILT = 0;
const double cameraBEARING = 30;

class VehicleCategory extends StatefulWidget {
  final String passengerCode;
  final bool isTextWritten;
  final String pickupPlaceAddress;
  final LatLng pickupPlace;
  final String dropOffPlaceAddress;
  final LatLng dropOffPlace;
  final Map tripDetails;

  const VehicleCategory({
    super.key,
    required this.passengerCode,
    required this.isTextWritten,
    required this.pickupPlaceAddress,
    required this.pickupPlace,
    required this.dropOffPlaceAddress,
    required this.dropOffPlace,
    required this.tripDetails,
  });

  @override
  _VehicleCategoryState createState() => _VehicleCategoryState(isTextWritten);
}

class _VehicleCategoryState extends State<VehicleCategory> {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  String googleAPIKey = "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw";
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  String passengerCode = 'passengerCode';
  late Fluttertoast flutterToast;

  _VehicleCategoryState(this.isTextWritten);

  late String contactNum;

  bool imagesLoaded = false;
  late bool isTextWritten;
  late io.Socket socket;

  List<dynamic> rideDetailsList = [];
  late List<dynamic> markerData;

  var selectedVehicleCategory;
  var tukList, nanoList, smartList, primeList, miniVan;
  var selectedVehicleSubCategory;
  var selectedCategoryDetail;

  var distance;
  var distanceKM;
  var lowerBidLimit = 0;
  var tripTotalCost = '0';

  PolylinePoints polylinePoints = PolylinePoints();
  late List polylinePointss;
  late List<MapLatLng> polyline;
  late List<PolylineModel> polylines;
  late MapZoomPanBehavior zoomPanBehavior;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    setMapPins();
    initSocket();
    getAllLocation();

    setSourceAndDestinationIcons();

    if (isTextWritten) {}
    flutterToast = Fluttertoast();
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer t) => getAllDriverLocation());
    super.initState();
  }

  void initSocket() {}

  getAllDriverLocation() async {
    // String url = "http://192.168.8.100:8101";
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
        });
      }
    });
  }

  getAllLocation() async {
    var data = {'latitude': widget.pickupPlace.latitude, 'longitude': widget.pickupPlace.longitude};
    var res = await ApiClient().postData(data, '/vehiclecategory/getCategoryAllDataTimeAndLocationBased');
    var result = json.decode(res.body);

    _logger.i(result);

    if (result['message'] == "success") {
      setState(() {
        tukList = result['content'][0];
        nanoList = result['content'][0];
        smartList = result['content'][2];
        // primeList = result['content'][3];
        // miniVan = result['content'][4];

        imagesLoaded = true;
      });
    } else {
      return "No Data";
    }
  }

  void setSourceAndDestinationIcons() async {}

  Future<dynamic> setMapPins() {
    var steps;
    const decoder = JsonDecoder();
    List<MapLatLng> polyLineFrom = <MapLatLng>[];

    /*final BASE_URL = "http://206.189.36.239:5000/route/v1/driving/" +
        widget.pickupPlace.longitude.toString() +
        "," +
        widget.pickupPlace.latitude.toString() +
        ";" +
        widget.dropOffPlace.longitude.toString() +
        "," +
        widget.dropOffPlace.latitude.toString() +
        "?steps=true";*/
    final baseUrl =
        "${ApiClient().mapUrl + ApiClient().mapSocket}/route/v1/driving/${widget.pickupPlace.longitude},${widget.pickupPlace.latitude};${widget.dropOffPlace.longitude},${widget.dropOffPlace.latitude}?steps=true";

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
            if (kDebugMode) {
              print(distanceKM);
            }
            polylines = <PolylineModel>[
              PolylineModel(polyLineFrom, 5, Colors.blue),
            ];
            if (kDebugMode) {
              print(polylines);
            }
            zoomPanBehavior = MapZoomPanBehavior(
              minZoomLevel: 13,
              maxZoomLevel: 16,
              enablePinching: true,
              enablePanning: true,
              focalLatLng: MapLatLng(widget.pickupPlace.latitude, widget.pickupPlace.longitude),
            );
          });
        }
      } catch (e) {
        throw Exception(e);
      }
    });
  }

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
                                          if (kDebugMode) {
                                            print(polylines.length);
                                          }
                                          return MapPolyline(
                                            points: polylines[index].points,
                                            color: polylines[index].color,
                                            width: polylines[index].width,
                                          );
                                        },
                                      ).toSet(),
                                    ),
                                  ],
                                  initialMarkersCount: 5,
                                  markerBuilder: (context, index) {
                                    if (index == 0) {
                                      return MapMarker(
                                          iconColor: Colors.white,
                                          iconStrokeColor: Colors.blue,
                                          iconStrokeWidth: 2,
                                          latitude: widget.pickupPlace.latitude,
                                          longitude: widget.pickupPlace.longitude,
                                          child: Image.asset(
                                            "assets/icons/pickup_location_marker.png",
                                            scale: 5,
                                          ));
                                    }
                                    try {
                                      if (index == 1) {
                                        return MapMarker(
                                            iconColor: Colors.white,
                                            iconStrokeColor: Colors.blue,
                                            iconStrokeWidth: 2,
                                            latitude: markerData[0]['currentLocation']['latitude'],
                                            longitude: markerData[0]['currentLocation']['longitude'],
                                            child: Image.asset(
                                              "assets/icons/car_marker.png",
                                              scale: 1,
                                            ));
                                      } else if (index == 2) {
                                        return MapMarker(
                                            iconColor: Colors.white,
                                            iconStrokeColor: Colors.blue,
                                            iconStrokeWidth: 2,
                                            latitude: markerData[1]['currentLocation']['latitude'],
                                            longitude: markerData[1]['currentLocation']['longitude'],
                                            child: Image.asset(
                                              "assets/icons/car_marker.png",
                                              scale: 1,
                                            ));
                                      } else if (index == 3) {
                                        return MapMarker(
                                            iconColor: Colors.white,
                                            iconStrokeColor: Colors.blue,
                                            iconStrokeWidth: 2,
                                            latitude: markerData[2]['currentLocation']['latitude'],
                                            longitude: markerData[2]['currentLocation']['longitude'],
                                            child: Image.asset(
                                              "assets/icons/car_marker.png",
                                              scale: 1,
                                            ));
                                      }
                                    } catch (e) {}

                                    return MapMarker(
                                        iconColor: Colors.white,
                                        iconStrokeColor: Colors.blue,
                                        iconStrokeWidth: 2,
                                        latitude: widget.dropOffPlace.latitude,
                                        longitude: widget.dropOffPlace.longitude,
                                        child: Image.asset(
                                          "assets/icons/pickup_location_marker.png",
                                          scale: 5,
                                        ));
                                  },
                                ),
                              ],
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.grey[300],
                              alignment: Alignment.center,
                              child: Text("Something went wrong...", style: greyNormalTextStyle),
                            ),
                      Column(
                        key: const Key("Cars"),
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.only(right: 12, top: 24),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserDashboardPage()));
                                },
                                child: const Image(
                                  image: AssetImage("assets/icons/ic_close.png"),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 10,
                                    margin: const EdgeInsets.only(left: 16),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
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
                                  IconButton(
                                      icon: const Icon(
                                        Icons.my_location,
                                        color: Colors.greenAccent,
                                        size: 18,
                                      ),
                                      onPressed: () {})
                                ],
                              ),
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 30,
                            ),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 10,
                                    margin: const EdgeInsets.only(left: 16),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.pink,
                                    ),
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
                          ),
                          Expanded(
                            flex: 80,
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          SizedBox(
                            height: 180,
                            child: Card(
                                elevation: 1,
                                color: const Color(0xFFFF922C),
                                margin: const EdgeInsets.all(0),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Pick your \nCategory",
                                                style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.white, fontSize: 20),
                                              )),
                                          Flexible(
                                            flex: 6,
                                            child: SizedBox(
                                              height: 120,
                                              child: ListView(
                                                scrollDirection: Axis.horizontal,
                                                children: [
                                                  SizedBox(
                                                    width: 80,
                                                    height: 107,
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        setState(() {
                                                          selectedVehicleCategory = "Budget";
                                                          selectedVehicleSubCategory = "Tuk";
                                                          lowerBidLimit = tukList['lowerBidLimit'];
                                                          selectedCategoryDetail = tukList;
                                                        });
                                                        await priceCalculation();
                                                      },
                                                      child: Card(
                                                        color: selectedVehicleSubCategory == 'Tuk' ? Colors.green : Colors.white,
                                                        elevation: 15,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(15),
                                                        ),
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Image(
                                                                image: NetworkImage(selectedVehicleSubCategory == 'Tuk' ? tukList['subCategoryIcon'] : tukList['subCategoryIconSelected']),
                                                              ),
                                                              const Text(
                                                                'Tuk',
                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                              ),
                                                              SizedBox(height: size.height * 0.01)
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    height: 107,
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
                                                      child: Card(
                                                        color: selectedVehicleSubCategory == 'Nano' ? Colors.green : Colors.white,
                                                        elevation: 30,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(15.0),
                                                        ),
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Image(
                                                                image: NetworkImage(selectedVehicleSubCategory == 'Nano' ? nanoList['subCategoryIcon'] : nanoList['subCategoryIconSelected']),
                                                              ),
                                                              const Text(
                                                                'Nano',
                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                              ),
                                                              SizedBox(height: size.height * 0.01),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    height: 107,
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
                                                      child: Card(
                                                        color: selectedVehicleSubCategory == 'Smart' ? Colors.green : Colors.white,
                                                        elevation: 30,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(15.0),
                                                        ),
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Image(
                                                                image: NetworkImage(selectedVehicleSubCategory == 'Smart' ? smartList['subCategoryIcon'] : smartList['subCategoryIconSelected']),
                                                              ),
                                                              const Text(
                                                                'Smart',
                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                              ),
                                                              SizedBox(height: size.height * 0.01),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    height: 107,
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
                                                      child: Card(
                                                        color: selectedVehicleSubCategory == 'Prime' ? Colors.green : Colors.white,
                                                        elevation: 30,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(15.0),
                                                        ),
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Image(
                                                                image: NetworkImage(selectedVehicleSubCategory == 'Prime' ? primeList['subCategoryIcon'] : primeList['subCategoryIconSelected']),
                                                              ),
                                                              const Text(
                                                                'Prime',
                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                              ),
                                                              SizedBox(height: size.height * 0.01),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    height: 107,
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        setState(() {
                                                          selectedVehicleCategory = "Family";
                                                          selectedVehicleSubCategory = "Mini Van";
                                                          lowerBidLimit = miniVan['lowerBidLimit'];
                                                          selectedCategoryDetail = miniVan;
                                                        });
                                                        await priceCalculation();
                                                      },
                                                      child: Card(
                                                        color: selectedVehicleSubCategory == 'Mini Van' ? Colors.green : Colors.white,
                                                        elevation: 30,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(15.0),
                                                        ),
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Image(
                                                                image: NetworkImage(selectedVehicleSubCategory == 'Mini Van' ? miniVan['subCategoryIcon'] : miniVan['subCategoryIconSelected']),
                                                              ),
                                                              const Text(
                                                                'Mini Van',
                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                              ),
                                                              SizedBox(height: size.height * 0.01),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 15,
                                            child: GestureDetector(
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(top: 14, bottom: 14),
                                                child: Text(
                                                  "Distance",
                                                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 15),
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
                                          SizedBox(width: size.width * 0.03),
                                          Text(
                                            '${distanceKM}Km',
                                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                                          ),
                                          SizedBox(width: size.width * 0.07),
                                          Expanded(
                                            flex: 50,
                                            child: GestureDetector(
                                              onTap: () {},
                                              child: Container(
                                                alignment: Alignment.topLeft,
                                                padding: const EdgeInsets.only(top: 14, bottom: 14),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "Estimate Cost: ",
                                                        style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.black, fontSize: 13),
                                                      ),
                                                      TextSpan(
                                                        text: "  Rs.$tripTotalCost",
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
                                    ],
                                  ),
                                )),
                          ),
                          // getDestinationView(),

                          Container(
                            width: double.infinity,
                            color: const Color(0xFFFF922C),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: GestureDetector(
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(top: 14, bottom: 14),
                                      child: Text(
                                        "Pay By",
                                        style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                    onTap: () {},
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: GestureDetector(
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(top: 14, bottom: 14),
                                      child: Text(
                                        "Cash",
                                        style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                    onTap: () {},
                                  ),
                                ),
                                Expanded(
                                  flex: 20,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 30.0, left: 30),
                                    child: SizedBox(
                                      height: 90,
                                      width: 40,
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
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
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
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 50,
                                                  child: GestureDetector(
                                                    child: SizedBox(
                                                      height: 45,
                                                      child: Card(
                                                        elevation: 1,
                                                        color: Colors.black,
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
                                                          child: Text(
                                                            "Book Now",
                                                            style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 16),
                                                          ),
                                                          padding: const EdgeInsets.only(bottom: 10),
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      validateRide();
                                                    },
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
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
                                        if (kDebugMode) {
                                          print(polylines.length);
                                        }
                                        return MapPolyline(
                                          points: polylines[index].points,
                                          color: polylines[index].color,
                                          width: polylines[index].width,
                                        );
                                      },
                                    ).toSet(),
                                  ),
                                ],
                                initialMarkersCount: 5,
                                markerBuilder: (context, index) {
                                  if (index == 0) {
                                    return MapMarker(
                                        iconColor: Colors.white,
                                        iconStrokeColor: Colors.blue,
                                        iconStrokeWidth: 2,
                                        latitude: widget.pickupPlace.latitude,
                                        longitude: widget.pickupPlace.longitude,
                                        child: Image.asset(
                                          "assets/icons/pickup_location_marker.png",
                                          scale: 5,
                                        ));
                                  }
                                  try {
                                    if (index == 1) {
                                      return MapMarker(
                                          iconColor: Colors.white,
                                          iconStrokeColor: Colors.blue,
                                          iconStrokeWidth: 2,
                                          latitude: markerData[0]['currentLocation']['latitude'],
                                          longitude: markerData[0]['currentLocation']['longitude'],
                                          child: Image.asset(
                                            "assets/icons/car_marker.png",
                                            scale: 1,
                                          ));
                                    } else if (index == 2) {
                                      return MapMarker(
                                          iconColor: Colors.white,
                                          iconStrokeColor: Colors.blue,
                                          iconStrokeWidth: 2,
                                          latitude: markerData[1]['currentLocation']['latitude'],
                                          longitude: markerData[1]['currentLocation']['longitude'],
                                          child: Image.asset(
                                            "assets/icons/car_marker.png",
                                            scale: 1,
                                          ));
                                    } else if (index == 3) {
                                      return MapMarker(
                                          iconColor: Colors.white,
                                          iconStrokeColor: Colors.blue,
                                          iconStrokeWidth: 2,
                                          latitude: markerData[2]['currentLocation']['latitude'],
                                          longitude: markerData[2]['currentLocation']['longitude'],
                                          child: Image.asset(
                                            "assets/icons/car_marker.png",
                                            scale: 1,
                                          ));
                                    }
                                  } catch (e) {}

                                  return MapMarker(
                                      iconColor: Colors.white,
                                      iconStrokeColor: Colors.blue,
                                      iconStrokeWidth: 2,
                                      latitude: widget.dropOffPlace.latitude,
                                      longitude: widget.dropOffPlace.longitude,
                                      child: Image.asset(
                                        "assets/icons/pickup_location_marker.png",
                                        scale: 5,
                                      ));
                                },
                              ),
                            ],
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: Text("Something went wrong...", style: greyNormalTextStyle),
                          ),
                    Column(
                      key: const Key("Cars"),
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.only(right: 12, top: 24),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserDashboardPage()));
                              },
                              child: const Image(
                                image: AssetImage("assets/icons/ic_close.png"),
                              ),
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 10,
                                  margin: const EdgeInsets.only(left: 16),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
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
                                IconButton(
                                    icon: const Icon(
                                      Icons.my_location,
                                      color: Colors.greenAccent,
                                      size: 18,
                                    ),
                                    onPressed: () {})
                              ],
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 30,
                          ),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 10,
                                  margin: const EdgeInsets.only(left: 16),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.pink,
                                  ),
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
                        ),
                        Expanded(
                          flex: 80,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        SizedBox(
                          height: 180,
                          child: Card(
                              elevation: 1,
                              color: const Color(0xFFFF922C),
                              margin: const EdgeInsets.all(0),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                              "Pick your \nCategory",
                                              style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.white, fontSize: 20),
                                            )),
                                        Flexible(
                                          flex: 6,
                                          child: SizedBox(
                                            height: 120,
                                            child: ListView(
                                              scrollDirection: Axis.horizontal,
                                              children: [
                                                SizedBox(
                                                  width: 80,
                                                  height: 107,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      setState(() {
                                                        selectedVehicleCategory = "Budget";
                                                        selectedVehicleSubCategory = "Tuk";
                                                        lowerBidLimit = tukList['lowerBidLimit'];
                                                        selectedCategoryDetail = tukList;
                                                      });
                                                      await priceCalculation();
                                                    },
                                                    child: Card(
                                                      color: selectedVehicleSubCategory == 'Tuk' ? Colors.green : Colors.white,
                                                      elevation: 15,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15),
                                                      ),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Image(
                                                              image: NetworkImage(selectedVehicleSubCategory == 'Tuk' ? tukList['subCategoryIcon'] : tukList['subCategoryIconSelected']),
                                                            ),
                                                            const Text(
                                                              'Tuk',
                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                            ),
                                                            SizedBox(height: size.height * 0.01)
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  height: 107,
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
                                                    child: Card(
                                                      color: selectedVehicleSubCategory == 'Nano' ? Colors.green : Colors.white,
                                                      elevation: 30,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15.0),
                                                      ),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Image(
                                                              image: NetworkImage(selectedVehicleSubCategory == 'Nano' ? nanoList['subCategoryIcon'] : nanoList['subCategoryIconSelected']),
                                                            ),
                                                            const Text(
                                                              'Nano',
                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                            ),
                                                            SizedBox(height: size.height * 0.01),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  height: 107,
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
                                                    child: Card(
                                                      color: selectedVehicleSubCategory == 'Smart' ? Colors.green : Colors.white,
                                                      elevation: 30,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15.0),
                                                      ),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Image(
                                                              image: NetworkImage(selectedVehicleSubCategory == 'Smart' ? smartList['subCategoryIcon'] : smartList['subCategoryIconSelected']),
                                                            ),
                                                            const Text(
                                                              'Smart',
                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                            ),
                                                            SizedBox(height: size.height * 0.01),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  height: 107,
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
                                                    child: Card(
                                                      color: selectedVehicleSubCategory == 'Prime' ? Colors.green : Colors.white,
                                                      elevation: 30,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15.0),
                                                      ),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Image(
                                                              image: NetworkImage(selectedVehicleSubCategory == 'Prime' ? primeList['subCategoryIcon'] : primeList['subCategoryIconSelected']),
                                                            ),
                                                            const Text(
                                                              'Prime',
                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                            ),
                                                            SizedBox(height: size.height * 0.01),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 80,
                                                  height: 107,
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      setState(() {
                                                        selectedVehicleCategory = "Family";
                                                        selectedVehicleSubCategory = "Mini Van";
                                                        lowerBidLimit = miniVan['lowerBidLimit'];
                                                        selectedCategoryDetail = miniVan;
                                                      });
                                                      await priceCalculation();
                                                    },
                                                    child: Card(
                                                      color: selectedVehicleSubCategory == 'Mini Van' ? Colors.green : Colors.white,
                                                      elevation: 30,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15.0),
                                                      ),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Image(
                                                              image: NetworkImage(selectedVehicleSubCategory == 'Mini Van' ? miniVan['subCategoryIcon'] : miniVan['subCategoryIconSelected']),
                                                            ),
                                                            const Text(
                                                              'Mini Van',
                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                            ),
                                                            SizedBox(height: size.height * 0.01),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 15,
                                          child: GestureDetector(
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                                              child: Text(
                                                "Distance",
                                                style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 15),
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
                                        SizedBox(width: size.width * 0.03),
                                        Text(
                                          '${distanceKM}Km',
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                                        ),
                                        SizedBox(width: size.width * 0.07),
                                        Expanded(
                                          flex: 50,
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              alignment: Alignment.topLeft,
                                              padding: const EdgeInsets.only(top: 14, bottom: 14),
                                              child: RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Estimate Cost: ",
                                                      style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.black, fontSize: 13),
                                                    ),
                                                    TextSpan(
                                                      text: "  Rs.$tripTotalCost",
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
                                  ],
                                ),
                              )),
                        ),
                        // getDestinationView(),

                        Container(
                          width: double.infinity,
                          color: const Color(0xFFFF922C),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(top: 14, bottom: 14),
                                    child: Text(
                                      "Pay By",
                                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(top: 14, bottom: 14),
                                    child: Text(
                                      "Cash",
                                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              ),
                              Expanded(
                                flex: 20,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 30.0, left: 30),
                                  child: SizedBox(
                                    height: 90,
                                    width: 40,
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
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
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
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 50,
                                                child: GestureDetector(
                                                  child: SizedBox(
                                                    height: 45,
                                                    child: Card(
                                                      elevation: 1,
                                                      color: Colors.black,
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
                                                        child: Text(
                                                          "Book Now",
                                                          style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.white, fontSize: 16),
                                                        ),
                                                        padding: const EdgeInsets.only(bottom: 10),
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    validateRide();
                                                  },
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
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
    );
  }

  Future<String> getPassengerDetails() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId')!;
    String temp = localStorage.getString("contactNumber")!;

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
    Map pickupLocation = {
      "address": widget.pickupPlaceAddress,
      "latitude": widget.pickupPlace.latitude,
      "longitude": widget.pickupPlace.longitude,
    };

    Map dropLocation = {
      "address": widget.dropOffPlaceAddress,
      "latitude": widget.dropOffPlace.latitude,
      "longitude": widget.dropOffPlace.longitude,
    };

    var data = {
      "dispatcherId": widget.tripDetails["dispatcherId"],
      "customerName": widget.tripDetails["custName"],
      "customerTelephoneNo": widget.tripDetails["custNumber"],
      "noOfPassengers": widget.tripDetails["numberOfPassengers"],
      "pickupLocation": pickupLocation,
      "dropLocations": dropLocation,
      "distance": distanceKM,
      "hireCost": lowerBidLimit.toString(),
      "vehicleCategory": selectedVehicleCategory,
      "vehicleSubCategory": selectedVehicleSubCategory,
      "totalPrice": tripTotalCost,
      "notes": widget.tripDetails["custNotes"],
      "type": "userDispatch",
      "validTime": 45,
      "operationRadius": 10
    };

    var res = await ApiClient().postData(data, '/dispatch/addDispatch');
    var response = json.decode(res.body);
    if (kDebugMode) {
      print(response);
    }
    if (response['message'] == "success") {
      if (kDebugMode) {
        print('Ok');
      }
    } else {}
  }

  validateRide() async {
    if (selectedVehicleSubCategory == null) {
      if (kDebugMode) {
        print("Please Select Vehicle Category");
      }
      _showWarningToast("Please select vehicle category");
    } else if (distanceKM.toString() == null) {
      if (kDebugMode) {
        print("Invalid distance. Please try again");
      }
      _showWarningToast("Invalid distance. Please try again");
    } else if (selectedVehicleSubCategory == null) {
      if (kDebugMode) {
        print("Please select a vehicle category");
      }
      _showWarningToast("Please select a vehicle category");
    } else if (lowerBidLimit.toString() == null) {
      if (kDebugMode) {
        print("Invalid lower bid limit. Please try again");
      }
      _showWarningToast("Invalid lower bid limit. Please try again");
    } else if (tripTotalCost.toString() == null) {
      if (kDebugMode) {
        print("Invalid estimate cost. Please try again");
      }
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
          const SizedBox(
            width: 12.0,
          ),
          Text(
            warningMsg,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    Fluttertoast.showToast(
      // child: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        msg: warningMsg,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  getDestinationView() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "USD 550-600",
            style: CustomTextStyle.regularTextStyle,
          ),
          const SizedBox(
            height: 4,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
        ],
      ),
    );
  }

  showFareEstimationBottomSheet() {
    return scaffoldKey.currentState!.showBottomSheet((BuildContext context) {
      return Container(
        height: 230,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
        child: Column(
          children: [
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
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
            const SizedBox(
              height: 4,
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
            const SizedBox(
              height: 4,
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
            const SizedBox(
              height: 6,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  elevation: const MaterialStatePropertyAll(0),
                  shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0)))),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: const MaterialStatePropertyAll(Colors.black),
                  backgroundColor: MaterialStatePropertyAll(Colors.grey.shade200),
                ),

                // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      if (kDebugMode) {
        print(distanceKM);
      }
      if (distanceKM <= selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumKM']) {
        totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['baseFare'] + selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumFare']).toInt();
        if (kDebugMode) {
          print('cost1$totalCost');
        }
      } else if (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['belowAboveKMRange'] > 0) {
        if (distanceKM <= selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['belowAboveKMRange']) {
          totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['baseFare'] +
                  selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumFare'] +
                  (distanceKM - selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumKM']) * lowerBidLimit)
              .toInt();
          if (kDebugMode) {
            print('cost2$totalCost');
          }
        } else if (distanceKM > selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['belowAboveKMRange']) {
          totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['baseFare'] +
                  selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumFare'] +
                  (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['belowAboveKMRange'] - selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumKM']) * lowerBidLimit +
                  (distanceKM - selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['belowAboveKMRange']) * selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['aboveKMFare'])
              .toInt();
        }
      } else {
        totalCost = (selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['baseFare'] +
                selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumFare'] +
                (distanceKM - selectedCategoryDetail['priceSelection'][0]['timeBase'][0]['minimumKM']) * lowerBidLimit)
            .toInt();
        if (kDebugMode) {
          print('cost4 $totalCost');
        }
      }

      var cost = totalCost.toStringAsFixed(2);
      if (kDebugMode) {
        print('cost is$cost');
      }
      setState(() {
        tripTotalCost = cost;
      });
    } else {}
    return totalCost;
  }
}

class PolylineModel {
  PolylineModel(this.points, this.width, this.color);

  final List<MapLatLng> points;
  final double width;
  final Color color;
}

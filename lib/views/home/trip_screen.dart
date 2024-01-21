import 'dart:async';
import 'dart:convert';

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Widgets/loading_dialog.dart';
import '../../generated/assets.dart';
import '../../utils/api_client.dart';
import '../../utils/custom_text_style.dart';
import '../../utils/settings.dart';
import 'book_cab.dart';
import 'cancel_trip_feedback.dart';
import 'dialog/payment_dialog.dart';
import 'dialog/promo_code_dialog.dart';
import 'trip_end.dart';
import 'trip_info.dart';

class TripScreen extends StatefulWidget {
  var driverDetailsData;
  var passengerPickupData;
  List passengerDropData = [];

  TripScreen({super.key, this.driverDetailsData, required this.passengerDropData, this.passengerPickupData});

  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
//  String passengerLat passengerLat=  double.parse();
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  late LatLng _ahmedabad; //= LatLng(7.06140169, 79.97053139);
  late LatLng _ahmedabad1; // = LatLng(40.038304, 79.511856);
  var pickupLat;
  var pickupLongi;
  var dropLat;
  var dropLongi;
  var distance;
  var distanceKM;

  String tripStatus = "Driver on the way";
  PolylinePoints polylinePoints = PolylinePoints();
  List polylinePointss = [];
  late MapZoomPanBehavior zoomPanBehavior;
  List<dynamic> markerData = [];

  List<MapLatLng> polyline = [];
  List<PolylineModel> polylines = [];
  List<LatLng> polylineCoordinates = [];
  late io.Socket socket;
  Set<Marker> markers = Set();
  final Set<Polyline> _polyline = {};
  List<LatLng> latlng = [];
  var tripAcceptDetails;
  bool tripCancelChecker = true;
  bool tripStarted = true;
  bool cancelButton = true;
  double tempMarkerSize = 5;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late GoogleMapController mapController;
  late String passengerCode;
  late List<PointLatLng> result;
  final MapTileLayerController _layerController = MapTileLayerController();

  late Timer _timer;

  String googleAPiKey = "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw";

  var overviewPolylines;

  String promoCode = '';
  double codeValue = 0;

  dynamic tripEndDetails;
  dynamic tripPaymentDetails;

  String driverSocketId = '';

  static const LatLng _center = LatLng(33.738045, 73.084488);

  String _passengerId = '';
  List<dynamic> _promoCode = [];
  int _promoCodeLength = 0;

  String _cardNumber = '';
  String _cardMonth = '';
  String _cardYear = '';
  String _cardName = '';
  String _cardCSV = '';
  String _cardType = 'VISA';

  bool loaded = false;

  @override
  void dispose() {
    _timer.cancel();
    // socket.destroy();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    getPassengerID().then((value) => passengerCode = value);

    setState(() {
      _ahmedabad = LatLng(double.parse(widget.passengerPickupData['latitude'].toString()), double.parse(widget.passengerPickupData['longitude'].toString()));
      _ahmedabad1 = LatLng(double.parse(widget.driverDetailsData['latitude'].toString()), double.parse(widget.driverDetailsData['longitude'].toString()));

      dropLat = widget.driverDetailsData['latitude'].toString();
      dropLongi = widget.driverDetailsData['longitude'].toString();
      pickupLat = widget.passengerPickupData['latitude'];
      pickupLongi = widget.passengerPickupData['longitude'];
    });

    _addMarker();
    _getUserLocation();
    setMapPins();

    const oneSec = Duration(seconds: 5); //_getUserLocation(),
    _timer = Timer.periodic(oneSec, (Timer t) => {driverDetailsSocket(), _addMarker()});
    latlng.add(_ahmedabad);
    latlng.add(_ahmedabad1);
    _onAddMarkerButtonPressed();
    _layerController.updateMarkers([1]);
    _getProfileData();
    super.initState();
  }

  void _getProfileData() async {
    String userID = await Settings.getUserID();
    // final data = {'userId': userID};
    final data = {'passengerId': userID};

    // await ApiClient().postData(data, '/user/checkInfo').then((res)

    await ApiClient().postData(data, '/passengerWallet/getWallet').then((res) {
      final response = jsonDecode(res.body);
      // logger.i(response);

      setState(() {
        //Fill Card Details
        _cardType = response['content']['card']['type'].toString();
        _cardNumber = response['content']['card']['number'].toString();
        _cardMonth = response['content']['card']['month'].toString();
        _cardYear = response['content']['card']['year'].toString();
        _cardName = response['content']['card']['owner_name'].toString();
        _cardCSV = response['content']['card']['csv_code'].toString();

        _passengerId = response['content']['_id'].toString();
        if (_passengerId.isEmpty) {
          _passengerId = '';
        }

        _promoCode = response['content']['promocode'];
        if (_promoCode.isEmpty) {
          var promoCode_1 = {
            "promocode": 'gfgfgfg',
            "validStartingDate": '2023-06-05',
            "validEndingDate": '2023-06-15',
            "recordedDate": '2023-06-05',
            "value": 75,
            "isActive": true,
          };

          var promoCode_2 = {
            "promocode": 'gfgfgfg',
            "validStartingDate": '2023-06-05',
            "validEndingDate": '2023-06-15',
            "recordedDate": '2023-06-05',
            "value": 25,
            "isActive": true,
          };
          _promoCode = [promoCode_1, promoCode_2];
          _promoCodeLength = _promoCode.length;
        } else {
          _promoCodeLength = _promoCode.length;
        }

        loaded = true;
      });
    });

    // String dispatcherID = response['content1'][0]['dispatcher'][0]['dispatcherId'];
  }

  Future<void> callDriver(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _tripCanceledByDriver() async {
    /*await AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 1,
      channelKey: 'TripCancelled',
      title: "Trip has been cancelled by the driver",
      body: "Driver has cancelled the trip, Please Retry",
    ));*/
  }

  _driverHasArrived() async {
    /*await AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 1,
      channelKey: 'tripAccept',
      title: "The Trip has Been Started",
      body: "BE SAFE",
    ));*/
  }

  _addMarker() {
    markers.add(createMarker("ahmedabad", _ahmedabad));
    markers.add(createMarker("ahmedabad1", _ahmedabad1));
  }

  Future<String> getPassengerID() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    passengerCode = localStorage.getString('passengerCode')!;
    return passengerCode;
  }

  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place1 = placemarks[0];
    Placemark place2 = placemarks[1];
    if (tripCancelChecker) {
      setState(() {
        var pickupPlace = LatLng(position.latitude, position.longitude);

        _ahmedabad = LatLng(pickupLat, pickupLongi);
      });
    }
  }

  Future<void> _onAddMarkerButtonPressed() async {
    _polyline.add(Polyline(
      polylineId: PolylineId(_center.toString()),
      visible: true,
      points: latlng,
      color: Colors.blue,
    ));
  }

  createMarker(String id, LatLng latLng) {
    return Marker(
      markerId: MarkerId(id),
      position: latLng,
    );
  }

  void _onMapCreated(GoogleMapController mapController) {
    this.mapController = mapController;
  }

  void loadTripEndScreen() {
    // _logger.w('Clicked');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TripEnd(
          tripEndDetails: tripEndDetails,
          driverDetails: widget.driverDetailsData,
          driverID: widget.driverDetailsData['driverId'],
          currentLoaction: _ahmedabad1,
          destionationLocation: _ahmedabad,
          passengerPickupData: widget.passengerPickupData,
          passengerDropData: widget.passengerDropData,
        ),
      ),
    );
  }

  void driverDetailsSocket() {
    //    print("---------------------------------------------------------------------------------Driver Detail Socket--------------------------------");
    String tripID = widget.driverDetailsData['tripId'];
    String driverID = widget.driverDetailsData['driverId'];
    // String url = "http://192.168.8.100:8101";
    socket = io.io(ApiClient().barUrl + ApiClient().passengerSocket, {
      'transports': ["websocket"],
      'autoConnect': true,
    });
    // socket.connect();

    // String socketID = socket.id;

    if (socket.connected) {
      // _logger.i('Socket ${socket.id} is Connected');
    }

    tripAcceptDetails = {'driverId': driverID, 'tripId': tripID, 'socketId': socket.id.toString()};
    // socket.connect();

    Settings.setTripId(tripID);

    socket.emit('getDriverLocationById', tripAcceptDetails);

    socket.on('getDriverLocationByIdResult', (data) {
      /*setState(() {
        switch (data['currentStatus']) {
          case "onTrip":
            tripStatus = "Trip ongoing";
            Settings.setOnTrip(true);
            Settings.setTripId(tripID);
            break;
          case "arrived":
            tripStatus = "Driver arrived";
            break;
          case "uponCompletion":
            tripStatus = "Trip completed";
            Settings.setOnTrip(false);
            Settings.setTripId("");
            break;
          case "online":
            tripStatus = "Driver Online";

            break;
          case "offline":
            tripStatus = "Offline";
            break;
          case "blocked":
            tripStatus = "Blocked";
            break;
          case "goingToPickup":
            tripStatus = "Driver on the way";
            Settings.setOnTrip(true);
            Settings.setTripId(tripID);
            break;
          case "disconnect":
            tripStatus = "Driver disconnected";
            break;
          default:
            tripStatus = "";
        }
        _logger.i('Trip Status : ' + tripStatus);
      });*/

      if (mounted) {
        setState(() {
          driverSocketId = data['socketId'];

          switch (data['currentStatus']) {
            case "goingToPickup":
              tripStatus = "Driver on the way";
              Settings.setOnTrip(true);
              Settings.setTripId(tripID);
              // showNotification('DriverOnTheWay', "DriverOnTheWay", "DriverOnTheWay");
              break;
            case "arrived":
              tripStatus = "Driver arrived";
              // showNotification('DriverArrived', "DriverArrived", "DriverArrived");
              break;
            case "onTrip":
              tripStatus = "Trip ongoing";
              Settings.setOnTrip(true);
              Settings.setTripId(tripID);

              // showNotification('TripOnGoing', "TripOnGoing", "TripOnGoing");
              break;
            case "uponCompletion":
              tripStatus = "Trip completed";
              Settings.setOnTrip(false);
              Settings.setTripId("");
              // showNotification('TripComplete', "TripComplete", "TripComplete");
              break;
            case "online":
              tripStatus = "Driver Online";
              break;
            case "offline":
              tripStatus = "Offline";
              break;
            case "blocked":
              tripStatus = "Blocked";
              break;
            case "disconnect":
              tripStatus = "Driver disconnected";
              break;
            default:
              tripStatus = "";
          }
          // _logger.w('Trip Status : $tripStatus');
        });

        if (tripCancelChecker) {
          if (tripStatus == "Driver on the way") {
            setState(() {
              dropLat = data['currentLocation']['latitude'].toString();
              dropLongi = data['currentLocation']['longitude'].toString();

              _ahmedabad1 = LatLng(data['currentLocation']['latitude'], data['currentLocation']['longitude']);
              setMapPins();
            });
          } else if (tripStatus == "Trip ongoing") {
            setState(() {
              dropLongi = widget.passengerDropData[0]['longitude'].toString();
              dropLat = widget.passengerDropData[0]['latitude'].toString();
              _layerController.updateMarkers([1]);
              _layerController.insertMarker(1);
              tempMarkerSize = 15;
              _ahmedabad1 = LatLng(data['currentLocation']['latitude'], data['currentLocation']['longitude']);
              setMapPins();
              cancelButton = false;
            });
          } else {}

          if (tripStatus == "Trip completed") {
            // showNotification('TripComplete', "Trip Complete", "Your Trip Completed. Come Again");
            Settings.setOnTrip(false);
            Settings.setTripId("");
            // socket.destroy();

            // tripEndDetails = data;

            // _logger.i(tripEndDetails);
          }
        }
      }
    });

    socket.on('request_trip_payment', (tripEndDetails) {
      if (mounted) {
        _logger.i('Request Trip Payment');
        _logger.i(tripEndDetails);
        tripPaymentDetails = tripEndDetails;
      }
    });

    socket.on('tripEndDetails', (tripEndDetails) {
      if (mounted) {
        // _logger.i('Request Trip Payment');
        // _logger.i(tripEndDetails);

        // this.tripEndDetails = tripEndDetails;
      }
    });

    socket.on('tripEndByDriver', (tripEndDetails) {
      if (mounted) {
        // showNotification('TripCancelled', "The Trip has Been Ended", "");
        Settings.setOnTrip(false);
        Settings.setTripId("");

        this.tripEndDetails = tripEndDetails;
        loadTripEndScreen();
        // socket.destroy();

        /*Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => TripEnd(
                    tripEndDetails: data,
                    driverDetails: widget.driverDetailsData,
                    driverID: widget.driverDetailsData['driverId'],
                    currentLoaction: _ahmedabad1,
                    destionationLocation: _ahmedabad,
                    passengerPickupData: widget.passengerPickupData,
                    passengerDropData: widget.passengerDropData,
                  )),
        );*/
      }
    });

    socket.on('tripCancelByDriver', (data) {
      if (tripCancelChecker) {
        if (mounted) {
          // showNotification('tripEnded', "The Trip has Been Ended", "");
          setState(() {
            tripCancelChecker = false;
            Settings.setOnTrip(false);
            Settings.setTripId("");
          });
          // socket.destroy();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Trip Cancelled By Driver"),
            duration: const Duration(milliseconds: 5000),
            onVisible: () {
              _tripCanceledByDriver();
            },
          ));
          Navigator.pop(context);
        }

        // Navigator.pop(context);
      }
    });
  }

  void _payTripPayment(String payMethod, String payStatus) {
    try {
      var payment = {
        'trip_id': tripPaymentDetails['trip']['passengerTripEndRequestModel']['tripId'],
        'pay_method': payMethod,
        'pay_status': payStatus,
        'driver_socket_id': driverSocketId,
      };

      socket.emit('updatePayStatus', payment);
      // loadTripEndScreen();
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<dynamic> setMapPins() {
    var steps;
    const JsonDecoder decoder = JsonDecoder();
    List<MapLatLng> polyLineFrom = <MapLatLng>[];

    // final BASE_URL = "http://206.189.36.239:5000/route/v1/driving/" + pickupLongi.toString() + "," + pickupLat.toString() + ";" + dropLongi.toString() + "," + dropLat.toString() + "?steps=true";
    final baseUrl = "${ApiClient().mapUrl + ApiClient().mapSocket}/route/v1/driving/$pickupLongi,$pickupLat;$dropLongi,$dropLat?steps=true";

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

          if (mounted) {
            setState(() {
              var distanceInMeter = decoder.convert(res)["routes"][0]["distance"];
              var distanceInKM = distanceInMeter / 1000;
              double num2 = double.parse((distanceInKM).toStringAsFixed(2));
              distanceKM = num2;

              polylines = <PolylineModel>[
                PolylineModel(polyLineFrom, 5, Colors.blue),
              ];

              zoomPanBehavior = MapZoomPanBehavior(
                zoomLevel: 15,
                focalLatLng: MapLatLng(pickupLat, pickupLongi),
              );

              loaded = true;
            });
          }
        }
      } catch (e) {
        throw Exception(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          body: loaded
              ? SizedBox(
                  width: double.infinity,
                  child: Stack(
                    children: [
                      polylines != null
                          ? SfMaps(
                              layers: [
                                //  MapShapeLayer(source: data),

                                MapTileLayer(
                                  controller: _layerController,
                                  //initialFocalLatLng: MapLatLng(20.3173, 78.7139),
                                  initialZoomLevel: 1,
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  zoomPanBehavior: zoomPanBehavior,
                                  sublayers: [
                                    MapPolylineLayer(
                                      polylines: List<MapPolyline>.generate(
                                        polylines.length,
                                        (int index) {
                                          // print(polylines.length);
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
                                          latitude: pickupLat,
                                          longitude: pickupLongi,
                                          child: Image.asset(
                                            "assets/icons/pickup_location_marker.png",
                                            scale: 5,
                                          ));
                                    } else if (index == 1) {
                                      return MapMarker(
                                          iconColor: Colors.white,
                                          iconStrokeColor: Colors.blue,
                                          iconStrokeWidth: 2,
                                          latitude: double.parse(dropLat),
                                          longitude: double.parse(dropLongi),
                                          child: Image.asset(
                                            "assets/icons/pickup_location_marker.png",
                                            scale: 5,
                                          ));
                                    }

                                    return MapMarker(
                                        iconColor: Colors.white,
                                        iconStrokeColor: Colors.blue,
                                        iconStrokeWidth: 2,
                                        latitude: double.parse(dropLat),
                                        longitude: double.parse(dropLongi),
                                        child: Image.asset(
                                          "assets/icons/pickup_location_marker.png",
                                          scale: 300,
                                        ));
                                  },
                                ),
                              ],
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              height: 500,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text(
                                  "Map Loading...",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black26),
                                ),
                              ),
                            ),
                      Align(
                        key: const Key("address"),
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: 24),
                          child: Column(
                            children: <Widget>[
                              Card(
                                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
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
                                          widget.passengerPickupData['address'],
                                          style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey.shade800),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                        icon: const Icon(
                                          Icons.favorite_border,
                                          color: Colors.grey,
                                          size: 18,
                                        ),
                                        onPressed: () {})
                                  ],
                                ),
                              ),
                              Card(
                                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: 10,
                                      margin: const EdgeInsets.only(left: 16),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      height: 10,
                                    ),
                                    Expanded(
                                      flex: 100,
                                      child: Container(
                                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                                        margin: const EdgeInsets.only(left: 16),
                                        child: Text(
                                          widget.passengerDropData[0]['address'],
                                          style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey.shade800),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        key: const Key("drive_details"),
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 24),
                                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Stack(
                                          children: <Widget>[
                                            Container(
                                              width: 100,
                                              height: 100,
                                              margin: const EdgeInsets.only(left: 16, top: 16),
                                              // BoxDecoration(image: DecorationImage(image: NetworkImage(widget.driverDetailsData['driverPic'])), borderRadius: BorderRadius.all(Radius.circular(10))),
                                              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(Assets.imagesDriver)), borderRadius: BorderRadius.all(Radius.circular(10))),
                                            ),
                                            Container(
                                              alignment: Alignment.bottomCenter,
                                              margin: const EdgeInsets.only(left: 16, top: 86),
                                              width: 100,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)), color: Colors.black.withOpacity(0.5)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    "4.5",
                                                    style: CustomTextStyle.boldTextStyle.copyWith(color: Colors.white, fontSize: 16),
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.yellowAccent.shade700,
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 20),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                widget.driverDetailsData['driverName'],
                                                style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 16),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Text(
                                                tripStatus,
                                                style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 16, color: Colors.tealAccent.shade700),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey, width: 1), borderRadius: BorderRadius.circular(4)),
                                                child: RichText(
                                                  text: TextSpan(children: [
                                                    TextSpan(text: widget.driverDetailsData['vehicleRegistrationNo'], style: CustomTextStyle.boldTextStyle.copyWith(color: Colors.black)),
                                                    TextSpan(text: "-", style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey, fontSize: 16)),
                                                    TextSpan(
                                                        text: widget.driverDetailsData['vehicleBrand'] + "(" + widget.driverDetailsData['vehicleColor'] + ")",
                                                        style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey))
                                                  ]),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(top: 16),
                                      color: Colors.grey.shade300,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 50,
                                            child: GestureDetector(
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(top: 14, bottom: 14),
                                                child: Text(
                                                  "Payment",
                                                  style: CustomTextStyle.regularTextStyle,
                                                ),
                                              ),
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return PaymentDialog(
                                                        doPay: (payMethod, payStatus) {
                                                          _payTripPayment(payMethod, payStatus);
                                                        },
                                                        tripEndDetails: tripPaymentDetails,
                                                        cardNumber: _cardNumber,
                                                        cardName: _cardName,
                                                        cardMonth: _cardMonth,
                                                        cardYear: _cardYear,
                                                        cardCSV: _cardCSV,
                                                        cardType: _cardType,
                                                      );
                                                    });
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 40,
                                            color: Colors.grey,
                                          ),
                                          Expanded(
                                            flex: 50,
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return PromoCodeDialog(
                                                        addCode: (String code, double value) {
                                                          promoCode = code;
                                                          codeValue = value;
                                                        },
                                                        promoCodeLength: _promoCodeLength,
                                                        promoCode: _promoCode,
                                                      );
                                                    });
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(top: 14, bottom: 14),
                                                child: Text(
                                                  "Promo Code",
                                                  style: CustomTextStyle.regularTextStyle,
                                                ),
                                              ),
                                            ),
                                          ),
                                          /*Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.grey,
                                    ),
                                    Expanded(
                                      flex: 50,
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return PromoCodeDialog();
                                              });
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(top: 14, bottom: 14),
                                          child: Text(
                                            "Promo Code",
                                            style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    )*/
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          callDriver("tel:" + widget.driverDetailsData['driverContactNo']);
                                        },
                                        style: const ButtonStyle(
                                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0)))),
                                          // foregroundColor: MaterialStatePropertyAll(Colors.white),
                                          backgroundColor: MaterialStatePropertyAll(Color(0xFF1ABC9C)),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          padding: MaterialStatePropertyAll(EdgeInsets.all(16)),
                                        ),
                                        child: Text(
                                          "Call Driver",
                                          style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(top: 2),
                                      width: double.infinity,
                                      child: cancelButton
                                          ? ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).push(MaterialPageRoute(
                                                    builder: (context) => CancelTripFeedback(
                                                          tripId: widget.driverDetailsData['tripId'],
                                                          driverId: widget.driverDetailsData['driverId'],
                                                        )));
                                                socket.destroy();
                                              },
                                              style: const ButtonStyle(
                                                shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0)))),
                                                // foregroundColor: MaterialStatePropertyAll(Colors.white),
                                                backgroundColor: MaterialStatePropertyAll(Color(0xFFE74C3C)),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                padding: MaterialStatePropertyAll(EdgeInsets.all(16)),
                                              ),
                                              child: Text(
                                                "Cancel Trip",
                                                style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.white),
                                              ),
                                            )
                                          : null,
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  GestureDetector(
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [BoxShadow(color: Colors.grey.shade200, offset: const Offset(1, 1), spreadRadius: 2, blurRadius: 10)]),
                                      child: const Icon(
                                        Icons.my_location,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const TripInfo(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [BoxShadow(color: Colors.grey.shade200, offset: const Offset(1, 1), spreadRadius: 2, blurRadius: 10)]),
                                      child: const Icon(
                                        Icons.info_outline,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : loadingDialog(context),
        ),
        onWillPop: () {
          return Future(() => true);
        });
  }

/*  showNotification(String channelKey, String title, String body) async {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Insert here your friendly dialog box before call the request method
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 1,
      channelKey: channelKey,
      title: title,
      body: body,
    ));
  }*/
}

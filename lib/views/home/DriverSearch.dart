import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../generated/assets.dart';
import '../../utils/api_client.dart';
import 'cancel_trip.dart';
import 'trip_screen.dart';

class DriverSearch extends StatefulWidget {
  final List rideDetailsList;

  DriverSearch({required this.rideDetailsList});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<DriverSearch> with SingleTickerProviderStateMixin {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  var _visible = true;

  late String _linkMessage;
  final bool _isCreatingLink = false;
  late BuildContext Applicationcontext;
  final String _testString = "To test: long press link and then copy and click from a non-browser "
      "app. Make sure this isn't being tested on iOS simulator and iOS xcode "
      "is properly setup. Look at firebase_dynamic_links/README.md for more "
      "details.";
  late AnimationController animationController;
  late Animation<double> animation;
  List pickupData = [];
  List dropData = [];
  final int _counter = 0;
  var arrayPickup;
  var arrayDrop;
  var passengerDetails;
  bool noDrivers = false;
  var dataList;
  String title = "Title";
  String helper = "helper";
  late io.Socket socket;

  startTime() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, navigationPage);
  }

  void navigationPage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    var user = localStorage.getString('user');
    var userType = localStorage.getString('user_type');
    if (user != null) {
      if (userType == 'doctor') {
        Navigator.of(context).pushReplacementNamed('/DoctorHomeScreen');
      } else {
        Navigator.of(context).pushReplacementNamed('/PatientHomeScreen');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/Welcome');
    }
  }

  late String contactNum;
  late String userID;

  Future<String> getUserContact() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    setState(() {
      contactNum = localStorage.getString("userContact")!;
    });

    return contactNum;
  }

  Future<String> getUserID() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    userID = localStorage.getString("_id")!;

    return userID;
  }

  @override
  dispose() {
    // socket.disconnect();
    // _logger.i("Socket Disconnected : " + socket.disconnected.toString());
    super.dispose();
  }

  @override
  initState() {
    Applicationcontext = context;
    super.initState();

    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    List data1 = [];

    arrayPickup = {"address": widget.rideDetailsList[2].toString(), "latitude": widget.rideDetailsList[3], "longitude": widget.rideDetailsList[4]};
    arrayDrop = [
      {"address": widget.rideDetailsList[5].toString(), "latitude": widget.rideDetailsList[6], "longitude": widget.rideDetailsList[7]}
    ];
    passengerDetails = {"id": widget.rideDetailsList[0].toString(), "contactNumber": widget.rideDetailsList[13].toString()};

    _logger.i(arrayDrop);
    _logger.i(arrayPickup);
    _findOnlineDrivers();
  }

/*  driverArrivingNotification(String driverName, String vehicalName, String vehicalNumber) async {
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
      channelKey: 'DriverOnTheWay',
      title: "$driverName is arriving",
      body: "Your Driver is arriving on a $vehicalName($vehicalNumber)",
    ));
  }*/

  void initSocket() async {
    // String url = "http://192.168.8.100:8101";
    socket = io.io(ApiClient().barUrl + ApiClient().passengerSocket, <String, dynamic>{
      'transports': ["websocket"],
      'autoConnect': true,
    });
    //
    // socket.connect();
    if (socket.connected) {
      // _logger.i("Socket Connected====${socket.id}");
    } else {
      // _logger.i("Socket not connected");
    }
    var tripAcceptDetails;
    String tripID;
    socket.on('driverDetails', (data) {
      // _logger.i(data);
      tripID = data['tripId'];
      tripAcceptDetails = {'tripId': tripID, 'socketId': socket.id.toString()};

      // _logger.i(data);
      // _logger.i(arrayPickup);
      // _logger.i(arrayDrop);

      socket.emit('getTripAcceptDetails', tripAcceptDetails);

      // socket.close();
      // driverArrivingNotification(data['driverName'], data['vehicleBrand'], data['vehicleRegistrationNo']);

      if (mounted) {
        // socket.close();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => TripScreen(
              driverDetailsData: data,
              passengerDropData: arrayDrop,
              passengerPickupData: arrayPickup,
            ),
          ),
          (route) => false,
        );
      }
    });

    socket.on('CancelTrip', (data) {
      // _logger.i("++++++++++++++++++++++++++++++++++++++++++++++++ data");
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CancelTrip()));
      // dispose();
    });

    socket.on('getTripAcceptDetails', (_) => _logger.i('Driver DEtails REcived: ${socket.id}'));

    String rawData;

    socket.on('driverDetails', (args) {
      // _logger.i("==========================Test Socket=====================");
    });
    var data = {
      "passengerId": widget.rideDetailsList[0],
      "address": widget.rideDetailsList[2].toString(),
      "longitude": widget.rideDetailsList[3].toString(),
      "latitude": widget.rideDetailsList[4].toString(),
      "currentStatus": "default"
    };
  }

  createPassengerRide() async {
    final response = await http.post(
      Uri.parse('${ApiClient().barUrl + ApiClient().baseSocket}/trip/findonlinedrivers'), // http://173.82.212.70:8095
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<dynamic, dynamic>{
        'passengerId': widget.rideDetailsList[0],
        'pickupLocation': arrayPickup,
        'dropLocations': arrayDrop,
        'distance': widget.rideDetailsList[8],
        'bidValue': widget.rideDetailsList[11],
        'vehicleCategory': widget.rideDetailsList[9],
        'vehicleSubCategory': widget.rideDetailsList[10],
        'hireCost': widget.rideDetailsList[12],
        'type': 'passengerTrip',
        'validTime': '',
        'payMethod': 'cash',
        'operationRadius': 10
      }),
    );

    // _logger.i(response.body);
    if (response.statusCode == 200) {
      dataList = json.decode(response.body)['notifiedDrivers'];
    } else {
      var result = json.decode(response.body);
      if (result['message'] == "No online Drivers") {
        setState(() {});
      }
    }
    return "Success";
  }

  void _findOnlineDrivers() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    var data = {
      'passengerDetails': passengerDetails,
      // 'pickupLocation':arrayPickup,
      'pickupLocation': arrayPickup,
      'dropLocations': arrayDrop,
      'distance': widget.rideDetailsList[8].toString(),
      'bidValue': widget.rideDetailsList[11],
      'vehicleCategory': widget.rideDetailsList[9],
      'vehicleSubCategory': widget.rideDetailsList[10],
      'hireCost': widget.rideDetailsList[12],
      'type': 'passengerTrip',
      'validTime': "45",
      'payMethod': 'cash',
      'operationRadius': 5.0
    };

    // _logger.i(data);
    var res = await ApiClient().postData(data, '/trip/finddriverforpassenger');

    var result = json.decode(res.body);

    // _logger.i(result);

    // _logger.i("---------------------- FIND ONLINE DRIVERS ----------------------");
    if (res.statusCode == 200) {
      dataList = json.decode(res.body)['notifiedDrivers'];
      var tripDetails = json.decode(res.body)['content'];

      Map<String, dynamic> map = json.decode(res.body);

      driverCheckingModel newDrivermodel = driverCheckingModel();

      newDrivermodel._id = tripDetails["_id"].toString();
    } else {
      var result = json.decode(res.body);
      if (result['message'] == "No online Drivers") {
        setState(() {});
      }
    }
    initSocket();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(true);
        return Future(() => true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  // child: new Image.asset(
                  //   'assets/images/powered_by.png',
                  //   height: 25.0,
                  //   fit: BoxFit.scaleDown,
                  // )),
                  child: Image(
                    image: const AssetImage("assets/icons/taxime_logo_white.png"),
                    width: size.width * 0.4,
                    height: size.height * 0.2,
                  ),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 340.0),
                  child: const Text(
                    'Searching Drivers...',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.deepOrange),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 40),
                  height: size.height * 0.04,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        // _logger.i('clicked');
                        Navigator.pop(context);
                        socket.on('CancelTrip', (data) {
                          // _logger.i("++++++++++++++++++++++++++++++++++++++++++++++++ data");
                          dispose();
                        });

                        //====================================Check=============================
                        // Navigator.of(context).push(new MaterialPageRoute(
                        //     builder: (context) => UserDashboardPage()));

                        // dispose();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ),
                  ),
                ),
                dataList != null
                    ? Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: ListView.builder(
                          itemExtent: 100,
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            return GestureDetector(
                                onTap: () {},
                                child: Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue, width: 3),
                                        // gradient: LinearGradient(colors: [Color(0xFF02aab0    ),Color(0xFF53FFe5) ],
                                        //   begin: Alignment.centerLeft,
                                        //   end: Alignment.centerRight,
                                        // ),
                                        borderRadius: BorderRadius.circular(30.0)),
                                    child: ListTile(
                                        leading: const CircleAvatar(radius: 30, backgroundImage: AssetImage(Assets.imagesDriver)),
                                        // leading: CircleAvatar(radius: 30, backgroundImage: NetworkImage(dataList[i]['driverPic'].toString())),
                                        title: Text(dataList[i]['driverInfo']['driverName']),
                                        subtitle: Text(dataList[i]['currentLocation']['address']),
                                        trailing: Image.asset(Assets.iconsMapMarker)),
                                    // trailing: Image.network(dataList[i]['mapIconOntrip'].toString())),
                                  ),
                                ));
                          },
                          itemCount: dataList.length,
                        ),
                      )
                    : Container()
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/preloader.gif',
                  width: size.width,
                  height: size.height * 0.45,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Customer {
  String name;
  double value;

  Customer(this.name, this.value);

  @override
  String toString() {
    return '{ $name: $value }';
  }
}

class pickLocation {
  late String address;
  late double latitude;
  late double longitude;
}

class driverCheckingModel {
  late String socketId;
  late String _id;

  // driverCheckingModel(this.socketId, this._id);
  // driverCheckingModel.fromJson(Map<String, dynamic> json)
  //     : name = json['n'],
  //       url = json['u'];

  Map<String, dynamic> toJson() {
    return {
      'socketId': socketId,
      'tripId': _id,
    };
  }
}
